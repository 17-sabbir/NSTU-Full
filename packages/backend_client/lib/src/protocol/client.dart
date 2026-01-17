/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:backend_client/src/protocol/otp_challenge_response.dart' as _i3;
import 'package:backend_client/src/protocol/login_response.dart' as _i4;
import 'package:backend_client/src/protocol/dispenser_profile_r.dart' as _i5;
import 'package:backend_client/src/protocol/InventoryItemInfo.dart' as _i6;
import 'package:backend_client/src/protocol/inventory_audit_log.dart' as _i7;
import 'package:backend_client/src/protocol/prescription.dart' as _i8;
import 'package:backend_client/src/protocol/prescription_detail.dart' as _i9;
import 'package:backend_client/src/protocol/dispense_request.dart' as _i10;
import 'package:backend_client/src/protocol/dispense_history_entry.dart'
    as _i11;
import 'package:backend_client/src/protocol/doctor_home_data.dart' as _i12;
import 'package:backend_client/src/protocol/doctor_profile.dart' as _i13;
import 'package:backend_client/src/protocol/PrescribedItem.dart' as _i14;
import 'package:backend_client/src/protocol/patient_external_report.dart'
    as _i15;
import 'package:backend_client/src/protocol/patient_record_list.dart' as _i16;
import 'package:backend_client/src/protocol/patient_record_prescription_details.dart'
    as _i17;
import 'package:backend_client/src/protocol/patient_return_tests.dart' as _i18;
import 'package:backend_client/src/protocol/test_result_create_upload.dart'
    as _i19;
import 'package:backend_client/src/protocol/staff_profile.dart' as _i20;
import 'package:backend_client/src/protocol/lab_today.dart' as _i21;
import 'package:backend_client/src/protocol/lab_ten_history.dart' as _i22;
import 'package:backend_client/src/protocol/notification.dart' as _i23;
import 'package:backend_client/src/protocol/patient_reponse.dart' as _i24;
import 'package:backend_client/src/protocol/patient_report.dart' as _i25;
import 'package:backend_client/src/protocol/prescription_list.dart' as _i26;
import 'package:backend_client/src/protocol/StaffInfo.dart' as _i27;
import 'package:backend_client/src/protocol/ambulance_contact.dart' as _i28;
import 'package:backend_client/src/protocol/onduty_staff.dart' as _i29;
import 'package:backend_client/src/protocol/greeting.dart' as _i30;
import 'protocol.dart' as _i31;

/// {@category Endpoint}
class EndpointAuth extends _i1.EndpointRef {
  EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  /// Sends an OTP to [newEmail] for verifying profile email change.
  /// Requires an authenticated user.
  _i2.Future<_i3.OtpChallengeResponse> requestProfileEmailChangeOtp(
    String newEmail,
  ) => caller.callServerEndpoint<_i3.OtpChallengeResponse>(
    'auth',
    'requestProfileEmailChangeOtp',
    {'newEmail': newEmail},
  );

  /// Verify OTP for profile email change (does not update DB).
  _i2.Future<bool> verifyProfileEmailChangeOtp(
    String newEmail,
    String otp,
    String otpToken,
  ) => caller.callServerEndpoint<bool>(
    'auth',
    'verifyProfileEmailChangeOtp',
    {
      'newEmail': newEmail,
      'otp': otp,
      'otpToken': otpToken,
    },
  );

  /// Update the authenticated user's email, requiring OTP proof.
  /// Also marks `email_otp_verified = TRUE` because the new email was verified.
  _i2.Future<String> updateMyEmailWithOtp(
    String newEmail,
    String otp,
    String otpToken,
  ) => caller.callServerEndpoint<String>(
    'auth',
    'updateMyEmailWithOtp',
    {
      'newEmail': newEmail,
      'otp': otp,
      'otpToken': otpToken,
    },
  );

  _i2.Future<_i4.LoginResponse> login(
    String email,
    String password, {
    String? deviceId,
  }) => caller.callServerEndpoint<_i4.LoginResponse>(
    'auth',
    'login',
    {
      'email': email,
      'password': password,
      'deviceId': deviceId,
    },
  );

  /// Signup requirement redesign: only phone verification (OTP) during signup.
  /// No email OTP is required here.
  /// Since no SMS API, OTP is returned as debugOtp for UI popup.
  _i2.Future<_i3.OtpChallengeResponse> startSignupPhoneOtp(
    String email,
    String phone,
  ) => caller.callServerEndpoint<_i3.OtpChallengeResponse>(
    'auth',
    'startSignupPhoneOtp',
    {
      'email': email,
      'phone': phone,
    },
  );

  /// Verify login OTP after password was correct but user required OTP.
  /// Returns a normal LoginResponse containing the session token.
  _i2.Future<_i4.LoginResponse> verifyLoginOtp(
    String email,
    String otp,
    String otpToken, {
    String? deviceId,
  }) => caller.callServerEndpoint<_i4.LoginResponse>(
    'auth',
    'verifyLoginOtp',
    {
      'email': email,
      'otp': otp,
      'otpToken': otpToken,
      'deviceId': deviceId,
    },
  );

  /// Logout: client should delete its auth token.
  ///
  /// Note: we intentionally do not store per-session token revocation state.
  /// This keeps the DB minimal as requested (only tracks `email_otp_verified`).
  _i2.Future<bool> logout() => caller.callServerEndpoint<bool>(
    'auth',
    'logout',
    {},
  );

  _i2.Future<String> register(
    String email,
    String password,
    String name,
    String role,
  ) => caller.callServerEndpoint<String>(
    'auth',
    'register',
    {
      'email': email,
      'password': password,
      'name': name,
      'role': role,
    },
  );

  _i2.Future<String> resendOtp(
    String email,
    String password,
    String name,
    String role,
  ) => caller.callServerEndpoint<String>(
    'auth',
    'resendOtp',
    {
      'email': email,
      'password': password,
      'name': name,
      'role': role,
    },
  );

  /// After signup email OTP verified, start phone verification.
  /// Since no SMS API, OTP is returned as debugOtp for UI popup.
  _i2.Future<_i3.OtpChallengeResponse> verifySignupEmailAndStartPhoneOtp(
    String email,
    String emailOtp,
    String emailOtpToken,
    String phone,
  ) => caller.callServerEndpoint<_i3.OtpChallengeResponse>(
    'auth',
    'verifySignupEmailAndStartPhoneOtp',
    {
      'email': email,
      'emailOtp': emailOtp,
      'emailOtpToken': emailOtpToken,
      'phone': phone,
    },
  );

  /// Finalize signup by verifying phone OTP, then creating the user.
  /// Returns LoginResponse with session token (auto-login after signup).
  _i2.Future<_i4.LoginResponse> completeSignupWithPhoneOtp(
    String email,
    String phone,
    String phoneOtp,
    String phoneOtpToken,
    String password,
    String name,
    String role,
    String? bloodGroup,
    DateTime? dateOfBirth,
    String? gender,
  ) => caller.callServerEndpoint<_i4.LoginResponse>(
    'auth',
    'completeSignupWithPhoneOtp',
    {
      'email': email,
      'phone': phone,
      'phoneOtp': phoneOtp,
      'phoneOtpToken': phoneOtpToken,
      'password': password,
      'name': name,
      'role': role,
      'bloodGroup': bloodGroup,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    },
  );

  /// Public helper: send a welcome email using Resend API. Returns true on success.
  _i2.Future<bool> sendWelcomeEmailViaResend(
    String email,
    String name,
  ) => caller.callServerEndpoint<bool>(
    'auth',
    'sendWelcomeEmailViaResend',
    {
      'email': email,
      'name': name,
    },
  );

  _i2.Future<String> verifyOtp(
    String email,
    String otp,
    String token,
    String password,
    String name,
    String role,
    String? phone,
    String? bloodGroup,
    String? allergies,
  ) => caller.callServerEndpoint<String>(
    'auth',
    'verifyOtp',
    {
      'email': email,
      'otp': otp,
      'token': token,
      'password': password,
      'name': name,
      'role': role,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
    },
  );

  /// Request a password reset: generate OTP and JWT token (expires in 2 minutes)
  /// Returns the token if email was sent successfully, otherwise an error message.
  _i2.Future<String> requestPasswordReset(String email) =>
      caller.callServerEndpoint<String>(
        'auth',
        'requestPasswordReset',
        {'email': email},
      );

  /// Verify password reset OTP using the client-provided token.
  /// Returns 'OK' on success or an error message on failure.
  _i2.Future<String> verifyPasswordReset(
    String email,
    String otp,
    String token,
  ) => caller.callServerEndpoint<String>(
    'auth',
    'verifyPasswordReset',
    {
      'email': email,
      'otp': otp,
      'token': token,
    },
  );

  /// Reset the user's password. Token must be a valid JWT created by requestPasswordReset.
  _i2.Future<String> resetPassword(
    String email,
    String token,
    String newPassword,
  ) => caller.callServerEndpoint<String>(
    'auth',
    'resetPassword',
    {
      'email': email,
      'token': token,
      'newPassword': newPassword,
    },
  );

  /// Universal: all roles can change password with the same rules.
  /// Identifies user by email (same as your login uses email).
  _i2.Future<String> changePasswordUniversal(
    String email,
    String currentPassword,
    String newPassword,
  ) => caller.callServerEndpoint<String>(
    'auth',
    'changePasswordUniversal',
    {
      'email': email,
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    },
  );
}

/// {@category Endpoint}
class EndpointDispenser extends _i1.EndpointRef {
  EndpointDispenser(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'dispenser';

  _i2.Future<_i5.DispenserProfileR?> getDispenserProfile() =>
      caller.callServerEndpoint<_i5.DispenserProfileR?>(
        'dispenser',
        'getDispenserProfile',
        {},
      );

  /// 2️⃣ Update dispenser profile
  _i2.Future<String> updateDispenserProfile({
    required String name,
    required String phone,
    required String qualification,
    required String designation,
    String? profilePictureUrl,
  }) => caller.callServerEndpoint<String>(
    'dispenser',
    'updateDispenserProfile',
    {
      'name': name,
      'phone': phone,
      'qualification': qualification,
      'designation': designation,
      'profilePictureUrl': profilePictureUrl,
    },
  );

  /// Fetch only inventory items that the dispenser can restock
  _i2.Future<List<_i6.InventoryItemInfo>> listInventoryItems() =>
      caller.callServerEndpoint<List<_i6.InventoryItemInfo>>(
        'dispenser',
        'listInventoryItems',
        {},
      );

  _i2.Future<bool> restockItem({
    required int itemId,
    required int quantity,
  }) => caller.callServerEndpoint<bool>(
    'dispenser',
    'restockItem',
    {
      'itemId': itemId,
      'quantity': quantity,
    },
  );

  _i2.Future<List<_i7.InventoryAuditLog>> getDispenserHistory() =>
      caller.callServerEndpoint<List<_i7.InventoryAuditLog>>(
        'dispenser',
        'getDispenserHistory',
        {},
      );

  /// Fetch all prescriptions that have not yet been dispensed
  /// Fetch pending prescriptions (not dispensed, not outside)
  _i2.Future<List<_i8.Prescription>> getPendingPrescriptions() =>
      caller.callServerEndpoint<List<_i8.Prescription>>(
        'dispenser',
        'getPendingPrescriptions',
        {},
      );

  _i2.Future<_i9.PrescriptionDetail?> getPrescriptionDetail(
    int prescriptionId,
  ) => caller.callServerEndpoint<_i9.PrescriptionDetail?>(
    'dispenser',
    'getPrescriptionDetail',
    {'prescriptionId': prescriptionId},
  );

  _i2.Future<_i6.InventoryItemInfo?> getStockByFirstWord(String medicineName) =>
      caller.callServerEndpoint<_i6.InventoryItemInfo?>(
        'dispenser',
        'getStockByFirstWord',
        {'medicineName': medicineName},
      );

  _i2.Future<List<_i6.InventoryItemInfo>> searchInventoryItems(String query) =>
      caller.callServerEndpoint<List<_i6.InventoryItemInfo>>(
        'dispenser',
        'searchInventoryItems',
        {'query': query},
      );

  /// ডিসপেন্স করার মেইন ট্রানজ্যাকশন (Atomic Transaction)
  _i2.Future<bool> dispensePrescription({
    required int prescriptionId,
    required int dispenserId,
    required List<_i10.DispenseItemRequest> items,
  }) => caller.callServerEndpoint<bool>(
    'dispenser',
    'dispensePrescription',
    {
      'prescriptionId': prescriptionId,
      'dispenserId': dispenserId,
      'items': items,
    },
  );

  /// Detailed dispense history (patient + items) for current dispenser
  _i2.Future<List<_i11.DispenseHistoryEntry>> getDispenserDispenseHistory({
    required int limit,
  }) => caller.callServerEndpoint<List<_i11.DispenseHistoryEntry>>(
    'dispenser',
    'getDispenserDispenseHistory',
    {'limit': limit},
  );
}

/// {@category Endpoint}
class EndpointDoctor extends _i1.EndpointRef {
  EndpointDoctor(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'doctor';

  /// Doctor home dashboard data
  _i2.Future<_i12.DoctorHomeData> getDoctorHomeData() =>
      caller.callServerEndpoint<_i12.DoctorHomeData>(
        'doctor',
        'getDoctorHomeData',
        {},
      );

  _i2.Future<Map<String, String?>> getDoctorInfo() =>
      caller.callServerEndpoint<Map<String, String?>>(
        'doctor',
        'getDoctorInfo',
        {},
      );

  /// ডাক্তারের আইডি দিয়ে তার সই এবং নাম খুঁজে বের করা
  _i2.Future<_i13.DoctorProfile?> getDoctorProfile(int doctorId) =>
      caller.callServerEndpoint<_i13.DoctorProfile?>(
        'doctor',
        'getDoctorProfile',
        {'doctorId': doctorId},
      );

  /// Update doctor's user and staff profile. If staff_profiles row doesn't exist, insert it.
  /// Expects profilePictureUrl and signatureUrl to be remote URLs (uploads happen on frontend).
  _i2.Future<bool> updateDoctorProfile(
    int doctorId,
    String name,
    String email,
    String phone,
    String? profilePictureUrl,
    String? designation,
    String? qualification,
    String? signatureUrl,
  ) => caller.callServerEndpoint<bool>(
    'doctor',
    'updateDoctorProfile',
    {
      'doctorId': doctorId,
      'name': name,
      'email': email,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
      'designation': designation,
      'qualification': qualification,
      'signatureUrl': signatureUrl,
    },
  );

  _i2.Future<Map<String, String?>> getPatientByPhone(String phone) =>
      caller.callServerEndpoint<Map<String, String?>>(
        'doctor',
        'getPatientByPhone',
        {'phone': phone},
      );

  /// নতুন প্রেসক্রিপশন সেভ করা
  _i2.Future<int> createPrescription(
    _i8.Prescription prescription,
    List<_i14.PrescribedItem> items,
    String patientPhone,
  ) => caller.callServerEndpoint<int>(
    'doctor',
    'createPrescription',
    {
      'prescription': prescription,
      'items': items,
      'patientPhone': patientPhone,
    },
  );

  _i2.Future<List<_i15.PatientExternalReport>> getReportsForDoctor(
    int doctorId,
  ) => caller.callServerEndpoint<List<_i15.PatientExternalReport>>(
    'doctor',
    'getReportsForDoctor',
    {'doctorId': doctorId},
  );

  /// Track if a test report was reviewed by the assigned doctor.
  _i2.Future<bool> markReportReviewed(int reportId) =>
      caller.callServerEndpoint<bool>(
        'doctor',
        'markReportReviewed',
        {'reportId': reportId},
      );

  _i2.Future<int> revisePrescription({
    required int originalPrescriptionId,
    required String newAdvice,
    required List<_i14.PrescribedItem> newItems,
  }) => caller.callServerEndpoint<int>(
    'doctor',
    'revisePrescription',
    {
      'originalPrescriptionId': originalPrescriptionId,
      'newAdvice': newAdvice,
      'newItems': newItems,
    },
  );

  /// List page: all prescriptions (latest first) + optional search by name/phone
  _i2.Future<List<_i16.PatientPrescriptionListItem>>
  getPatientPrescriptionList({
    String? query,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_i16.PatientPrescriptionListItem>>(
    'doctor',
    'getPatientPrescriptionList',
    {
      'query': query,
      'limit': limit,
      'offset': offset,
    },
  );

  /// Bottom sheet: single prescription full details + medicines
  _i2.Future<_i17.PatientPrescriptionDetails?> getPrescriptionDetails({
    required int prescriptionId,
  }) => caller.callServerEndpoint<_i17.PatientPrescriptionDetails?>(
    'doctor',
    'getPrescriptionDetails',
    {'prescriptionId': prescriptionId},
  );
}

/// {@category Endpoint}
class EndpointLab extends _i1.EndpointRef {
  EndpointLab(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'lab';

  /// Fetch all lab tests using your raw SQL schema
  _i2.Future<List<_i18.LabTests>> getAllLabTests() =>
      caller.callServerEndpoint<List<_i18.LabTests>>(
        'lab',
        'getAllLabTests',
        {},
      );

  _i2.Future<bool> createTestResult({
    required int testId,
    required String patientName,
    required String mobileNumber,
    required String patientType,
  }) => caller.callServerEndpoint<bool>(
    'lab',
    'createTestResult',
    {
      'testId': testId,
      'patientName': patientName,
      'mobileNumber': mobileNumber,
      'patientType': patientType,
    },
  );

  /// Create a new lab test record
  _i2.Future<bool> createLabTest(_i18.LabTests test) =>
      caller.callServerEndpoint<bool>(
        'lab',
        'createLabTest',
        {'test': test},
      );

  /// Update an existing lab test (Admin style using QueryParameters)
  _i2.Future<bool> updateLabTest(_i18.LabTests test) =>
      caller.callServerEndpoint<bool>(
        'lab',
        'updateLabTest',
        {'test': test},
      );

  /// Dummy SMS sender: logs message to server logs (no real SMS)
  _i2.Future<bool> sendDummySms({
    required String mobileNumber,
    required String message,
  }) => caller.callServerEndpoint<bool>(
    'lab',
    'sendDummySms',
    {
      'mobileNumber': mobileNumber,
      'message': message,
    },
  );

  _i2.Future<bool> submitResult({required int resultId}) =>
      caller.callServerEndpoint<bool>(
        'lab',
        'submitResult',
        {'resultId': resultId},
      );

  /// Submit or resubmit result + dummy SMS notification.
  /// Upload happens on frontend; backend only stores the URL.
  _i2.Future<bool> submitResultWithUrl({
    required int resultId,
    required String attachmentUrl,
  }) => caller.callServerEndpoint<bool>(
    'lab',
    'submitResultWithUrl',
    {
      'resultId': resultId,
      'attachmentUrl': attachmentUrl,
    },
  );

  _i2.Future<List<_i19.TestResult>> getAllTestResults() =>
      caller.callServerEndpoint<List<_i19.TestResult>>(
        'lab',
        'getAllTestResults',
        {},
      );

  /// Fetch Lab Staff profile by userId
  _i2.Future<_i20.StaffProfileDto?> getStaffProfile(int userId) =>
      caller.callServerEndpoint<_i20.StaffProfileDto?>(
        'lab',
        'getStaffProfile',
        {'userId': userId},
      );

  /// Update Staff Profile (Users + Staff_Profiles tables)
  _i2.Future<bool> updateStaffProfile({
    required int userId,
    required String name,
    required String phone,
    required String email,
    required String designation,
    required String qualification,
    String? profilePictureUrl,
  }) => caller.callServerEndpoint<bool>(
    'lab',
    'updateStaffProfile',
    {
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'designation': designation,
      'qualification': qualification,
      'profilePictureUrl': profilePictureUrl,
    },
  );

  _i2.Future<_i21.LabToday> getLabHomeTwoDaySummary() =>
      caller.callServerEndpoint<_i21.LabToday>(
        'lab',
        'getLabHomeTwoDaySummary',
        {},
      );

  _i2.Future<List<_i22.LabTenHistory>> getLast10TestHistory() =>
      caller.callServerEndpoint<List<_i22.LabTenHistory>>(
        'lab',
        'getLast10TestHistory',
        {},
      );
}

/// {@category Endpoint}
class EndpointNotification extends _i1.EndpointRef {
  EndpointNotification(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'notification';

  _i2.Future<bool> createNotification({
    required int userId,
    required String title,
    required String message,
  }) => caller.callServerEndpoint<bool>(
    'notification',
    'createNotification',
    {
      'userId': userId,
      'title': title,
      'message': message,
    },
  );

  _i2.Future<List<_i23.NotificationInfo>> getMyNotifications({
    required int limit,
    required int userId,
  }) => caller.callServerEndpoint<List<_i23.NotificationInfo>>(
    'notification',
    'getMyNotifications',
    {
      'limit': limit,
      'userId': userId,
    },
  );

  _i2.Future<Map<String, int>> getMyNotificationCounts({required int userId}) =>
      caller.callServerEndpoint<Map<String, int>>(
        'notification',
        'getMyNotificationCounts',
        {'userId': userId},
      );

  _i2.Future<_i23.NotificationInfo?> getNotificationById({
    required int notificationId,
    required int userId,
  }) => caller.callServerEndpoint<_i23.NotificationInfo?>(
    'notification',
    'getNotificationById',
    {
      'notificationId': notificationId,
      'userId': userId,
    },
  );

  _i2.Future<bool> markAsRead({
    required int notificationId,
    required int userId,
  }) => caller.callServerEndpoint<bool>(
    'notification',
    'markAsRead',
    {
      'notificationId': notificationId,
      'userId': userId,
    },
  );

  _i2.Future<bool> markAllAsRead({required int userId}) =>
      caller.callServerEndpoint<bool>(
        'notification',
        'markAllAsRead',
        {'userId': userId},
      );
}

/// {@category Endpoint}
class EndpointPassword extends _i1.EndpointRef {
  EndpointPassword(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'password';

  _i2.Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => caller.callServerEndpoint<String>(
    'password',
    'changePassword',
    {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    },
  );
}

/// {@category Endpoint}
class EndpointPatient extends _i1.EndpointRef {
  EndpointPatient(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'patient';

  _i2.Future<_i24.PatientProfile?> getPatientProfile() =>
      caller.callServerEndpoint<_i24.PatientProfile?>(
        'patient',
        'getPatientProfile',
        {},
      );

  /// List lab tests from the `tests` table. Returns a list of maps with keys:
  /// test_name, description, student_fee, teacher_fee, outside_fee, available
  _i2.Future<List<_i18.LabTests>> listTests() =>
      caller.callServerEndpoint<List<_i18.LabTests>>(
        'patient',
        'listTests',
        {},
      );

  /// Return the role of a user (stored as text in users.role) by email/userId.
  /// Returns uppercase role string or empty string if not found.
  _i2.Future<String> getUserRole(int userId) =>
      caller.callServerEndpoint<String>(
        'patient',
        'getUserRole',
        {'userId': userId},
      );

  _i2.Future<String> updatePatientProfile(
    int userId,
    String name,
    String phone,
    String? bloodGroup,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImageUrl,
  ) => caller.callServerEndpoint<String>(
    'patient',
    'updatePatientProfile',
    {
      'userId': userId,
      'name': name,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'profileImageUrl': profileImageUrl,
    },
  );

  /// Fetch logged-in patient's lab reports using phone number
  _i2.Future<List<_i25.PatientReportDto>> getMyLabReports(int userId) =>
      caller.callServerEndpoint<List<_i25.PatientReportDto>>(
        'patient',
        'getMyLabReports',
        {'userId': userId},
      );

  _i2.Future<List<_i26.PrescriptionList>> getMyPrescriptionList(int userId) =>
      caller.callServerEndpoint<List<_i26.PrescriptionList>>(
        'patient',
        'getMyPrescriptionList',
        {'userId': userId},
      );

  _i2.Future<bool> finalizeReportUpload({
    required int patientId,
    required int prescriptionId,
    required String reportType,
    required String fileUrl,
  }) => caller.callServerEndpoint<bool>(
    'patient',
    'finalizeReportUpload',
    {
      'patientId': patientId,
      'prescriptionId': prescriptionId,
      'reportType': reportType,
      'fileUrl': fileUrl,
    },
  );

  _i2.Future<List<_i15.PatientExternalReport>> getMyExternalReports(
    int userId,
  ) => caller.callServerEndpoint<List<_i15.PatientExternalReport>>(
    'patient',
    'getMyExternalReports',
    {'userId': userId},
  );

  /// ১. রোগীর সব প্রেসক্রিপশনের লিস্ট আনা
  _i2.Future<List<_i26.PrescriptionList>> getPrescriptionList(int patientId) =>
      caller.callServerEndpoint<List<_i26.PrescriptionList>>(
        'patient',
        'getPrescriptionList',
        {'patientId': patientId},
      );

  /// সরাসরি Patient ID (User ID) দিয়ে প্রেসক্রিপশন লিস্ট আনা
  _i2.Future<List<_i26.PrescriptionList>> getPrescriptionsByPatientId(
    int patientId,
  ) => caller.callServerEndpoint<List<_i26.PrescriptionList>>(
    'patient',
    'getPrescriptionsByPatientId',
    {'patientId': patientId},
  );

  /// ২. একটি নির্দিষ্ট প্রেসক্রিপশনের বিস্তারিত তথ্য (PDF এর জন্য)
  _i2.Future<_i9.PrescriptionDetail?> getPrescriptionDetail(
    int prescriptionId,
  ) => caller.callServerEndpoint<_i9.PrescriptionDetail?>(
    'patient',
    'getPrescriptionDetail',
    {'prescriptionId': prescriptionId},
  );

  /// Fetch all active medical staff (Admin, Doctor, Dispenser, Labstaff)
  /// Fetch all active medical staff (Admin, Doctor, Dispenser, Labstaff)
  _i2.Future<List<_i27.StaffInfo>> getMedicalStaff() =>
      caller.callServerEndpoint<List<_i27.StaffInfo>>(
        'patient',
        'getMedicalStaff',
        {},
      );

  _i2.Future<List<_i28.AmbulanceContact>> getAmbulanceContacts() =>
      caller.callServerEndpoint<List<_i28.AmbulanceContact>>(
        'patient',
        'getAmbulanceContacts',
        {},
      );

  _i2.Future<List<_i29.OndutyStaff>> getOndutyStaff() =>
      caller.callServerEndpoint<List<_i29.OndutyStaff>>(
        'patient',
        'getOndutyStaff',
        {},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i30.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i30.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i31.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    auth = EndpointAuth(this);
    dispenser = EndpointDispenser(this);
    doctor = EndpointDoctor(this);
    lab = EndpointLab(this);
    notification = EndpointNotification(this);
    password = EndpointPassword(this);
    patient = EndpointPatient(this);
    greeting = EndpointGreeting(this);
  }

  late final EndpointAuth auth;

  late final EndpointDispenser dispenser;

  late final EndpointDoctor doctor;

  late final EndpointLab lab;

  late final EndpointNotification notification;

  late final EndpointPassword password;

  late final EndpointPatient patient;

  late final EndpointGreeting greeting;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'auth': auth,
    'dispenser': dispenser,
    'doctor': doctor,
    'lab': lab,
    'notification': notification,
    'password': password,
    'patient': patient,
    'greeting': greeting,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
