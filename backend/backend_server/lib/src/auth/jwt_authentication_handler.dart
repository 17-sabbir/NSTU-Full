import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:serverpod/serverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

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

  // Fallback to Serverpod's service secret to avoid extra config locally.
  final fromServiceSecret = session.passwords['serviceSecret'];
  if (fromServiceSecret != null && fromServiceSecret.trim().isNotEmpty) {
    return fromServiceSecret.trim();
  }

  return null;
}

/// Auth handler that treats the Serverpod auth key as a signed JWT.
///
/// Expected JWT payload:
/// - `uid`: int (our `users.user_id`)
/// - `tv`: int token version (must match `users.token_version`)
/// - `jti`: string unique id
///
/// This implementation validates against DB state so logout can invalidate tokens.
Future<AuthenticationInfo?> jwtAuthenticationHandler(
  Session session,
  String token,
) async {
  try {
    final secret = _jwtSecret(session);
    if (secret == null) return null;

    final t = token.trim().startsWith('Bearer ')
        ? token.trim().substring('Bearer '.length).trim()
        : token.trim();
    if (t.isEmpty) return null;

    final jwt = JWT.verify(t, SecretKey(secret));

    final uid = jwt.payload['uid'];
    final userId = uid is int ? uid : int.tryParse(uid?.toString() ?? '');
    if (userId == null) return null;

    final tvRaw = jwt.payload['tv'];
    final tokenVersion = tvRaw is int ? tvRaw : int.tryParse('${tvRaw ?? ''}');
    if (tokenVersion == null) return null;

    // Validate user is active and token version matches.
    final rows = await session.db.unsafeQuery(
      'SELECT is_active, token_version FROM users WHERE user_id = @uid LIMIT 1',
      parameters: QueryParameters.named({'uid': userId}),
    );
    if (rows.isEmpty) return null;
    final row = rows.first.toColumnMap();

    final isActive = row['is_active'] == true;
    if (!isActive) return null;

    final dbTv = row['token_version'];
    final dbTokenVersion = dbTv is int ? dbTv : int.tryParse('${dbTv ?? ''}');
    if (dbTokenVersion == null) return null;
    if (dbTokenVersion != tokenVersion) return null;

    final jti = (jwt.payload['jti'] ?? _uuid.v4()).toString();

    return AuthenticationInfo(
      userId.toString(),
      const {},
      authId: jti,
    );
  } catch (_) {
    return null;
  }
}
