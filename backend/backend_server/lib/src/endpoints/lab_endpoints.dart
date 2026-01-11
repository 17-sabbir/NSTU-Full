import 'package:serverpod/serverpod.dart';
import 'package:backend_server/src/generated/protocol.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'cloudinary_upload.dart';

class LabEndpoint extends Endpoint {
  /// Fetch all lab tests using your raw SQL schema
  Future<List<LabTests>> getAllLabTests(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        '''SELECT test_id, test_name, description, student_fee, teacher_fee, outside_fee, available 
           FROM lab_tests 
           ORDER BY test_name ASC''',
      );

      return result.map((r) {
        final row = r.toColumnMap();

        return LabTests(
          id: row['test_id'] as int?, // Ekhon eti constructor-e kaj korbe
          testName: _safeString(row['test_name']),
          description: _safeString(row['description']),
          studentFee: _toDouble(row['student_fee']),
          teacherFee: _toDouble(row['teacher_fee']),
          outsideFee: _toDouble(row['outside_fee']),
          available: row['available'] as bool? ?? true,
        );
      }).toList();
    } catch (e, stackTrace) {
      session.log('Error fetching lab tests: $e',
          level: LogLevel.error, stackTrace: stackTrace);
      return [];
    }
  }
  //result upload er jonnne user er test create
  Future<bool> createTestResult(
      Session session, {
        required int testId,
        required String patientName,
        required String mobileNumber,
        String patientType = 'STUDENT',
      }) async {
    try {
      await session.db.unsafeExecute(
        '''
      INSERT INTO test_results 
      (test_id, patient_name, mobile_number, patient_type)
      VALUES (@testId, @patientName, @mobile, @patientType)
      ''',
        parameters: QueryParameters.named({
          'testId': testId,
          'patientName': patientName,
          'mobile': mobileNumber,
          'patientType': patientType,
        }),
      );
      return true;
    } catch (e, st) {
      session.log('Create test result failed: $e',
          level: LogLevel.error, stackTrace: st);
      return false;
    }
  }

  /// Create a new lab test record
  Future<bool> createLabTest(Session session, LabTests test) async {
    try {
      await session.db.unsafeExecute(
        '''INSERT INTO lab_tests (test_name, description, student_fee, teacher_fee, outside_fee, available)
           VALUES (@testName, @description, @studentFee, @teacherFee, @outsideFee, @available)''',
        parameters: QueryParameters.named({
          'testName': test.testName,
          'description': test.description,
          'studentFee': test.studentFee,
          'teacherFee': test.teacherFee,
          'outsideFee': test.outsideFee,
          'available': test.available,
        }),
      );
      return true;
    } catch (e, stackTrace) {
      session.log('Error creating lab test: $e',
          level: LogLevel.error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Update an existing lab test (Admin style using QueryParameters)
  Future<bool> updateLabTest(Session session, LabTests test) async {
    if (test.id == null) return false;
    try {
      // AdminEndpoints-er moto unsafeExecute ebong QueryParameters use kora hoyeche
      await session.db.unsafeExecute(
        '''UPDATE lab_tests 
           SET test_name = @testName, 
               description = @description, 
               student_fee = @studentFee, 
               teacher_fee = @teacherFee, 
               outside_fee = @outsideFee, 
               available = @available
           WHERE test_id = @id''',
        parameters: QueryParameters.named({
          'id': test.id,
          'testName': test.testName,
          'description': test.description,
          'studentFee': test.studentFee,
          'teacherFee': test.teacherFee,
          'outsideFee': test.outsideFee,
          'available': test.available,
        }),
      );
      return true;
    } catch (e, stackTrace) {
      session.log('Error updating lab test: $e',
          level: LogLevel.error, stackTrace: stackTrace);
      return false;
    }
  }



  /// Uploads lab result (PDF or Image) to Cloudinary and updates DB
  Future<String?> attachResultFileCloudinary(
      Session session, {
        required int resultId,
        required String base64Data,
        required String fileName,
      }) async {
    try {
      // ফাইল এক্সটেনশন চেক করে PDF কি না তা নির্ধারণ করা
      final bool isPdf = fileName.toLowerCase().endsWith('.pdf');

      // CloudinaryUpload ক্লাস ব্যবহার করে আপলোড
      final String? secureUrl = await CloudinaryUpload.uploadFile(
        base64Data: base64Data,
        folder: 'lab_reports',
        isPdf: isPdf,
      );

      if (secureUrl == null) {
        session.log('Cloudinary upload returned null', level: LogLevel.error);
        return null;
      }

      // ডাটাবেসে অনলাইন URL আপডেট করা
      await session.db.unsafeExecute(
        '''
        UPDATE test_results
        SET is_uploaded = TRUE,
            attachment_path = @url
        WHERE result_id = @id
        ''',
        parameters: QueryParameters.named({
          'id': resultId,
          'url': secureUrl,
        }),
      );

      return secureUrl;
    } catch (e, st) {
      session.log('Attach file to Cloudinary failed: $e',
          level: LogLevel.error, stackTrace: st);
      return null;
    }
  }


  /// Dummy SMS sender: logs message to server logs (no real SMS)
  Future<bool> sendDummySms(Session session,
      {required String mobileNumber, required String message}) async {
    // simulate sending delay
    await Future.delayed(const Duration(milliseconds: 500));

    print('We sent a SMS TO: $mobileNumber');
    print('Message: $message');
    return true;
  }
//submit result

  Future<bool> submitResult(
    Session session, {
    required int resultId,
  }) async {
    try {
      await session.db.unsafeExecute(
        '''
      UPDATE test_results
      SET submitted_at = NOW()
      WHERE result_id = @id
      ''',
        parameters: QueryParameters.named({
          'id': resultId,
        }),
      );
      return true;
    } catch (e, st) {
      session.log('Submit result failed: $e',
          level: LogLevel.error, stackTrace: st);
      return false;
    }
  }

  /// Submit or resubmit result + dummy SMS notification
  /// Submit result: upload file to Cloudinary, save URL and timestamp
  Future<bool> submitResultWithFile(
      Session session, {
        required int resultId,
        required String base64Data,
        required String fileName,
      }) async {
    try {
      // Upload file to Cloudinary
      final bool isPdf = fileName.toLowerCase().endsWith('.pdf');
      final String? secureUrl = await CloudinaryUpload.uploadFile(
        base64Data: base64Data,
        folder: 'lab_reports',
        isPdf: isPdf,
      );

      if (secureUrl == null) {
        session.log('Cloudinary upload failed', level: LogLevel.error);
        return false;
      }

      // Save URL and timestamp in DB
      await session.db.unsafeExecute(
        '''
      UPDATE test_results
      SET attachment_path = @url,
          is_uploaded = TRUE,
          submitted_at = NOW()
      WHERE result_id = @id
      ''',
        parameters: QueryParameters.named({
          'id': resultId,
          'url': secureUrl,
        }),
      );

      // Optionally, send SMS
      final rows = await session.db.unsafeQuery(
        'SELECT patient_name, mobile_number FROM test_results WHERE result_id = @id',
        parameters: QueryParameters.named({'id': resultId}),
      );

      if (rows.isNotEmpty) {
        final m = rows.first.toColumnMap();
        final name = m['patient_name']?.toString() ?? 'Patient';
        final mobile = m['mobile_number']?.toString() ?? '';
        final message = 'প্রিয় $name, আপনার lab result submit হয়েছে।';
        await sendDummySms(session, mobileNumber: mobile, message: message);
      }

      return true;
    } catch (e, st) {
      session.log('Submit with file failed: $e', level: LogLevel.error, stackTrace: st);
      return false;
    }
  }


//Fetch all results (list screen)
  Future<List<TestResult>> getAllTestResults(Session session) async {
    try {
      final rows = await session.db.unsafeQuery(
        '''
      SELECT * FROM test_results
      ORDER BY created_at DESC
      ''',
      );

      return rows.map((r) {
        final m = r.toColumnMap();
        return TestResult(
          resultId: m['result_id'] as int,
          testId: m['test_id'] as int,
          patientName: _safeString(m['patient_name']),
          mobileNumber: _safeString(m['mobile_number']),
          patientType: _safeString(m['patient_type']),
          isUploaded: (m['is_uploaded'] as bool?) ?? false,
          attachmentPath: m['attachment_path'] as String?,
          submittedAt: m['submitted_at'] as DateTime?,
          createdAt: m['created_at'] as DateTime?,
        );
      }).toList();
    } catch (e, st) {
      session.log('Fetch results failed: $e',
          level: LogLevel.error, stackTrace: st);
      return [];
    }
  }


  /// Fetch Lab Staff profile by userId
  Future<StaffProfileDto?> getStaffProfile(Session session, int userId) async {
    try {
      final result = await session.db.unsafeQuery(
        '''
        SELECT 
          u.name, 
          u.email, 
          u.phone, 
          u.profile_picture_url,
          s.designation, 
          s.qualification
        FROM users u
        LEFT JOIN staff_profiles s ON s.user_id = u.user_id
        WHERE u.user_id = @userId LIMIT 1
        ''',
        parameters: QueryParameters.named({'userId': userId}),
      );

      if (result.isEmpty) return null;

      final row = result.first.toColumnMap();

      return StaffProfileDto(
        name: _safeString(row['name']),
        email: _safeString(row['email']),
        phone: _safeString(row['phone']),
        designation: _safeString(row['designation']),
        qualification: _safeString(row['qualification']),
        profilePictureUrl: row['profile_picture_url'] as String?,
      );
    } catch (e, stack) {
      session.log('Error fetching staff profile: $e', level: LogLevel.error, stackTrace: stack);
      return null;
    }
  }

  /// Update Staff Profile (Users + Staff_Profiles tables)
  Future<bool> updateStaffProfile(
      Session session, {
        required int userId,
        required String name,
        required String phone,
        required String email,
        required String designation,
        required String qualification,
        String? profilePictureUrl,
      }) async {
    try {
      return await session.db.transaction((transaction) async {
        // 1. Update Core User Info
        await session.db.unsafeExecute(
          '''
          UPDATE users 
          SET name = @name, 
              phone = @phone,
              email = @email,
              profile_picture_url = COALESCE(@url, profile_picture_url)
          WHERE user_id = @id
          ''',
          parameters: QueryParameters.named({
            'id': userId,
            'name': name,
            'phone': phone,
            'email': email,
            'url': profilePictureUrl,
          }),
        );

        // 2. Upsert Staff Specific Info
        await session.db.unsafeExecute(
          '''
          INSERT INTO staff_profiles (user_id, designation, qualification)
          VALUES (@id, @des, @qual)
          ON CONFLICT (user_id)
          DO UPDATE SET 
            designation = EXCLUDED.designation,
            qualification = EXCLUDED.qualification
          ''',
          parameters: QueryParameters.named({
            'id': userId,
            'des': designation,
            'qual': qualification,
          }),
        );

        return true;
      });
    } catch (e, stack) {
      session.log('Failed to update staff profile: $e', level: LogLevel.error, stackTrace: stack);
      return false;
    }
  }

  /// স্টাফ প্রোফাইল ইমেজ আপলোড
  Future<String?> uploadProfileImage(
      Session session,
      String base64Data,
      ) async {
    // সরাসরি ক্লাউডিনারি সার্ভিস কল
    return await CloudinaryUpload.uploadFile(
      base64Data: base64Data,
      folder: 'staff_profiles',
      isPdf: false,
    );
  }


  // --- Type Safety Helpers ---

  String _safeString(dynamic value) {
    if (value == null) return '';

    try {
      // ✅ handles UndecodedBytes WITHOUT referencing the type
      if (value.runtimeType.toString() == 'UndecodedBytes') {
        final bytes = (value as dynamic).bytes as List<int>;
        return utf8.decode(bytes);
      }

      if (value is Uint8List) {
        return utf8.decode(value);
      }

      if (value is Iterable<int>) {
        return utf8.decode(value.toList());
      }
    } catch (_) {
      // ignore decode errors
    }
    return value.toString();
  }

  Future<LabToday> getLabHomeTwoDaySummary(Session session) async {
    final todayRows = await session.db.unsafeQuery(r'''
    SELECT
      COUNT(*)::int AS total,
      SUM(CASE WHEN is_uploaded = FALSE THEN 1 ELSE 0 END)::int AS pending_uploads,
      SUM(CASE WHEN submitted_at IS NOT NULL THEN 1 ELSE 0 END)::int AS submitted
    FROM test_results
    WHERE created_at::date = CURRENT_DATE
  ''');

    final yesterdayRows = await session.db.unsafeQuery(r'''
    SELECT
      COUNT(*)::int AS total,
      SUM(CASE WHEN is_uploaded = FALSE THEN 1 ELSE 0 END)::int AS pending_uploads,
      SUM(CASE WHEN submitted_at IS NOT NULL THEN 1 ELSE 0 END)::int AS submitted
    FROM test_results
    WHERE created_at::date = (CURRENT_DATE - INTERVAL '1 day')::date
  ''');

    final t = todayRows.isNotEmpty ? todayRows.first.toColumnMap() : <String, dynamic>{};
    final y = yesterdayRows.isNotEmpty ? yesterdayRows.first.toColumnMap() : <String, dynamic>{};

    return LabToday(
      todayTotal: (t['total'] as int?) ?? 0,
      todayPendingUploads: (t['pending_uploads'] as int?) ?? 0,
      todaySubmitted: (t['submitted'] as int?) ?? 0,
      yesterdayTotal: (y['total'] as int?) ?? 0,
      yesterdayPendingUploads: (y['pending_uploads'] as int?) ?? 0,
      yesterdaySubmitted: (y['submitted'] as int?) ?? 0,
    );
  }

  Future<List<LabTenHistory>> getLast10TestHistory(Session session) async {
    final rows = await session.db.unsafeQuery(r'''
    SELECT
      tr.result_id,
      tr.test_id,
      lt.test_name,
      tr.patient_name,
      tr.mobile_number,
      tr.is_uploaded,
      tr.submitted_at,
      tr.created_at
    FROM test_results tr
    LEFT JOIN lab_tests lt ON lt.test_id = tr.test_id
    ORDER BY tr.created_at DESC
    LIMIT 10
  ''');

    return rows.map((r) {
      final m = r.toColumnMap();
      return LabTenHistory(
        resultId: m['result_id'] as int,
        testId: m['test_id'] as int,
        testName: m['test_name']?.toString(),
        patientName: (m['patient_name']?.toString() ?? ''),
        mobileNumber: (m['mobile_number']?.toString() ?? ''),
        isUploaded: (m['is_uploaded'] as bool?) ?? false,
        submittedAt: m['submitted_at'] as DateTime?,
        createdAt: m['created_at'] as DateTime?,
      );
    }).toList();
  }


  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    // PostgreSQL NUMERIC often comes back as a String or double via the driver
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
