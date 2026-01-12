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
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod/protocol.dart' as _i2;
import 'InventoryCategory.dart' as _i3;
import 'InventoryItemInfo.dart' as _i4;
import 'PrescribedItem.dart' as _i5;
import 'StaffInfo.dart' as _i6;
import 'admin_profile.dart' as _i7;
import 'ambulance_contact.dart' as _i8;
import 'audit_entry.dart' as _i9;
import 'dashboard_analytics.dart' as _i10;
import 'dispense_item_detail.dart' as _i11;
import 'dispense_request.dart' as _i12;
import 'dispensed_item_input.dart' as _i13;
import 'dispenser_profile_r.dart' as _i14;
import 'doctor_profile.dart' as _i15;
import 'external_report_file.dart' as _i16;
import 'greeting.dart' as _i17;
import 'inventory_audit_log.dart' as _i18;
import 'inventory_transaction.dart' as _i19;
import 'lab_ten_history.dart' as _i20;
import 'lab_today.dart' as _i21;
import 'login_response.dart' as _i22;
import 'medicine_alternative.dart' as _i23;
import 'medicine_details.dart' as _i24;
import 'notification.dart' as _i25;
import 'onduty_staff.dart' as _i26;
import 'otp_challenge_response.dart' as _i27;
import 'patient_external_report.dart' as _i28;
import 'patient_record_list.dart' as _i29;
import 'patient_record_prescribed_item.dart' as _i30;
import 'patient_record_prescription_details.dart' as _i31;
import 'patient_reponse.dart' as _i32;
import 'patient_report.dart' as _i33;
import 'patient_return_tests.dart' as _i34;
import 'prescription.dart' as _i35;
import 'prescription_detail.dart' as _i36;
import 'prescription_list.dart' as _i37;
import 'report_monthly.dart' as _i38;
import 'report_prescription.dart' as _i39;
import 'report_stock.dart' as _i40;
import 'report_top_medicine.dart' as _i41;
import 'roster_data.dart' as _i42;
import 'roster_lists.dart' as _i43;
import 'roster_user_role.dart' as _i44;
import 'shift_type.dart' as _i45;
import 'staff_profile.dart' as _i46;
import 'test_result_create_upload.dart' as _i47;
import 'user_list_item.dart' as _i48;
import 'package:backend_server/src/generated/user_list_item.dart' as _i49;
import 'package:backend_server/src/generated/roster_data.dart' as _i50;
import 'package:backend_server/src/generated/roster_lists.dart' as _i51;
import 'package:backend_server/src/generated/audit_entry.dart' as _i52;
import 'package:backend_server/src/generated/InventoryCategory.dart' as _i53;
import 'package:backend_server/src/generated/InventoryItemInfo.dart' as _i54;
import 'package:backend_server/src/generated/inventory_transaction.dart'
    as _i55;
import 'package:backend_server/src/generated/inventory_audit_log.dart' as _i56;
import 'package:backend_server/src/generated/prescription.dart' as _i57;
import 'package:backend_server/src/generated/dispense_request.dart' as _i58;
import 'package:backend_server/src/generated/PrescribedItem.dart' as _i59;
import 'package:backend_server/src/generated/patient_external_report.dart'
    as _i60;
import 'package:backend_server/src/generated/patient_record_list.dart' as _i61;
import 'package:backend_server/src/generated/patient_return_tests.dart' as _i62;
import 'package:backend_server/src/generated/test_result_create_upload.dart'
    as _i63;
import 'package:backend_server/src/generated/lab_ten_history.dart' as _i64;
import 'package:backend_server/src/generated/notification.dart' as _i65;
import 'package:backend_server/src/generated/patient_report.dart' as _i66;
import 'package:backend_server/src/generated/prescription_list.dart' as _i67;
import 'package:backend_server/src/generated/StaffInfo.dart' as _i68;
import 'package:backend_server/src/generated/ambulance_contact.dart' as _i69;
import 'package:backend_server/src/generated/onduty_staff.dart' as _i70;
export 'InventoryCategory.dart';
export 'InventoryItemInfo.dart';
export 'PrescribedItem.dart';
export 'StaffInfo.dart';
export 'admin_profile.dart';
export 'ambulance_contact.dart';
export 'audit_entry.dart';
export 'dashboard_analytics.dart';
export 'dispense_item_detail.dart';
export 'dispense_request.dart';
export 'dispensed_item_input.dart';
export 'dispenser_profile_r.dart';
export 'doctor_profile.dart';
export 'external_report_file.dart';
export 'greeting.dart';
export 'inventory_audit_log.dart';
export 'inventory_transaction.dart';
export 'lab_ten_history.dart';
export 'lab_today.dart';
export 'login_response.dart';
export 'medicine_alternative.dart';
export 'medicine_details.dart';
export 'notification.dart';
export 'onduty_staff.dart';
export 'otp_challenge_response.dart';
export 'patient_external_report.dart';
export 'patient_record_list.dart';
export 'patient_record_prescribed_item.dart';
export 'patient_record_prescription_details.dart';
export 'patient_reponse.dart';
export 'patient_report.dart';
export 'patient_return_tests.dart';
export 'prescription.dart';
export 'prescription_detail.dart';
export 'prescription_list.dart';
export 'report_monthly.dart';
export 'report_prescription.dart';
export 'report_stock.dart';
export 'report_top_medicine.dart';
export 'roster_data.dart';
export 'roster_lists.dart';
export 'roster_user_role.dart';
export 'shift_type.dart';
export 'staff_profile.dart';
export 'test_result_create_upload.dart';
export 'user_list_item.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i3.InventoryCategory) {
      return _i3.InventoryCategory.fromJson(data) as T;
    }
    if (t == _i4.InventoryItemInfo) {
      return _i4.InventoryItemInfo.fromJson(data) as T;
    }
    if (t == _i5.PrescribedItem) {
      return _i5.PrescribedItem.fromJson(data) as T;
    }
    if (t == _i6.StaffInfo) {
      return _i6.StaffInfo.fromJson(data) as T;
    }
    if (t == _i7.AdminProfileRespond) {
      return _i7.AdminProfileRespond.fromJson(data) as T;
    }
    if (t == _i8.AmbulanceContact) {
      return _i8.AmbulanceContact.fromJson(data) as T;
    }
    if (t == _i9.AuditEntry) {
      return _i9.AuditEntry.fromJson(data) as T;
    }
    if (t == _i10.DashboardAnalytics) {
      return _i10.DashboardAnalytics.fromJson(data) as T;
    }
    if (t == _i11.DispenseItemDetail) {
      return _i11.DispenseItemDetail.fromJson(data) as T;
    }
    if (t == _i12.DispenseItemRequest) {
      return _i12.DispenseItemRequest.fromJson(data) as T;
    }
    if (t == _i13.DispensedItemInput) {
      return _i13.DispensedItemInput.fromJson(data) as T;
    }
    if (t == _i14.DispenserProfileR) {
      return _i14.DispenserProfileR.fromJson(data) as T;
    }
    if (t == _i15.DoctorProfile) {
      return _i15.DoctorProfile.fromJson(data) as T;
    }
    if (t == _i16.ExternalReportFile) {
      return _i16.ExternalReportFile.fromJson(data) as T;
    }
    if (t == _i17.Greeting) {
      return _i17.Greeting.fromJson(data) as T;
    }
    if (t == _i18.InventoryAuditLog) {
      return _i18.InventoryAuditLog.fromJson(data) as T;
    }
    if (t == _i19.InventoryTransactionInfo) {
      return _i19.InventoryTransactionInfo.fromJson(data) as T;
    }
    if (t == _i20.LabTenHistory) {
      return _i20.LabTenHistory.fromJson(data) as T;
    }
    if (t == _i21.LabToday) {
      return _i21.LabToday.fromJson(data) as T;
    }
    if (t == _i22.LoginResponse) {
      return _i22.LoginResponse.fromJson(data) as T;
    }
    if (t == _i23.MedicineAlternative) {
      return _i23.MedicineAlternative.fromJson(data) as T;
    }
    if (t == _i24.MedicineDetail) {
      return _i24.MedicineDetail.fromJson(data) as T;
    }
    if (t == _i25.NotificationInfo) {
      return _i25.NotificationInfo.fromJson(data) as T;
    }
    if (t == _i26.OndutyStaff) {
      return _i26.OndutyStaff.fromJson(data) as T;
    }
    if (t == _i27.OtpChallengeResponse) {
      return _i27.OtpChallengeResponse.fromJson(data) as T;
    }
    if (t == _i28.PatientExternalReport) {
      return _i28.PatientExternalReport.fromJson(data) as T;
    }
    if (t == _i29.PatientPrescriptionListItem) {
      return _i29.PatientPrescriptionListItem.fromJson(data) as T;
    }
    if (t == _i30.PatientPrescribedItem) {
      return _i30.PatientPrescribedItem.fromJson(data) as T;
    }
    if (t == _i31.PatientPrescriptionDetails) {
      return _i31.PatientPrescriptionDetails.fromJson(data) as T;
    }
    if (t == _i32.PatientProfile) {
      return _i32.PatientProfile.fromJson(data) as T;
    }
    if (t == _i33.PatientReportDto) {
      return _i33.PatientReportDto.fromJson(data) as T;
    }
    if (t == _i34.LabTests) {
      return _i34.LabTests.fromJson(data) as T;
    }
    if (t == _i35.Prescription) {
      return _i35.Prescription.fromJson(data) as T;
    }
    if (t == _i36.PrescriptionDetail) {
      return _i36.PrescriptionDetail.fromJson(data) as T;
    }
    if (t == _i37.PrescriptionList) {
      return _i37.PrescriptionList.fromJson(data) as T;
    }
    if (t == _i38.MonthlyBreakdown) {
      return _i38.MonthlyBreakdown.fromJson(data) as T;
    }
    if (t == _i39.PrescriptionStats) {
      return _i39.PrescriptionStats.fromJson(data) as T;
    }
    if (t == _i40.StockReport) {
      return _i40.StockReport.fromJson(data) as T;
    }
    if (t == _i41.TopMedicine) {
      return _i41.TopMedicine.fromJson(data) as T;
    }
    if (t == _i42.Roster) {
      return _i42.Roster.fromJson(data) as T;
    }
    if (t == _i43.Rosterlists) {
      return _i43.Rosterlists.fromJson(data) as T;
    }
    if (t == _i44.RosterUserRole) {
      return _i44.RosterUserRole.fromJson(data) as T;
    }
    if (t == _i45.ShiftType) {
      return _i45.ShiftType.fromJson(data) as T;
    }
    if (t == _i46.StaffProfileDto) {
      return _i46.StaffProfileDto.fromJson(data) as T;
    }
    if (t == _i47.TestResult) {
      return _i47.TestResult.fromJson(data) as T;
    }
    if (t == _i48.UserListItem) {
      return _i48.UserListItem.fromJson(data) as T;
    }
    if (t == _i1.getType<_i3.InventoryCategory?>()) {
      return (data != null ? _i3.InventoryCategory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.InventoryItemInfo?>()) {
      return (data != null ? _i4.InventoryItemInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.PrescribedItem?>()) {
      return (data != null ? _i5.PrescribedItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.StaffInfo?>()) {
      return (data != null ? _i6.StaffInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.AdminProfileRespond?>()) {
      return (data != null ? _i7.AdminProfileRespond.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.AmbulanceContact?>()) {
      return (data != null ? _i8.AmbulanceContact.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.AuditEntry?>()) {
      return (data != null ? _i9.AuditEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.DashboardAnalytics?>()) {
      return (data != null ? _i10.DashboardAnalytics.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.DispenseItemDetail?>()) {
      return (data != null ? _i11.DispenseItemDetail.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.DispenseItemRequest?>()) {
      return (data != null ? _i12.DispenseItemRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.DispensedItemInput?>()) {
      return (data != null ? _i13.DispensedItemInput.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.DispenserProfileR?>()) {
      return (data != null ? _i14.DispenserProfileR.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.DoctorProfile?>()) {
      return (data != null ? _i15.DoctorProfile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.ExternalReportFile?>()) {
      return (data != null ? _i16.ExternalReportFile.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.Greeting?>()) {
      return (data != null ? _i17.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.InventoryAuditLog?>()) {
      return (data != null ? _i18.InventoryAuditLog.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.InventoryTransactionInfo?>()) {
      return (data != null
              ? _i19.InventoryTransactionInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i20.LabTenHistory?>()) {
      return (data != null ? _i20.LabTenHistory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.LabToday?>()) {
      return (data != null ? _i21.LabToday.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.LoginResponse?>()) {
      return (data != null ? _i22.LoginResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.MedicineAlternative?>()) {
      return (data != null ? _i23.MedicineAlternative.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i24.MedicineDetail?>()) {
      return (data != null ? _i24.MedicineDetail.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.NotificationInfo?>()) {
      return (data != null ? _i25.NotificationInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.OndutyStaff?>()) {
      return (data != null ? _i26.OndutyStaff.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.OtpChallengeResponse?>()) {
      return (data != null ? _i27.OtpChallengeResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.PatientExternalReport?>()) {
      return (data != null ? _i28.PatientExternalReport.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i29.PatientPrescriptionListItem?>()) {
      return (data != null
              ? _i29.PatientPrescriptionListItem.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i30.PatientPrescribedItem?>()) {
      return (data != null ? _i30.PatientPrescribedItem.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i31.PatientPrescriptionDetails?>()) {
      return (data != null
              ? _i31.PatientPrescriptionDetails.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i32.PatientProfile?>()) {
      return (data != null ? _i32.PatientProfile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.PatientReportDto?>()) {
      return (data != null ? _i33.PatientReportDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.LabTests?>()) {
      return (data != null ? _i34.LabTests.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.Prescription?>()) {
      return (data != null ? _i35.Prescription.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.PrescriptionDetail?>()) {
      return (data != null ? _i36.PrescriptionDetail.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i37.PrescriptionList?>()) {
      return (data != null ? _i37.PrescriptionList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.MonthlyBreakdown?>()) {
      return (data != null ? _i38.MonthlyBreakdown.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.PrescriptionStats?>()) {
      return (data != null ? _i39.PrescriptionStats.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.StockReport?>()) {
      return (data != null ? _i40.StockReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.TopMedicine?>()) {
      return (data != null ? _i41.TopMedicine.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i42.Roster?>()) {
      return (data != null ? _i42.Roster.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.Rosterlists?>()) {
      return (data != null ? _i43.Rosterlists.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.RosterUserRole?>()) {
      return (data != null ? _i44.RosterUserRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.ShiftType?>()) {
      return (data != null ? _i45.ShiftType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.StaffProfileDto?>()) {
      return (data != null ? _i46.StaffProfileDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i47.TestResult?>()) {
      return (data != null ? _i47.TestResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i48.UserListItem?>()) {
      return (data != null ? _i48.UserListItem.fromJson(data) : null) as T;
    }
    if (t == List<_i38.MonthlyBreakdown>) {
      return (data as List)
              .map((e) => deserialize<_i38.MonthlyBreakdown>(e))
              .toList()
          as T;
    }
    if (t == List<_i41.TopMedicine>) {
      return (data as List)
              .map((e) => deserialize<_i41.TopMedicine>(e))
              .toList()
          as T;
    }
    if (t == List<_i40.StockReport>) {
      return (data as List)
              .map((e) => deserialize<_i40.StockReport>(e))
              .toList()
          as T;
    }
    if (t == List<_i30.PatientPrescribedItem>) {
      return (data as List)
              .map((e) => deserialize<_i30.PatientPrescribedItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i5.PrescribedItem>) {
      return (data as List)
              .map((e) => deserialize<_i5.PrescribedItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i49.UserListItem>) {
      return (data as List)
              .map((e) => deserialize<_i49.UserListItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i50.Roster>) {
      return (data as List).map((e) => deserialize<_i50.Roster>(e)).toList()
          as T;
    }
    if (t == List<_i51.Rosterlists>) {
      return (data as List)
              .map((e) => deserialize<_i51.Rosterlists>(e))
              .toList()
          as T;
    }
    if (t == List<_i52.AuditEntry>) {
      return (data as List).map((e) => deserialize<_i52.AuditEntry>(e)).toList()
          as T;
    }
    if (t == List<_i53.InventoryCategory>) {
      return (data as List)
              .map((e) => deserialize<_i53.InventoryCategory>(e))
              .toList()
          as T;
    }
    if (t == List<_i54.InventoryItemInfo>) {
      return (data as List)
              .map((e) => deserialize<_i54.InventoryItemInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i55.InventoryTransactionInfo>) {
      return (data as List)
              .map((e) => deserialize<_i55.InventoryTransactionInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i56.InventoryAuditLog>) {
      return (data as List)
              .map((e) => deserialize<_i56.InventoryAuditLog>(e))
              .toList()
          as T;
    }
    if (t == List<_i57.Prescription>) {
      return (data as List)
              .map((e) => deserialize<_i57.Prescription>(e))
              .toList()
          as T;
    }
    if (t == List<_i58.DispenseItemRequest>) {
      return (data as List)
              .map((e) => deserialize<_i58.DispenseItemRequest>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String?>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String?>(v)),
          )
          as T;
    }
    if (t == List<_i59.PrescribedItem>) {
      return (data as List)
              .map((e) => deserialize<_i59.PrescribedItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i60.PatientExternalReport>) {
      return (data as List)
              .map((e) => deserialize<_i60.PatientExternalReport>(e))
              .toList()
          as T;
    }
    if (t == List<_i61.PatientPrescriptionListItem>) {
      return (data as List)
              .map((e) => deserialize<_i61.PatientPrescriptionListItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i62.LabTests>) {
      return (data as List).map((e) => deserialize<_i62.LabTests>(e)).toList()
          as T;
    }
    if (t == List<_i63.TestResult>) {
      return (data as List).map((e) => deserialize<_i63.TestResult>(e)).toList()
          as T;
    }
    if (t == List<_i64.LabTenHistory>) {
      return (data as List)
              .map((e) => deserialize<_i64.LabTenHistory>(e))
              .toList()
          as T;
    }
    if (t == List<_i65.NotificationInfo>) {
      return (data as List)
              .map((e) => deserialize<_i65.NotificationInfo>(e))
              .toList()
          as T;
    }
    if (t == Map<String, int>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<int>(v)),
          )
          as T;
    }
    if (t == List<_i66.PatientReportDto>) {
      return (data as List)
              .map((e) => deserialize<_i66.PatientReportDto>(e))
              .toList()
          as T;
    }
    if (t == List<_i67.PrescriptionList>) {
      return (data as List)
              .map((e) => deserialize<_i67.PrescriptionList>(e))
              .toList()
          as T;
    }
    if (t == List<_i68.StaffInfo>) {
      return (data as List).map((e) => deserialize<_i68.StaffInfo>(e)).toList()
          as T;
    }
    if (t == List<_i69.AmbulanceContact>) {
      return (data as List)
              .map((e) => deserialize<_i69.AmbulanceContact>(e))
              .toList()
          as T;
    }
    if (t == List<_i70.OndutyStaff>) {
      return (data as List)
              .map((e) => deserialize<_i70.OndutyStaff>(e))
              .toList()
          as T;
    }
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i3.InventoryCategory => 'InventoryCategory',
      _i4.InventoryItemInfo => 'InventoryItemInfo',
      _i5.PrescribedItem => 'PrescribedItem',
      _i6.StaffInfo => 'StaffInfo',
      _i7.AdminProfileRespond => 'AdminProfileRespond',
      _i8.AmbulanceContact => 'AmbulanceContact',
      _i9.AuditEntry => 'AuditEntry',
      _i10.DashboardAnalytics => 'DashboardAnalytics',
      _i11.DispenseItemDetail => 'DispenseItemDetail',
      _i12.DispenseItemRequest => 'DispenseItemRequest',
      _i13.DispensedItemInput => 'DispensedItemInput',
      _i14.DispenserProfileR => 'DispenserProfileR',
      _i15.DoctorProfile => 'DoctorProfile',
      _i16.ExternalReportFile => 'ExternalReportFile',
      _i17.Greeting => 'Greeting',
      _i18.InventoryAuditLog => 'InventoryAuditLog',
      _i19.InventoryTransactionInfo => 'InventoryTransactionInfo',
      _i20.LabTenHistory => 'LabTenHistory',
      _i21.LabToday => 'LabToday',
      _i22.LoginResponse => 'LoginResponse',
      _i23.MedicineAlternative => 'MedicineAlternative',
      _i24.MedicineDetail => 'MedicineDetail',
      _i25.NotificationInfo => 'NotificationInfo',
      _i26.OndutyStaff => 'OndutyStaff',
      _i27.OtpChallengeResponse => 'OtpChallengeResponse',
      _i28.PatientExternalReport => 'PatientExternalReport',
      _i29.PatientPrescriptionListItem => 'PatientPrescriptionListItem',
      _i30.PatientPrescribedItem => 'PatientPrescribedItem',
      _i31.PatientPrescriptionDetails => 'PatientPrescriptionDetails',
      _i32.PatientProfile => 'PatientProfile',
      _i33.PatientReportDto => 'PatientReportDto',
      _i34.LabTests => 'LabTests',
      _i35.Prescription => 'Prescription',
      _i36.PrescriptionDetail => 'PrescriptionDetail',
      _i37.PrescriptionList => 'PrescriptionList',
      _i38.MonthlyBreakdown => 'MonthlyBreakdown',
      _i39.PrescriptionStats => 'PrescriptionStats',
      _i40.StockReport => 'StockReport',
      _i41.TopMedicine => 'TopMedicine',
      _i42.Roster => 'Roster',
      _i43.Rosterlists => 'Rosterlists',
      _i44.RosterUserRole => 'RosterUserRole',
      _i45.ShiftType => 'ShiftType',
      _i46.StaffProfileDto => 'StaffProfileDto',
      _i47.TestResult => 'TestResult',
      _i48.UserListItem => 'UserListItem',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('backend.', '');
    }

    switch (data) {
      case _i3.InventoryCategory():
        return 'InventoryCategory';
      case _i4.InventoryItemInfo():
        return 'InventoryItemInfo';
      case _i5.PrescribedItem():
        return 'PrescribedItem';
      case _i6.StaffInfo():
        return 'StaffInfo';
      case _i7.AdminProfileRespond():
        return 'AdminProfileRespond';
      case _i8.AmbulanceContact():
        return 'AmbulanceContact';
      case _i9.AuditEntry():
        return 'AuditEntry';
      case _i10.DashboardAnalytics():
        return 'DashboardAnalytics';
      case _i11.DispenseItemDetail():
        return 'DispenseItemDetail';
      case _i12.DispenseItemRequest():
        return 'DispenseItemRequest';
      case _i13.DispensedItemInput():
        return 'DispensedItemInput';
      case _i14.DispenserProfileR():
        return 'DispenserProfileR';
      case _i15.DoctorProfile():
        return 'DoctorProfile';
      case _i16.ExternalReportFile():
        return 'ExternalReportFile';
      case _i17.Greeting():
        return 'Greeting';
      case _i18.InventoryAuditLog():
        return 'InventoryAuditLog';
      case _i19.InventoryTransactionInfo():
        return 'InventoryTransactionInfo';
      case _i20.LabTenHistory():
        return 'LabTenHistory';
      case _i21.LabToday():
        return 'LabToday';
      case _i22.LoginResponse():
        return 'LoginResponse';
      case _i23.MedicineAlternative():
        return 'MedicineAlternative';
      case _i24.MedicineDetail():
        return 'MedicineDetail';
      case _i25.NotificationInfo():
        return 'NotificationInfo';
      case _i26.OndutyStaff():
        return 'OndutyStaff';
      case _i27.OtpChallengeResponse():
        return 'OtpChallengeResponse';
      case _i28.PatientExternalReport():
        return 'PatientExternalReport';
      case _i29.PatientPrescriptionListItem():
        return 'PatientPrescriptionListItem';
      case _i30.PatientPrescribedItem():
        return 'PatientPrescribedItem';
      case _i31.PatientPrescriptionDetails():
        return 'PatientPrescriptionDetails';
      case _i32.PatientProfile():
        return 'PatientProfile';
      case _i33.PatientReportDto():
        return 'PatientReportDto';
      case _i34.LabTests():
        return 'LabTests';
      case _i35.Prescription():
        return 'Prescription';
      case _i36.PrescriptionDetail():
        return 'PrescriptionDetail';
      case _i37.PrescriptionList():
        return 'PrescriptionList';
      case _i38.MonthlyBreakdown():
        return 'MonthlyBreakdown';
      case _i39.PrescriptionStats():
        return 'PrescriptionStats';
      case _i40.StockReport():
        return 'StockReport';
      case _i41.TopMedicine():
        return 'TopMedicine';
      case _i42.Roster():
        return 'Roster';
      case _i43.Rosterlists():
        return 'Rosterlists';
      case _i44.RosterUserRole():
        return 'RosterUserRole';
      case _i45.ShiftType():
        return 'ShiftType';
      case _i46.StaffProfileDto():
        return 'StaffProfileDto';
      case _i47.TestResult():
        return 'TestResult';
      case _i48.UserListItem():
        return 'UserListItem';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'InventoryCategory') {
      return deserialize<_i3.InventoryCategory>(data['data']);
    }
    if (dataClassName == 'InventoryItemInfo') {
      return deserialize<_i4.InventoryItemInfo>(data['data']);
    }
    if (dataClassName == 'PrescribedItem') {
      return deserialize<_i5.PrescribedItem>(data['data']);
    }
    if (dataClassName == 'StaffInfo') {
      return deserialize<_i6.StaffInfo>(data['data']);
    }
    if (dataClassName == 'AdminProfileRespond') {
      return deserialize<_i7.AdminProfileRespond>(data['data']);
    }
    if (dataClassName == 'AmbulanceContact') {
      return deserialize<_i8.AmbulanceContact>(data['data']);
    }
    if (dataClassName == 'AuditEntry') {
      return deserialize<_i9.AuditEntry>(data['data']);
    }
    if (dataClassName == 'DashboardAnalytics') {
      return deserialize<_i10.DashboardAnalytics>(data['data']);
    }
    if (dataClassName == 'DispenseItemDetail') {
      return deserialize<_i11.DispenseItemDetail>(data['data']);
    }
    if (dataClassName == 'DispenseItemRequest') {
      return deserialize<_i12.DispenseItemRequest>(data['data']);
    }
    if (dataClassName == 'DispensedItemInput') {
      return deserialize<_i13.DispensedItemInput>(data['data']);
    }
    if (dataClassName == 'DispenserProfileR') {
      return deserialize<_i14.DispenserProfileR>(data['data']);
    }
    if (dataClassName == 'DoctorProfile') {
      return deserialize<_i15.DoctorProfile>(data['data']);
    }
    if (dataClassName == 'ExternalReportFile') {
      return deserialize<_i16.ExternalReportFile>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i17.Greeting>(data['data']);
    }
    if (dataClassName == 'InventoryAuditLog') {
      return deserialize<_i18.InventoryAuditLog>(data['data']);
    }
    if (dataClassName == 'InventoryTransactionInfo') {
      return deserialize<_i19.InventoryTransactionInfo>(data['data']);
    }
    if (dataClassName == 'LabTenHistory') {
      return deserialize<_i20.LabTenHistory>(data['data']);
    }
    if (dataClassName == 'LabToday') {
      return deserialize<_i21.LabToday>(data['data']);
    }
    if (dataClassName == 'LoginResponse') {
      return deserialize<_i22.LoginResponse>(data['data']);
    }
    if (dataClassName == 'MedicineAlternative') {
      return deserialize<_i23.MedicineAlternative>(data['data']);
    }
    if (dataClassName == 'MedicineDetail') {
      return deserialize<_i24.MedicineDetail>(data['data']);
    }
    if (dataClassName == 'NotificationInfo') {
      return deserialize<_i25.NotificationInfo>(data['data']);
    }
    if (dataClassName == 'OndutyStaff') {
      return deserialize<_i26.OndutyStaff>(data['data']);
    }
    if (dataClassName == 'OtpChallengeResponse') {
      return deserialize<_i27.OtpChallengeResponse>(data['data']);
    }
    if (dataClassName == 'PatientExternalReport') {
      return deserialize<_i28.PatientExternalReport>(data['data']);
    }
    if (dataClassName == 'PatientPrescriptionListItem') {
      return deserialize<_i29.PatientPrescriptionListItem>(data['data']);
    }
    if (dataClassName == 'PatientPrescribedItem') {
      return deserialize<_i30.PatientPrescribedItem>(data['data']);
    }
    if (dataClassName == 'PatientPrescriptionDetails') {
      return deserialize<_i31.PatientPrescriptionDetails>(data['data']);
    }
    if (dataClassName == 'PatientProfile') {
      return deserialize<_i32.PatientProfile>(data['data']);
    }
    if (dataClassName == 'PatientReportDto') {
      return deserialize<_i33.PatientReportDto>(data['data']);
    }
    if (dataClassName == 'LabTests') {
      return deserialize<_i34.LabTests>(data['data']);
    }
    if (dataClassName == 'Prescription') {
      return deserialize<_i35.Prescription>(data['data']);
    }
    if (dataClassName == 'PrescriptionDetail') {
      return deserialize<_i36.PrescriptionDetail>(data['data']);
    }
    if (dataClassName == 'PrescriptionList') {
      return deserialize<_i37.PrescriptionList>(data['data']);
    }
    if (dataClassName == 'MonthlyBreakdown') {
      return deserialize<_i38.MonthlyBreakdown>(data['data']);
    }
    if (dataClassName == 'PrescriptionStats') {
      return deserialize<_i39.PrescriptionStats>(data['data']);
    }
    if (dataClassName == 'StockReport') {
      return deserialize<_i40.StockReport>(data['data']);
    }
    if (dataClassName == 'TopMedicine') {
      return deserialize<_i41.TopMedicine>(data['data']);
    }
    if (dataClassName == 'Roster') {
      return deserialize<_i42.Roster>(data['data']);
    }
    if (dataClassName == 'Rosterlists') {
      return deserialize<_i43.Rosterlists>(data['data']);
    }
    if (dataClassName == 'RosterUserRole') {
      return deserialize<_i44.RosterUserRole>(data['data']);
    }
    if (dataClassName == 'ShiftType') {
      return deserialize<_i45.ShiftType>(data['data']);
    }
    if (dataClassName == 'StaffProfileDto') {
      return deserialize<_i46.StaffProfileDto>(data['data']);
    }
    if (dataClassName == 'TestResult') {
      return deserialize<_i47.TestResult>(data['data']);
    }
    if (dataClassName == 'UserListItem') {
      return deserialize<_i48.UserListItem>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'backend';
}
