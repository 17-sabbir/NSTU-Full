import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:http/http.dart' as http;
import 'package:backend_server/src/generated/protocol.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

class AuthEndpoint extends Endpoint {
  String? _jwtSecret(Session session) {
    final fromPasswords = session.passwords['jwtSecret'];
    if (fromPasswords != null && fromPasswords.trim().isNotEmpty) {
      return fromPasswords.trim();
    }

    // Allow runtime env as fallback (useful for Railway).
    final fromEnv = Platform.environment['JWT_SECRET'];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      return fromEnv.trim();
    }

    // Fallback to Serverpod's service secret if a dedicated jwtSecret isn't configured.
    // This avoids extra config for local/Railway, while still keeping the value secret.
    final fromServiceSecret = session.passwords['serviceSecret'];
    if (fromServiceSecret != null && fromServiceSecret.trim().isNotEmpty) {
      return fromServiceSecret.trim();
    }

    return null;
  }

  String? _resendApiKey(Session session) {
    final fromPasswords = session.passwords['resendApiKey'];
    if (fromPasswords != null && fromPasswords.trim().isNotEmpty) {
      return fromPasswords.trim();
    }
    final fromEnv = Platform.environment['RESEND_API_KEY'];
    if (fromEnv == null || fromEnv.trim().isEmpty) return null;
    return fromEnv.trim();
  }

  // UUID generator for jti
  final Uuid _uuid = Uuid();

  static const Duration _otpTtl = Duration(minutes: 2);
  static const int _otpTtlSeconds = 120;

  String? _normalizeDeviceId(String? deviceId) {
    final v = deviceId?.trim();
    if (v == null || v.isEmpty) return null;
    // Prevent absurdly large values from being stored.
    if (v.length > 200) return null;
    return v;
  }

  String _hashDeviceId(String deviceId) {
    return sha256.convert(utf8.encode(deviceId)).toString();
  }

  Future<void> _ensureTrustedDeviceTable(Session session) async {
    // Best-effort: unmanaged SQL tables.
    try {
      await session.db.unsafeExecute(
        '''
        CREATE TABLE IF NOT EXISTS user_trusted_devices (
          id SERIAL PRIMARY KEY,
          user_id INTEGER NOT NULL,
          device_id_hash TEXT NOT NULL,
          created_at TIMESTAMP NOT NULL DEFAULT NOW(),
          last_used_at TIMESTAMP NOT NULL DEFAULT NOW(),
          CONSTRAINT user_trusted_devices_user_device_unique UNIQUE (user_id, device_id_hash)
        )
        ''',
      );
    } catch (_) {}
  }

  Future<bool> _isDeviceTrusted(
    Session session, {
    required int userId,
    required String deviceIdHash,
  }) async {
    try {
      final res = await session.db.unsafeQuery(
        '''
        SELECT 1
        FROM user_trusted_devices
        WHERE user_id = @uid AND device_id_hash = @h
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'uid': userId, 'h': deviceIdHash}),
      );
      return res.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _upsertTrustedDevice(
    Session session, {
    required int userId,
    required String deviceIdHash,
  }) async {
    try {
      await session.db.unsafeExecute(
        '''
        INSERT INTO user_trusted_devices (user_id, device_id_hash)
        VALUES (@uid, @h)
        ON CONFLICT (user_id, device_id_hash)
        DO UPDATE SET last_used_at = NOW()
        ''',
        parameters: QueryParameters.named({'uid': userId, 'h': deviceIdHash}),
      );
    } catch (_) {}
  }

  String? _issueAuthToken(
    Session session, {
    required String email,
    required String userId,
    required String role,
    required int tokenVersion,
  }) {
    final jwtSecret = _jwtSecret(session);
    if (jwtSecret == null) return null;

    return JWT(
      {
        'uid': int.tryParse(userId) ?? userId,
        'role': role,
        'tv': tokenVersion,
        'jti': _uuid.v4(),
      },
      issuer: 'dishari',
      subject: email,
    ).sign(
      SecretKey(jwtSecret),
      expiresIn: const Duration(days: 30),
    );
  }

  Future<void> _ensureSecurityColumns(Session session) async {
    // This project uses unmanaged SQL tables; keep it resilient.
    // Postgres supports IF NOT EXISTS.
    try {
      await session.db.unsafeExecute(
        'ALTER TABLE users ADD COLUMN IF NOT EXISTS token_version integer NOT NULL DEFAULT 0',
      );
    } catch (_) {}

    try {
      await session.db.unsafeExecute(
        'ALTER TABLE users ADD COLUMN IF NOT EXISTS require_login_email_otp boolean NOT NULL DEFAULT FALSE',
      );
    } catch (_) {}

    await _ensureTrustedDeviceTable(session);
  }

  Future<void> _ensurePatientProfileDobColumn(Session session) async {
    // Best-effort (unmanaged SQL tables).
    try {
      final res = await session.db.unsafeQuery(
        '''
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'patient_profiles'
          AND column_name = 'date_of_birth'
        LIMIT 1
        ''',
      );
      if (res.isNotEmpty) return;

      await session.db.unsafeExecute(
        '''
        ALTER TABLE patient_profiles
        ADD COLUMN date_of_birth DATE
        ''',
      );
    } catch (e) {
      session.log('Could not ensure patient_profiles.date_of_birth: $e',
          level: LogLevel.warning);
    }
  }

  String _decodeDbValue(dynamic value) {
    if (value == null) return '';
    if (value is List<int>) return utf8.decode(value);
    return value.toString();
  }

  int? _decodeDbInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is List<int>) return int.tryParse(utf8.decode(value));
    return int.tryParse(value.toString());
  }

  DateTime? _decodeDbDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is List<int>) return DateTime.tryParse(utf8.decode(value));
    if (value is String) return DateTime.tryParse(value);
    return DateTime.tryParse(value.toString());
  }

  int? _calculateAgeFromDob(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    final hasHadBirthdayThisYear = (now.month > dob.month) ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hasHadBirthdayThisYear) years -= 1;
    if (years < 0) return 0;
    return years;
  }

  Future<OtpChallengeResponse> _createOtpToken({
    required Session session,
    required String purpose,
    String? email,
    String? phone,
  }) async {
    final jwtSecret = _jwtSecret(session);
    if (jwtSecret == null) {
      return OtpChallengeResponse(
        success: false,
        error: 'Server auth is not configured (missing JWT secret).',
      );
    }

    final otp = (Random().nextInt(900000) + 100000).toString();
    final jti = _uuid.v4();

    final payload = <String, dynamic>{
      'purpose': purpose,
      'otp': otp,
      'jti': jti,
    };
    if (email != null) payload['email'] = email;
    if (phone != null) payload['phone'] = phone;

    final token = JWT(
      payload,
      issuer: 'dishari',
      subject: email ?? phone ?? 'otp',
    ).sign(
      SecretKey(jwtSecret),
      expiresIn: _otpTtl,
    );

    // NOTE: returning OTP is ONLY for phone OTP dev-mode popup.
    return OtpChallengeResponse(
      success: true,
      token: token,
      debugOtp: otp,
      expiresInSeconds: _otpTtlSeconds,
    );
  }

  Future<String?> _validateOtpToken({
    required Session session,
    required String purpose,
    required String otp,
    required String token,
    String? email,
    String? phone,
  }) async {
    final jwtSecret = _jwtSecret(session);
    if (jwtSecret == null) {
      return 'Server auth is not configured (missing JWT secret).';
    }

    try {
      final jwt = JWT.verify(token, SecretKey(jwtSecret));
      final payload = jwt.payload;
      if (payload['purpose'] != purpose) return 'Invalid or expired OTP';
      if ((payload['otp'] ?? '').toString() != otp)
        return 'Invalid or expired OTP';
      if (email != null && (payload['email'] ?? '').toString() != email) {
        return 'Invalid or expired OTP';
      }
      if (phone != null && (payload['phone'] ?? '').toString() != phone) {
        return 'Invalid or expired OTP';
      }
      return null;
    } catch (e) {
      session.log('OTP JWT verification failed: $e', level: LogLevel.warning);
      return 'Invalid or expired OTP';
    }
  }

  static final Map<String, List<DateTime>> _rateLimit = {};
  static const int maxAttempts = 5;
  static const Duration window = Duration(minutes: 5);

  bool _isRateLimited(String key) {
    final now = DateTime.now();
    _rateLimit.putIfAbsent(key, () => []);

    // Remove expired attempts
    _rateLimit[key]!.removeWhere((t) => now.difference(t) > window);

    if (_rateLimit[key]!.length >= maxAttempts) {
      return true;
    }

    _rateLimit[key]!.add(now);
    return false;
  }

  //login
  Future<LoginResponse> login(
    Session session,
    String email,
    String password, {
    String? deviceId,
  }) async {
    final rateKey = 'login_$email';

    if (_isRateLimited(rateKey)) {
      return LoginResponse(
        success: false,
        error: 'Too many login attempts. Please try again later.',
      );
    }

    try {
      await _ensureSecurityColumns(session);
      await _ensurePatientProfileDobColumn(session);

      final result = await session.db.unsafeQuery(
        '''
      SELECT u.user_id, u.name, u.email, u.password_hash, u.role::text AS role, u.is_active,
              u.phone, p.blood_group, p.date_of_birth, u.profile_picture_url,
             COALESCE(u.require_login_email_otp, FALSE) AS require_login_email_otp,
             COALESCE(u.token_version, 0) AS token_version
      FROM users u
      LEFT JOIN patient_profiles p ON p.user_id = u.user_id
      WHERE u.email = @e
      ''',
        parameters: QueryParameters.named({'e': email}),
      );

      if (result.isEmpty) {
        return LoginResponse(success: false, error: 'User not found');
      }

      final row = result.first.toColumnMap();

      final storedHash = _decodeDbValue(row['password_hash']);
      final hashed = sha256.convert(utf8.encode(password)).toString();

      if (storedHash != hashed) {
        return LoginResponse(success: false, error: 'Invalid password');
      }

      if (row['is_active'] == false) {
        return LoginResponse(
            success: false, error: 'Account deactivated from Admin panel');
      }

      final decodedRole = _decodeDbValue(row['role']).toUpperCase();
      final userId = _decodeDbValue(row['user_id']);

      final userIdInt = int.tryParse(userId);
      final tokenVersion = _decodeDbInt(row['token_version']) ?? 0;
      final requireLoginEmailOtp = (row['require_login_email_otp'] == true);

      final normalizedDeviceId = _normalizeDeviceId(deviceId);
      final deviceHash =
          normalizedDeviceId == null ? null : _hashDeviceId(normalizedDeviceId);

      bool deviceTrusted = false;
      if (userIdInt != null && deviceHash != null) {
        deviceTrusted = await _isDeviceTrusted(
          session,
          userId: userIdInt,
          deviceIdHash: deviceHash,
        );
      }

      final shouldRequireEmailOtp = requireLoginEmailOtp || !deviceTrusted;

      // If device is trusted and user didn't explicitly logout, issue token directly.
      if (!shouldRequireEmailOtp) {
        final token = _issueAuthToken(
          session,
          email: email,
          userId: userId,
          role: decodedRole,
          tokenVersion: tokenVersion,
        );
        if (token == null) {
          return LoginResponse(
            success: false,
            error: 'Server auth is not configured (missing JWT secret).',
          );
        }

        if (userIdInt != null && deviceHash != null) {
          await _upsertTrustedDevice(
            session,
            userId: userIdInt,
            deviceIdHash: deviceHash,
          );
        }

        return LoginResponse(
          success: true,
          role: decodedRole,
          userId: userId,
          userName: _decodeDbValue(row['name']),
          phone: _decodeDbValue(row['phone']),
          bloodGroup: _decodeDbValue(row['blood_group']),
          profilePictureUrl: _decodeDbValue(row['profile_picture_url']),
          token: token,
        );
      }

      // Require OTP only if user explicitly logged out, OR this is a first-time
      // login on this device/browser.
      final challenge = await _createOtpToken(
        session: session,
        purpose: 'login_email',
        email: email,
      );
      if (!challenge.success) {
        return LoginResponse(success: false, error: challenge.error);
      }

      final sent = await _sendOtpWithResend(
        session,
        email,
        challenge.debugOtp!,
        isReset: false,
      );
      if (!sent) {
        return LoginResponse(
          success: false,
          error: 'Failed to send login OTP. Please try again later.',
        );
      }

      session
          .log('Login OTP sent to $email (userId=$userId role=$decodedRole)');
      return LoginResponse(
        success: true,
        requiresEmailOtp: true,
        otpToken: challenge.token,
      );
    } catch (e, stack) {
      session.log('Login failed: $e\n$stack', level: LogLevel.error);
      return LoginResponse(success: false, error: 'Internal server error');
    }
  }

  /// Signup requirement redesign: only phone verification (OTP) during signup.
  /// No email OTP is required here.
  /// Since no SMS API, OTP is returned as debugOtp for UI popup.
  Future<OtpChallengeResponse> startSignupPhoneOtp(
    Session session,
    String email,
    String phone,
  ) async {
    final rateKey = 'startSignupPhoneOtp_$email';
    if (_isRateLimited(rateKey)) {
      return OtpChallengeResponse(
        success: false,
        error: 'Too many attempts. Please wait.',
      );
    }

    final normalizedEmail = email.trim();
    final normalizedPhone = phone.trim();
    if (normalizedEmail.isEmpty || normalizedPhone.isEmpty) {
      return OtpChallengeResponse(
        success: false,
        error: 'Email and phone are required.',
      );
    }

    // Ensure email uniqueness
    try {
      final existingEmail = await session.db.unsafeQuery(
        'SELECT 1 FROM users WHERE email = @e',
        parameters: QueryParameters.named({'e': normalizedEmail}),
      );
      if (existingEmail.isNotEmpty) {
        return OtpChallengeResponse(
          success: false,
          error: 'Email already registered.',
        );
      }
    } catch (_) {}

    // Ensure phone uniqueness
    try {
      final existingPhone = await session.db.unsafeQuery(
        'SELECT 1 FROM users WHERE phone = @ph',
        parameters: QueryParameters.named({'ph': normalizedPhone}),
      );
      if (existingPhone.isNotEmpty) {
        return OtpChallengeResponse(
          success: false,
          error: 'Phone number already registered.',
        );
      }
    } catch (_) {}

    final challenge = await _createOtpToken(
      session: session,
      purpose: 'signup_phone',
      email: normalizedEmail,
      phone: normalizedPhone,
    );
    if (!challenge.success) return challenge;

    session.log(
      'PHONE OTP for signup phone=$normalizedPhone email=$normalizedEmail: ${challenge.debugOtp}',
      level: LogLevel.warning,
    );
    return challenge;
  }

  /// Verify login OTP after password was correct but user required OTP.
  /// Returns a normal LoginResponse containing the session token.
  Future<LoginResponse> verifyLoginOtp(
    Session session,
    String email,
    String otp,
    String otpToken, {
    String? deviceId,
  }) async {
    final rateKey = 'verifyLoginOtp_$email';
    if (_isRateLimited(rateKey)) {
      return LoginResponse(
        success: false,
        error: 'Too many OTP attempts. Please wait.',
      );
    }

    try {
      await _ensureSecurityColumns(session);

      final err = await _validateOtpToken(
        session: session,
        purpose: 'login_email',
        otp: otp,
        token: otpToken,
        email: email,
      );
      if (err != null) return LoginResponse(success: false, error: err);

      final result = await session.db.unsafeQuery(
        '''
        SELECT user_id, name, email, role::text AS role, is_active, phone,
               COALESCE(token_version, 0) AS token_version
        FROM users
        WHERE email = @e
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'e': email}),
      );
      if (result.isEmpty) {
        return LoginResponse(success: false, error: 'User not found');
      }
      final row = result.first.toColumnMap();
      if (row['is_active'] == false) {
        return LoginResponse(
          success: false,
          error: 'Account deactivated from Admin panel',
        );
      }

      final jwtSecret = _jwtSecret(session);
      if (jwtSecret == null) {
        return LoginResponse(
          success: false,
          error: 'Server auth is not configured (missing JWT secret).',
        );
      }

      // Clear OTP requirement now that email OTP is verified.
      await session.db.unsafeExecute(
        'UPDATE users SET require_login_email_otp = FALSE WHERE email = @e',
        parameters: QueryParameters.named({'e': email}),
      );

      final userId = _decodeDbValue(row['user_id']);
      final decodedRole = _decodeDbValue(row['role']).toUpperCase();
      final tokenVersion = _decodeDbInt(row['token_version']) ?? 0;

      final authToken = _issueAuthToken(
        session,
        email: email,
        userId: userId,
        role: decodedRole,
        tokenVersion: tokenVersion,
      );
      if (authToken == null) {
        return LoginResponse(
          success: false,
          error: 'Server auth is not configured (missing JWT secret).',
        );
      }

      final normalizedDeviceId = _normalizeDeviceId(deviceId);
      final userIdInt = int.tryParse(userId);
      if (normalizedDeviceId != null && userIdInt != null) {
        await _upsertTrustedDevice(
          session,
          userId: userIdInt,
          deviceIdHash: _hashDeviceId(normalizedDeviceId),
        );
      }

      return LoginResponse(
        success: true,
        role: decodedRole,
        userId: userId,
        userName: _decodeDbValue(row['name']),
        phone: _decodeDbValue(row['phone']),
        token: authToken,
      );
    } catch (e, st) {
      session.log('verifyLoginOtp failed: $e\n$st', level: LogLevel.error);
      return LoginResponse(success: false, error: 'Internal server error');
    }
  }

  /// Logout: invalidate current JWTs (token_version++) and force email OTP on next login.
  Future<bool> logout(Session session) async {
    try {
      await _ensureSecurityColumns(session);

      final auth = session.authenticated;
      if (auth == null) return false;
      final userId = int.tryParse(auth.userIdentifier);
      if (userId == null) return false;

      await session.db.unsafeExecute(
        '''
        UPDATE users
        SET token_version = COALESCE(token_version, 0) + 1,
            require_login_email_otp = TRUE
        WHERE user_id = @uid
        ''',
        parameters: QueryParameters.named({'uid': userId}),
      );
      return true;
    } catch (e, st) {
      session.log('logout failed: $e\n$st', level: LogLevel.error);
      return false;
    }
  }

  //REGISTER (Generate OTP)
  Future<String> register(Session session, String email, String password,
      String name, String role) async {
    final existing = await session.db.unsafeQuery(
      'SELECT 1 FROM users WHERE email = @email',
      parameters: QueryParameters.named({'email': email}),
    );

    if (existing.isNotEmpty) return 'Email already registered';

    return _sendOtp(session, email, password, name, role);
  }

  // RESEND OTP
  Future<String> resendOtp(Session session, String email, String password,
      String name, String role) async {
    return _sendOtp(session, email, password, name, role);
  }

  //COMMON OTP SENDING LOGIC
  Future<String> _sendOtp(Session session, String email, String password,
      String name, String role) async {
    final jwtSecret = _jwtSecret(session);
    if (jwtSecret == null) {
      return 'Server auth is not configured (missing JWT secret).';
    }
    // Generate OTP and JWT token (expires in 2 minutes)
    final otp = (Random().nextInt(900000) + 100000).toString();
    final jti = _uuid.v4();

    // Build JWT with claims: email, otp, jti
    final jwt = JWT(
      {
        'purpose': 'signup_email',
        'email': email,
        'otp': otp,
        'jti': jti,
      },
      issuer: 'dishari',
      subject: email,
    );

    final token = jwt.sign(SecretKey(jwtSecret), expiresIn: _otpTtl);

    final success = await _sendOtpWithResend(session, email, otp);

    if (success) {
      session.log('OTP $otp sent successfully via Resend to $email');
      // Return the token to the client; client must send it back when verifying
      return token;
    } else {
      return 'Failed to send OTP. Please try again later.';
    }
  }

  /// After signup email OTP verified, start phone verification.
  /// Since no SMS API, OTP is returned as debugOtp for UI popup.
  Future<OtpChallengeResponse> verifySignupEmailAndStartPhoneOtp(
    Session session,
    String email,
    String emailOtp,
    String emailOtpToken,
    String phone,
  ) async {
    final rateKey = 'verifySignupEmail_$email';
    if (_isRateLimited(rateKey)) {
      return OtpChallengeResponse(
        success: false,
        error: 'Too many OTP attempts. Please wait.',
      );
    }

    final err = await _validateOtpToken(
      session: session,
      purpose: 'signup_email',
      otp: emailOtp,
      token: emailOtpToken,
      email: email,
    );
    if (err != null) {
      return OtpChallengeResponse(success: false, error: err);
    }

    final phoneChallenge = await _createOtpToken(
      session: session,
      purpose: 'signup_phone',
      email: email,
      phone: phone,
    );
    if (!phoneChallenge.success) return phoneChallenge;

    // Print on backend (and also return to client for temporary popup).
    session
        .log('PHONE OTP for $phone (email=$email): ${phoneChallenge.debugOtp}');

    return phoneChallenge;
  }

  /// Finalize signup by verifying phone OTP, then creating the user.
  /// Returns LoginResponse with session token (auto-login after signup).
  Future<LoginResponse> completeSignupWithPhoneOtp(
    Session session,
    String email,
    String phone,
    String phoneOtp,
    String phoneOtpToken,
    String password,
    String name,
    String role,
    String? bloodGroup,
    DateTime? dateOfBirth,
  ) async {
    final rateKey = 'completeSignup_$email';
    if (_isRateLimited(rateKey)) {
      return LoginResponse(
        success: false,
        error: 'Too many attempts. Please wait.',
      );
    }

    await _ensureSecurityColumns(session);
    await _ensurePatientProfileDobColumn(session);

    final err = await _validateOtpToken(
      session: session,
      purpose: 'signup_phone',
      otp: phoneOtp,
      token: phoneOtpToken,
      email: email,
      phone: phone,
    );
    if (err != null) return LoginResponse(success: false, error: err);

    // Ensure phone uniqueness
    try {
      if (phone.trim().isNotEmpty) {
        final existingPhone = await session.db.unsafeQuery(
          'SELECT 1 FROM users WHERE phone = @ph',
          parameters: QueryParameters.named({'ph': phone}),
        );
        if (existingPhone.isNotEmpty) {
          return LoginResponse(
            success: false,
            error: 'Registration failed: Phone number already registered.',
          );
        }
      }
    } catch (_) {}

    final hashed = sha256.convert(utf8.encode(password)).toString();

    int? generatedId;
    int tokenVersion = 0;

    try {
      await session.db.unsafeExecute('BEGIN');

      final insertResult = await session.db.unsafeQuery(
        '''
        INSERT INTO users (name, email, password_hash, phone, role, is_active)
        VALUES (@n, @e, @p, @ph, @r::user_role, TRUE)
        RETURNING user_id, COALESCE(token_version, 0) AS token_version
        ''',
        parameters: QueryParameters.named({
          'n': name,
          'e': email,
          'p': hashed,
          'ph': phone,
          'r': role,
        }),
      );

      if (insertResult.isEmpty) {
        await session.db.unsafeExecute('ROLLBACK');
        return LoginResponse(
            success: false, error: 'Database error during account creation.');
      }
      final insertedRow = insertResult.first.toColumnMap();
      generatedId = _decodeDbInt(insertedRow['user_id']);
      tokenVersion = _decodeDbInt(insertedRow['token_version']) ?? 0;
      if (generatedId == null) {
        await session.db.unsafeExecute('ROLLBACK');
        return LoginResponse(
            success: false, error: 'Database error during account creation.');
      }

      if (role == 'STUDENT' || role == 'TEACHER' || role == 'STAFF') {
        await session.db.unsafeExecute(
          '''
          INSERT INTO patient_profiles (user_id, blood_group, date_of_birth)
          VALUES (@uid, @bg, @dob)
          ''',
          parameters: QueryParameters.named({
            'uid': generatedId,
            'bg': bloodGroup,
            'dob': dateOfBirth,
          }),
        );
      }

      await session.db.unsafeExecute('COMMIT');
    } on DatabaseQueryException catch (e) {
      await session.db.unsafeExecute('ROLLBACK');

      final msg = e.message.toLowerCase();
      if (msg.contains('users_phone_key') || msg.contains('phone')) {
        return LoginResponse(
            success: false, error: 'Phone number already exists');
      }
      if (msg.contains('users_email_key') || msg.contains('email')) {
        return LoginResponse(success: false, error: 'Email already exists');
      }

      session.log('Database error during user creation: $e',
          level: LogLevel.error);
      return LoginResponse(
          success: false, error: 'Database error during account creation.');
    } catch (e) {
      await session.db.unsafeExecute('ROLLBACK');
      session.log('Unexpected error: $e', level: LogLevel.error);
      return LoginResponse(
          success: false,
          error: 'An unexpected error occurred during registration.');
    }

    // Auto-login after successful signup.
    final jwtSecret = _jwtSecret(session);
    if (jwtSecret == null) {
      return LoginResponse(
          success: false,
          error: 'Server auth is not configured (missing JWT secret).');
    }

    final authToken = JWT(
      {
        'uid': generatedId!,
        'role': role.toUpperCase(),
        'tv': tokenVersion,
        'jti': _uuid.v4(),
      },
      issuer: 'dishari',
      subject: email,
    ).sign(
      SecretKey(jwtSecret),
      expiresIn: const Duration(days: 30),
    );

    return LoginResponse(
      success: true,
      role: role.toUpperCase(),
      userId: generatedId!.toString(),
      userName: name,
      phone: phone,
      bloodGroup: bloodGroup,
      age: _calculateAgeFromDob(dateOfBirth),
      token: authToken,
    );
  }

  // ---------------- RESEND EMAIL IMPLEMENTATION ----------------
  /// Sends an OTP email using the Resend API. If [isReset] is true,
  /// the email content/subject will be for password reset; otherwise it's for registration.
  Future<bool> _sendOtpWithResend(Session session, String email, String otp,
      {bool isReset = false}) async {
    final resendApiKey = _resendApiKey(session);
    if (resendApiKey == null) {
      session.log('Missing RESEND_API_KEY (or passwords.resendApiKey).',
          level: LogLevel.warning);
      return false;
    }
    // Subject and email body content
    final String subject = isReset
        ? 'NSTU Medical Center Password Reset Code'
        : 'NSTU Medical Center Verification Code';

    final String plainTextBody = isReset
        ? 'Your NSTU Medical Center password reset code is: $otp\n'
            'This code will expire in 2 minutes.\n\n'
            'If you did not request this, you can ignore this email.'
        : 'Your NSTU Medical Center registration code is: $otp\n'
            'This code will expire in 2 minutes.\n\n'
            'If you did not request this, you can ignore this email.';

    final String htmlBody = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>$subject</title>
  </head>
  <body style="font-family: Arial, sans-serif; line-height:1.6; color:#333;">
    <h2 style="color:#1a1a1a;">$subject</h2>
    <p>Hello,</p>
    <p>We received a request to verify your email for NSTU Medical Center.</p>
    <p>Your one-time code is:</p>
    <h1 style="margin:0; font-size:28px; letter-spacing:1.5px;">$otp</h1>
    <p>This code will expire in <strong>2 minutes</strong>.</p>
    <p>Please do not share this code with anyone.</p>
    <p>If you did not request ${isReset ? 'a password reset' : 'this verification'}, you can safely ignore this email.</p>
    <br>
    <p>Thank you,<br>NSTU Medical Center</p>
  </body>
</html>
""";

    // Resend API payload
    const String fromEmail = "NSTU Medical Center <onboarding@sabbir.qzz.io>";

    final Map<String, dynamic> emailData = {
      "from": fromEmail,
      "to": [email],
      "subject": subject,
      // Include both plain text and HTML
      "text": plainTextBody,
      "html": htmlBody,
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Authorization': 'Bearer $resendApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(emailData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        session.log('Email ($subject) sent successfully to $email via Resend',
            level: LogLevel.info);
        return true;
      } else {
        session.log(
            'Resend API Error (${response.statusCode}): ${response.body}',
            level: LogLevel.warning);
        return false;
      }
    } catch (e) {
      session.log('Resend API connection error: $e', level: LogLevel.warning);
      return false;
    }
  }

  /// Public helper: send a welcome email using Resend API. Returns true on success.
  Future<bool> sendWelcomeEmailViaResend(
      Session session, String email, String name) async {
    final resendApiKey = session.passwords['resendApiKey'] ??
        Platform.environment['RESEND_API_KEY'];

    if (resendApiKey == null || resendApiKey.trim().isEmpty) {
      session.log('Missing RESEND_API_KEY', level: LogLevel.warning);
      return false;
    }

    final String subject = 'Welcome to NSTU Medical Center';
    final String mailBody =
        'Hi $name,\n\nYour account has been created. You can log in using your email.';

    const String verifiedFromEmail =
        "Welcome to NSTU Medical Center <onboarding@sabbir.qzz.io>";

    final Map<String, dynamic> emailData = {
      "from": verifiedFromEmail,
      "to": [email],
      "subject": subject,
      "text": mailBody,
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Authorization': 'Bearer $resendApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(emailData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        session.log('Welcome email sent to $email');
        return true;
      } else {
        session.log('Resend error: ${response.body}', level: LogLevel.warning);
        return false;
      }
    } catch (e) {
      session.log('Resend API connection error: $e', level: LogLevel.warning);
      return false;
    }
  }

  // VERIFY OTP
  Future<String> verifyOtp(
    Session session,
    String email,
    String otp,
    String token,
    String password,
    String name,
    String role,
    String? phone,
    String? bloodGroup,
    String? allergies,
  ) async {
    final rateKey = 'verifyOtp_$email';
    if (_isRateLimited(rateKey)) {
      return 'Too many OTP attempts. Please wait.';
    }

    // Backwards-compat: legacy verifyOtp flow (email only) kept for older clients.
    // New clients should use verifySignupEmailAndStartPhoneOtp + completeSignupWithPhoneOtp.
    final err = await _validateOtpToken(
      session: session,
      purpose: 'signup_email',
      otp: otp,
      token: token,
      email: email,
    );
    if (err != null) return err;

    await _ensurePatientProfileDobColumn(session);

    // Ensure phone uniqueness if phone provided
    try {
      if (phone != null && phone.trim().isNotEmpty) {
        final existingPhone = await session.db.unsafeQuery(
          'SELECT 1 FROM users WHERE phone = @ph',
          parameters: QueryParameters.named({'ph': phone}),
        );
        if (existingPhone.isNotEmpty) {
          return 'Registration failed: Phone number already registered.';
        }
      }
    } catch (e) {
      session.log('Phone uniqueness check failed: $e', level: LogLevel.warning);
      // Continue - if DB check fails for unexpected reason, let insertion handle unique constraint
    }

    final hashed = sha256.convert(utf8.encode(password)).toString();
    // final String userId = email; // user_id should be auto-generated by DB

    try {
      // Start a transaction
      await session.db.unsafeExecute('BEGIN');

      // 1. Insert into users table and get generated user_id
      final insertResult = await session.db.unsafeQuery(
        '''
      INSERT INTO users (name, email, password_hash, phone, role, is_active)
      VALUES (@n, @e, @p, @ph, @r::user_role, TRUE)
      RETURNING user_id
      ''',
        parameters: QueryParameters.named({
          'n': name,
          'e': email,
          'p': hashed,
          'ph': phone,
          'r': role,
        }),
      );

      if (insertResult.isEmpty) {
        await session.db.unsafeExecute('ROLLBACK');
        return 'Database error during account creation.';
      }

      final insertedRow = insertResult.first.toColumnMap();
      final dynamic generatedId = insertedRow['user_id'];

      // 2. Insert into patient_profiles table ONLY for STUDENT, TEACHER, STAFF
      if (role == 'STUDENT' || role == 'TEACHER' || role == 'STAFF') {
        await session.db.unsafeExecute(
          '''
        INSERT INTO patient_profiles (user_id, blood_group, date_of_birth)
        VALUES (@uid, @bg, NULL)
        ''',
          parameters: QueryParameters.named({
            'uid': generatedId,
            'bg': bloodGroup,
          }),
        );
      }

      // Commit transaction
      await session.db.unsafeExecute('COMMIT');
    } on DatabaseQueryException catch (e) {
      await session.db.unsafeExecute('ROLLBACK');

      final msg = e.message.toLowerCase();

      if (msg.contains('users_phone_key') || msg.contains('phone')) {
        return 'Phone number already exists';
      }

      if (msg.contains('users_email_key') || msg.contains('email')) {
        return 'Email already exists';
      }

      session.log('Database error during user creation: $e',
          level: LogLevel.error);
      return 'Database error during account creation.';
    } catch (e) {
      await session.db.unsafeExecute('ROLLBACK');
      session.log('Unexpected error: $e', level: LogLevel.error);
      return 'An unexpected error occurred during registration.';
    }

    return 'Account created successfully';
  }

  // ---------------- FORGOT PASSWORD / RESET FLOW ----------------
  /// Request a password reset: generate OTP and JWT token (expires in 2 minutes)
  /// Returns the token if email was sent successfully, otherwise an error message.
  Future<String> requestPasswordReset(Session session, String email) async {
    final rateKey = 'reset_$email';
    if (_isRateLimited(rateKey)) {
      return 'Too many reset requests. Please try later.';
    }

    try {
      // Check if user exists in the database; if not, return explicit "User not found" per request
      final exists = await session.db.unsafeQuery(
        'SELECT 1 FROM users WHERE email = @e',
        parameters: QueryParameters.named({'e': email}),
      );

      if (exists.isEmpty) {
        return 'User not found';
      }

      // Generate OTP and token (even if user does not exist, generate & attempt send to keep timing similar)
      final otp = (Random().nextInt(900000) + 100000).toString();
      final jti = _uuid.v4();

      final jwt = JWT(
        {
          'email': email,
          'otp': otp,
          'jti': jti,
        },
        issuer: 'dishari',
        subject: email,
      );

      final jwtSecret = _jwtSecret(session);
      if (jwtSecret == null) {
        return 'Server auth is not configured (missing JWT secret).';
      }

      final token =
          jwt.sign(SecretKey(jwtSecret), expiresIn: Duration(minutes: 2));

      // Try to send email. If user doesn't exist, _sendOtpWithResend will still be called but not harmful.
      final sent = await _sendOtpWithResend(session, email, otp, isReset: true);

      if (sent) {
        session.log('Password reset OTP $otp sent to $email');
        return token;
      } else {
        return 'Failed to send password reset email. Please try again later.';
      }
    } catch (e, st) {
      session.log('requestPasswordReset failed: $e\n$st',
          level: LogLevel.error);
      return 'Internal server error';
    }
  }

  /// Verify password reset OTP using the client-provided token.
  /// Returns 'OK' on success or an error message on failure.
  Future<String> verifyPasswordReset(
      Session session, String email, String otp, String token) async {
    try {
      final jwtSecret = _jwtSecret(session);
      if (jwtSecret == null) {
        return 'Server auth is not configured (missing JWT secret).';
      }

      final jwt = JWT.verify(token, SecretKey(jwtSecret));
      final payload = jwt.payload;

      if (payload['email'] != email || payload['otp'] != otp) {
        return 'Invalid or expired OTP';
      }

      return 'OK';
    } catch (e) {
      session.log('verifyPasswordReset JWT verification failed: $e',
          level: LogLevel.warning);
      return 'Invalid or expired OTP';
    }
  }

  /// Reset the user's password. Token must be a valid JWT created by requestPasswordReset.
  Future<String> resetPassword(
      Session session, String email, String token, String newPassword) async {
    try {
      final jwtSecret = _jwtSecret(session);
      if (jwtSecret == null) {
        return 'Server auth is not configured (missing JWT secret).';
      }

      final jwt = JWT.verify(token, SecretKey(jwtSecret));
      final payload = jwt.payload;

      if (payload['email'] != email) {
        return 'Invalid token';
      }

      final hashed = sha256.convert(utf8.encode(newPassword)).toString();

      // Update password if user exists
      await session.db.unsafeExecute(
        '''
        UPDATE users SET password_hash = @p WHERE email = @e
        ''',
        parameters: QueryParameters.named({'p': hashed, 'e': email}),
      );

      // unsafeExecute does not return affected rows; do a quick check
      final check = await session.db.unsafeQuery(
        'SELECT 1 FROM users WHERE email = @e',
        parameters: QueryParameters.named({'e': email}),
      );

      if (check.isEmpty) {
        return 'User not found';
      }

      session.log('Password reset successful for $email');
      return 'Password reset successful';
    } catch (e, st) {
      session.log('resetPassword failed: $e\n$st', level: LogLevel.error);
      return 'Internal server error';
    }
  }

  // ---------- Universal Change Password (Logged-in) ----------

  String? _validateNewPassword(String p) {
    final s = p.trim();
    if (s.isEmpty) return 'New password is required';
    if (s.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  /// Universal: all roles can change password with the same rules.
  /// Identifies user by email (same as your login uses email).
  Future<String> changePasswordUniversal(
    Session session,
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (email.trim().isEmpty) return 'Email is required';
      if (currentPassword.trim().isEmpty) return 'Current password is required';

      final err = _validateNewPassword(newPassword);
      if (err != null) return err;

      final result = await session.db.unsafeQuery(
        'SELECT passwordhash FROM users WHERE email = e LIMIT 1',
        parameters: QueryParameters.named({'e': email.trim()}),
      );
      if (result.isEmpty) return 'User not found';

      final row = result.first.toColumnMap();
      final ph = row['passwordhash'];

      String storedHash = '';
      if (ph == null) {
        storedHash = '';
      } else if (ph is List<int>) {
        storedHash = String.fromCharCodes(ph);
      } else {
        storedHash = ph.toString();
      }

      final currHash = sha256.convert(utf8.encode(currentPassword)).toString();
      if (storedHash != currHash) return 'Incorrect current password';

      final newHash = sha256.convert(utf8.encode(newPassword)).toString();
      await session.db.unsafeExecute(
        'UPDATE users SET passwordhash = p WHERE email = e',
        parameters: QueryParameters.named({'p': newHash, 'e': email.trim()}),
      );

      return 'OK';
    } catch (e, st) {
      session.log('changePasswordUniversal failed: $e',
          level: LogLevel.error, stackTrace: st);
      return 'Failed to change password';
    }
  }
}
