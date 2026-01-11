import 'dart:convert';
import 'package:backend_server/src/endpoints/cloudinary_upload.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class DoctorEndpoint extends Endpoint {


  /// ডাক্তারের আইডি দিয়ে তার সই এবং নাম খুঁজে বের করা
  Future<Map<String, String?>> getDoctorInfo(
      Session session,int doctorId) async {
    try {
      final res = await session.db.unsafeQuery('''
        SELECT u.name, s.signature_url 
        FROM users u 
        JOIN staff_profiles s ON u.user_id = s.user_id 
        WHERE u.user_id = @id
      ''', parameters: QueryParameters.named({'id': doctorId}));

      if (res.isEmpty) return {'name': '', 'signature': ''};
      final row = res.first.toColumnMap();
      return {
        'name': _decode(row['name']),
        'signature': _decode(row['signature_url']),
      };
    } catch (e) {
      return {'name': '', 'signature': ''};
    }
  }

  // হেল্পার: ডাটাবেস থেকে আসা টেক্সট ডিকোড করতে
  String _decode(dynamic v) {
    if (v == null) return '';
    if (v is List<int>) return String.fromCharCodes(v);
    return v.toString();
  }

  /// ডাক্তারের আইডি দিয়ে তার সই এবং নাম খুঁজে বের করা
  Future<DoctorProfile?> getDoctorProfile(
      Session session,int doctorId
      ) async {
    try {
      final res = await session.db.unsafeQuery('''
      SELECT u.user_id, u.name, u.email, u.phone, u.profile_picture_url,
             s.designation, s.qualification, s.signature_url
      FROM users u
      LEFT JOIN staff_profiles s ON u.user_id = s.user_id
      WHERE u.user_id = @id
      LIMIT 1
    ''', parameters: QueryParameters.named({'id': doctorId}));

      if (res.isEmpty) return null;

      final row = res.first.toColumnMap();

      return DoctorProfile(
        userId: row['user_id'] as int?,
        name: _decode(row['name']),
        email: _decode(row['email']),
        phone: _decode(row['phone']),
        profilePictureUrl: _decode(row['profile_picture_url']),
        designation: _decode(row['designation']),
        qualification: _decode(row['qualification']),
        signatureUrl: _decode(row['signature_url']),
      );
    } catch (e, st) {
      session.log(
        'getDoctorProfile failed: $e',
        level: LogLevel.error,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Update doctor's user and staff profile. If staff_profiles row doesn't exist, insert it.
  /// Allows profilePictureUrl and signatureUrl to be either a remote URL or a base64/data URL.
  Future<bool> updateDoctorProfile(
      Session session,
      int doctorId,
      String name,
      String email,
      String phone,
      String? profilePictureUrl,
      String? designation,
      String? qualification,
      String? signatureUrl,
      ) async {
    try {

      // Pre-check for duplicate phone (different user)
      final dup = await session.db.unsafeQuery(
        'SELECT 1 FROM users WHERE phone = @ph AND user_id <> @id LIMIT 1',
        parameters:
        QueryParameters.named({'ph': phone, 'id': doctorId}),
      );

      if (dup.isNotEmpty) {
        // Return a clear error to client by throwing - client will receive the message
        throw Exception('Phone number already registered');
      }

      // If the provided profilePictureUrl or signatureUrl are base64/data URIs, upload them server-side.
      String? finalProfileUrl = profilePictureUrl;
      String? finalSignatureUrl = signatureUrl;

      // Helper to decode base64/data-uri to bytes
      List<int>? decodeBase64(String? data) {
        if (data == null) return null;
        var s = data.trim();
        if (s.isEmpty) return null;
        // If it looks like a URL, not base64
        if (s.startsWith('http://') || s.startsWith('https://')) return null;
        // Remove data:image/...;base64, prefix if present
        if (s.contains(',')) s = s.split(',').last;
        s = s.replaceAll(RegExp(r"\s+"), '');
        try {
          return base64.decode(s);
        } catch (e) {
          return null;
        }
      }

      final profileBytes = decodeBase64(profilePictureUrl);
      final sigBytes = decodeBase64(signatureUrl);

      // Upload before transaction so we don't hold DB locks during network IO
      if (profileBytes != null) {
        if (profileBytes.length > 2 * 1024 * 1024) {
          return false; // too large
        }
        finalProfileUrl = await CloudinaryUpload.uploadFile(
            base64Data: ' profileBytes', folder: 'doctor_signatures');
        if (finalProfileUrl == null) return false;
      }

      if (sigBytes != null) {
        if (sigBytes.length > 2 * 1024 * 1024) {
          return false;
        }
        finalSignatureUrl = await CloudinaryUpload.uploadFile(
            base64Data: 'sigBytes', folder: 'doctor_signatures');

        if (finalSignatureUrl == null) return false;
      }

      await session.db.unsafeExecute('BEGIN');

      // Update users table (name, phone, profile picture)
      await session.db.unsafeExecute('''
        UPDATE users
        SET name = @name,email = @email, phone = @phone, profile_picture_url = COALESCE(@pp, profile_picture_url)
        WHERE user_id = @id
      ''',
          parameters: QueryParameters.named({
            'name': name,
            'email': email.trim(),
            'phone': phone,
            'pp': finalProfileUrl,
            'id': doctorId
          }));

      // Check if staff_profiles exists
      final exists = await session.db.unsafeQuery(
          'SELECT 1 FROM staff_profiles WHERE user_id = @id',
          parameters: QueryParameters.named({'id': doctorId}));

      if (exists.isEmpty) {
        // insert
        await session.db.unsafeExecute('''
          INSERT INTO staff_profiles (user_id, designation, qualification, signature_url)
          VALUES (@id, @spec, @qual, @sig)
        ''',
            parameters: QueryParameters.named({
              'id': doctorId,
              'spec': designation,
              'qual': qualification,
              'sig': finalSignatureUrl
            }));
      } else {
        await session.db.unsafeExecute('''
          UPDATE staff_profiles
          SET designation = @spec, qualification = @qual, signature_url = COALESCE(@sig, signature_url)
          WHERE user_id = @id
        ''',
            parameters: QueryParameters.named({
              'spec': designation,
              'qual': qualification,
              'sig': finalSignatureUrl,
              'id': doctorId
            }));
      }

      await session.db.unsafeExecute('COMMIT');
      return true;
    } catch (e, st) {
      await session.db.unsafeExecute('ROLLBACK');
      session.log('updateDoctorProfile failed: $e',
          level: LogLevel.error, stackTrace: st);
      return false;
    }
  }

  Future<Map<String, String?>> getPatientByPhone(
      Session session, String phone) async {
    try {
      // Extract last 11 digits only
      final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
      final last11 = cleaned.length >= 11
          ? cleaned.substring(cleaned.length - 11)
          : cleaned;

      session.log('Searching for patient with last 11 digits: $last11',
          level: LogLevel.info);

      // Search: phone ends with last 11 digits
      final res = await session.db.unsafeQuery(
        '''SELECT user_id, name FROM users 
         WHERE phone IS NOT NULL 
         AND (
           REPLACE(REPLACE(phone, ' ', ''), '-', '') LIKE @pattern
           OR RIGHT(REPLACE(REPLACE(phone, ' ', ''), '-', ''), 11) = @num
         )
         LIMIT 1''',
        parameters: QueryParameters.named({
          'pattern': '%$last11',  // Ends with last11
          'num': last11,           // Exact last 11
        }),
      );

      if (res.isEmpty) {
        session.log('Patient not found with phone: $phone (last11: $last11)',
            level: LogLevel.warning);
        return {'id': null, 'name': null};
      }

      final row = res.first.toColumnMap();
      final userId = row['user_id']?.toString();
      final name = decode(row['name']);

      session.log('Patient found: ID=$userId, Name=$name',
          level: LogLevel.info);

      return {
        'id': userId,
        'name': name,
      };
    } catch (e) {
      session.log('Error in getPatientByPhone: $e', level: LogLevel.error);
      return {'id': null, 'name': null};
    }
  }


  /// নতুন প্রেসক্রিপশন সেভ করা
  Future<int> createPrescription(
      Session session,
      Prescription prescription,
      List<PrescribedItem> items,
      String patientPhone,
      ) async {
    try {

      // FIXED QUERY: Joining with 'users' because 'phone' isn't in 'patient_profiles'
      // createPrescription মেথডের ভেতরে এই অংশটুকু পরিবর্তন করতে পারেন:
      final patientData = await getPatientByPhone(session, patientPhone);

      int? foundPatientId;
      if (patientData['id'] != null) {
        foundPatientId = int.tryParse(patientData['id']!);
      }

      await session.db.unsafeExecute('BEGIN');

      // Insert prescription - Matches your SQL Table
      final res = await session.db.unsafeQuery('''
    INSERT INTO prescriptions (
      patient_id, doctor_id, name, age, mobile_number, gender,
      prescription_date, cc, oe, advice, test, next_visit, is_outside
    ) VALUES (
      @pid, @did, @name, @age, @mobile, @gender,
      @pdate, @cc, @oe, @advice, @test, @nextVisit, @iso
    ) RETURNING prescription_id
    ''',
          parameters: QueryParameters.named({
            'pid': foundPatientId,
            'did': prescription.doctorId,
            'name': prescription.name,
            'age': prescription.age,
            'mobile': prescription.mobileNumber,
            'gender': prescription.gender,
            'pdate': prescription.prescriptionDate ?? DateTime.now(),
            'cc': prescription.cc,
            'oe': prescription.oe,
            'advice': prescription.advice,
            'test': prescription.test,
            'nextVisit': prescription.nextVisit,
            'iso': prescription.isOutside ?? false,
          }));

      if (res.isEmpty) {
        await session.db.unsafeExecute('ROLLBACK');
        return -1;
      }

      final prescriptionId = res.first.toColumnMap()['prescription_id'] as int;

      // Insert prescribed items
      for (var item in items) {
        await session.db.unsafeExecute('''
      INSERT INTO prescribed_items (
        prescription_id, medicine_name, dosage_times, meal_timing, duration
      ) VALUES (@preId, @mname, @dtimes, @mtiming, @dur)
      ''',
            parameters: QueryParameters.named({
              'preId': prescriptionId,
              'mname': item.medicineName,
              'dtimes': item.dosageTimes,
              'mtiming': item.mealTiming,
              'dur': item.duration, // Ensure this is passed as an int
            }));
      }

      await session.db.unsafeExecute('COMMIT');
      return prescriptionId;
    } catch (e, st) {
      await session.db.unsafeExecute('ROLLBACK');
      session.log('createPrescription failed: $e',
          level: LogLevel.error, stackTrace: st);
      return -1;
    }
  }

  // ডাক্তারের কাছে আসা রিপোর্টগুলো দেখার জন্য
  Future<List<PatientExternalReport>> getReportsForDoctor(Session session,int doctorId) async {
    try {
      final res = await session.db.unsafeQuery('''
      SELECT * FROM UploadpatientR 
      WHERE prescribed_doctor_id = @id 
      ORDER BY created_at DESC
    ''', parameters: QueryParameters.named({'id': doctorId}));

      return res.map((row) {
        final map = row.toColumnMap();
        return PatientExternalReport(
          reportId: map['report_id'] as int?,
          patientId: map['patient_id'] as int,
          type: map['type'] as String,
          reportDate: map['report_date'] as DateTime,
          filePath: map['file_path'] as String,
          prescribedDoctorId: map['prescribed_doctor_id'] as int,
          prescriptionId: map['prescription_id'] as int?,
          uploadedBy: map['uploaded_by'] as int,
          createdAt: map['created_at'] as DateTime?,
        );
      }).toList();
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }

//update Prescription
  Future<int> revisePrescription(
      Session session, {
        required int originalPrescriptionId,
        required String newAdvice,
        required List<PrescribedItem> newItems,
      }) async {
    try {
      await session.db.unsafeExecute('BEGIN');

      // ১. পুরনো প্রেসক্রিপশনের তথ্য কপি করা
      final oldPres = await session.db.unsafeQuery(
          'SELECT * FROM prescriptions WHERE prescription_id = @id',
          parameters: QueryParameters.named({'id': originalPrescriptionId})
      );
      if (oldPres.isEmpty) return -1;
      final pData = oldPres.first.toColumnMap();

      // ২. নতুন (Revised) প্রেসক্রিপশন তৈরি
      final res = await session.db.unsafeQuery('''
      INSERT INTO prescriptions (
        patient_id, doctor_id, name, age, mobile_number, gender,
        cc, oe, advice, test, revised_from_id
      ) VALUES (
        @pid, @did, @name, @age, @mobile, @gender,
        @cc, @oe, @advice, @test, @revisedId
      ) RETURNING prescription_id
    ''', parameters: QueryParameters.named({
        'pid': pData['patient_id'],
        'did': pData['doctor_id'],
        'name': pData['name'],
        'age': pData['age'],
        'mobile': pData['mobile_number'],
        'gender': pData['gender'],
        'cc': pData['cc'],
        'oe': pData['oe'],
        'advice': newAdvice,
        'test': pData['test'],
        'revisedId': originalPrescriptionId,
      }));

      final newId = res.first.toColumnMap()['prescription_id'] as int;

      // ৩. নতুন ওষুধগুলো যোগ করা
      for (var item in newItems) {
        await session.db.unsafeExecute('''
        INSERT INTO prescribed_items (prescription_id, medicine_name, dosage_times, meal_timing, duration)
        VALUES (@preId, @mname, @dtimes, @mtiming, @dur)
      ''', parameters: QueryParameters.named({
          'preId': newId,
          'mname': item.medicineName,
          'dtimes': item.dosageTimes,
          'mtiming': item.mealTiming,
          'dur': item.duration,
        }));
      }

      // ৪. পেশেন্টকে নোটিফিকেশন পাঠানো
      await session.db.unsafeExecute('''
      INSERT INTO notifications (user_id, title, message, is_read)
      VALUES (@pId, 'Prescription Updated', 'Your doctor has updated your prescription after reviewing your report.', false)
    ''', parameters: QueryParameters.named({'pId': pData['patient_id']}));

      await session.db.unsafeExecute('COMMIT');
      return newId;
    } catch (e) {
      await session.db.unsafeExecute('ROLLBACK');
      return -1;
    }
  }


  /// List page: all prescriptions (latest first) + optional search by name/phone
  Future<List<PatientPrescriptionListItem>> getPatientPrescriptionList(
      Session session, {
        String? query,
        int limit = 100,
        int offset = 0,
      }) async {
    final q = (query ?? '').trim();

    final rows = await session.db.unsafeQuery(r'''
      SELECT
        prescription_id,
        name,
        mobile_number,
        gender,
        age,
        prescription_date
      FROM prescriptions
      WHERE
        (@q = '' OR
         LOWER(name) LIKE LOWER(@likeQ) OR
         REPLACE(REPLACE(mobile_number, ' ', ''), '-', '') LIKE @phoneLike)
      ORDER BY prescription_id DESC
      LIMIT @limit OFFSET @offset
    ''', parameters: QueryParameters.named({
      'q': q,
      'likeQ': '%$q%',
      'phoneLike': '%${q.replaceAll(RegExp(r'[^0-9]'), '')}%',
      'limit': limit,
      'offset': offset,
    }));

    return rows.map((r) {
      final m = r.toColumnMap();
      return PatientPrescriptionListItem(
        prescriptionId: m['prescription_id'] as int,
        name: _s(m['name']),
        mobileNumber: m['mobile_number']?.toString(),
        gender: m['gender']?.toString(),
        age: m['age'] as int?,
        prescriptionDate: m['prescription_date'] as DateTime?,
      );
    }).toList();
  }

  /// Bottom sheet: single prescription full details + medicines
  Future<PatientPrescriptionDetails?> getPrescriptionDetails(
      Session session, {
        required int prescriptionId,
      }) async {
    final presRows = await session.db.unsafeQuery(r'''
      SELECT
        prescription_id,
        name,
        mobile_number,
        gender,
        age,
        cc,
        oe,
        advice,
        test
      FROM prescriptions
      WHERE prescription_id = @id
      LIMIT 1
    ''', parameters: QueryParameters.named({'id': prescriptionId}));

    if (presRows.isEmpty) return null;

    final p = presRows.first.toColumnMap();

    final itemRows = await session.db.unsafeQuery(r'''
      SELECT medicine_name, dosage_times, meal_timing, duration
      FROM prescribed_items
      WHERE prescription_id = @id
      ORDER BY item_id ASC
    ''', parameters: QueryParameters.named({'id': prescriptionId}));

    final items = itemRows.map((r) {
      final m = r.toColumnMap();
      return PatientPrescribedItem(
        medicineName: _s(m['medicine_name']),
        dosageTimes: _s(m['dosage_times']),
        mealTiming: _s(m['meal_timing']),
        duration: m['duration'] as int?,
      );
    }).toList();

    return PatientPrescriptionDetails(
      prescriptionId: p['prescription_id'] as int,
      name: _s(p['name']),
      mobileNumber: p['mobile_number']?.toString(),
      gender: p['gender']?.toString(),
      age: p['age'] as int?,
      cc: p['cc']?.toString(),
      oe: p['oe']?.toString(),
      advice: p['advice']?.toString(),
      test: p['test']?.toString(),
      items: items,
    );
  }
  String decode(dynamic v) {
    if (v == null) return '';
    if (v is List<int>) return String.fromCharCodes(v);
    return v.toString();
  }
  String _s(dynamic v) {
    if (v == null) return '';
    if (v is List<int>) return String.fromCharCodes(v);
    return v.toString();
  }


}
