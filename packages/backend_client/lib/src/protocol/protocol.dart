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
import 'InventoryCategory.dart' as _i2;
import 'InventoryItemInfo.dart' as _i3;
import 'PrescribedItem.dart' as _i4;
import 'StaffInfo.dart' as _i5;
import 'admin_profile.dart' as _i6;
import 'ambulance_contact.dart' as _i7;
import 'audit_entry.dart' as _i8;
import 'dashboard_analytics.dart' as _i9;
import 'dispense_item_detail.dart' as _i10;
import 'dispense_request.dart' as _i11;
import 'dispensed_item_input.dart' as _i12;
import 'dispenser_profile_r.dart' as _i13;
import 'doctor_profile.dart' as _i14;
import 'external_report_file.dart' as _i15;
import 'greeting.dart' as _i16;
import 'inventory_audit_log.dart' as _i17;
import 'inventory_transaction.dart' as _i18;
import 'lab_ten_history.dart' as _i19;
import 'lab_today.dart' as _i20;
import 'login_response.dart' as _i21;
import 'medicine_alternative.dart' as _i22;
import 'medicine_details.dart' as _i23;
import 'notification.dart' as _i24;
import 'onduty_staff.dart' as _i25;
import 'patient_external_report.dart' as _i26;
import 'patient_record_list.dart' as _i27;
import 'patient_record_prescribed_item.dart' as _i28;
import 'patient_record_prescription_details.dart' as _i29;
import 'patient_reponse.dart' as _i30;
import 'patient_report.dart' as _i31;
import 'patient_return_tests.dart' as _i32;
import 'prescription.dart' as _i33;
import 'prescription_detail.dart' as _i34;
import 'prescription_list.dart' as _i35;
import 'report_monthly.dart' as _i36;
import 'report_prescription.dart' as _i37;
import 'report_stock.dart' as _i38;
import 'report_top_medicine.dart' as _i39;
import 'roster_data.dart' as _i40;
import 'roster_lists.dart' as _i41;
import 'roster_user_role.dart' as _i42;
import 'shift_type.dart' as _i43;
import 'staff_profile.dart' as _i44;
import 'test_result_create_upload.dart' as _i45;
import 'user_list_item.dart' as _i46;
import 'package:backend_client/src/protocol/user_list_item.dart' as _i47;
import 'package:backend_client/src/protocol/roster_data.dart' as _i48;
import 'package:backend_client/src/protocol/roster_lists.dart' as _i49;
import 'package:backend_client/src/protocol/audit_entry.dart' as _i50;
import 'package:backend_client/src/protocol/InventoryCategory.dart' as _i51;
import 'package:backend_client/src/protocol/InventoryItemInfo.dart' as _i52;
import 'package:backend_client/src/protocol/inventory_transaction.dart' as _i53;
import 'package:backend_client/src/protocol/inventory_audit_log.dart' as _i54;
import 'package:backend_client/src/protocol/prescription.dart' as _i55;
import 'package:backend_client/src/protocol/dispense_request.dart' as _i56;
import 'package:backend_client/src/protocol/PrescribedItem.dart' as _i57;
import 'package:backend_client/src/protocol/patient_external_report.dart'
    as _i58;
import 'package:backend_client/src/protocol/patient_record_list.dart' as _i59;
import 'package:backend_client/src/protocol/patient_return_tests.dart' as _i60;
import 'package:backend_client/src/protocol/test_result_create_upload.dart'
    as _i61;
import 'package:backend_client/src/protocol/lab_ten_history.dart' as _i62;
import 'package:backend_client/src/protocol/notification.dart' as _i63;
import 'package:backend_client/src/protocol/patient_report.dart' as _i64;
import 'package:backend_client/src/protocol/prescription_list.dart' as _i65;
import 'package:backend_client/src/protocol/StaffInfo.dart' as _i66;
import 'package:backend_client/src/protocol/ambulance_contact.dart' as _i67;
import 'package:backend_client/src/protocol/onduty_staff.dart' as _i68;
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
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

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

    if (t == _i2.InventoryCategory) {
      return _i2.InventoryCategory.fromJson(data) as T;
    }
    if (t == _i3.InventoryItemInfo) {
      return _i3.InventoryItemInfo.fromJson(data) as T;
    }
    if (t == _i4.PrescribedItem) {
      return _i4.PrescribedItem.fromJson(data) as T;
    }
    if (t == _i5.StaffInfo) {
      return _i5.StaffInfo.fromJson(data) as T;
    }
    if (t == _i6.AdminProfileRespond) {
      return _i6.AdminProfileRespond.fromJson(data) as T;
    }
    if (t == _i7.AmbulanceContact) {
      return _i7.AmbulanceContact.fromJson(data) as T;
    }
    if (t == _i8.AuditEntry) {
      return _i8.AuditEntry.fromJson(data) as T;
    }
    if (t == _i9.DashboardAnalytics) {
      return _i9.DashboardAnalytics.fromJson(data) as T;
    }
    if (t == _i10.DispenseItemDetail) {
      return _i10.DispenseItemDetail.fromJson(data) as T;
    }
    if (t == _i11.DispenseItemRequest) {
      return _i11.DispenseItemRequest.fromJson(data) as T;
    }
    if (t == _i12.DispensedItemInput) {
      return _i12.DispensedItemInput.fromJson(data) as T;
    }
    if (t == _i13.DispenserProfileR) {
      return _i13.DispenserProfileR.fromJson(data) as T;
    }
    if (t == _i14.DoctorProfile) {
      return _i14.DoctorProfile.fromJson(data) as T;
    }
    if (t == _i15.ExternalReportFile) {
      return _i15.ExternalReportFile.fromJson(data) as T;
    }
    if (t == _i16.Greeting) {
      return _i16.Greeting.fromJson(data) as T;
    }
    if (t == _i17.InventoryAuditLog) {
      return _i17.InventoryAuditLog.fromJson(data) as T;
    }
    if (t == _i18.InventoryTransactionInfo) {
      return _i18.InventoryTransactionInfo.fromJson(data) as T;
    }
    if (t == _i19.LabTenHistory) {
      return _i19.LabTenHistory.fromJson(data) as T;
    }
    if (t == _i20.LabToday) {
      return _i20.LabToday.fromJson(data) as T;
    }
    if (t == _i21.LoginResponse) {
      return _i21.LoginResponse.fromJson(data) as T;
    }
    if (t == _i22.MedicineAlternative) {
      return _i22.MedicineAlternative.fromJson(data) as T;
    }
    if (t == _i23.MedicineDetail) {
      return _i23.MedicineDetail.fromJson(data) as T;
    }
    if (t == _i24.NotificationInfo) {
      return _i24.NotificationInfo.fromJson(data) as T;
    }
    if (t == _i25.OndutyStaff) {
      return _i25.OndutyStaff.fromJson(data) as T;
    }
    if (t == _i26.PatientExternalReport) {
      return _i26.PatientExternalReport.fromJson(data) as T;
    }
    if (t == _i27.PatientPrescriptionListItem) {
      return _i27.PatientPrescriptionListItem.fromJson(data) as T;
    }
    if (t == _i28.PatientPrescribedItem) {
      return _i28.PatientPrescribedItem.fromJson(data) as T;
    }
    if (t == _i29.PatientPrescriptionDetails) {
      return _i29.PatientPrescriptionDetails.fromJson(data) as T;
    }
    if (t == _i30.PatientProfileDto) {
      return _i30.PatientProfileDto.fromJson(data) as T;
    }
    if (t == _i31.PatientReportDto) {
      return _i31.PatientReportDto.fromJson(data) as T;
    }
    if (t == _i32.LabTests) {
      return _i32.LabTests.fromJson(data) as T;
    }
    if (t == _i33.Prescription) {
      return _i33.Prescription.fromJson(data) as T;
    }
    if (t == _i34.PrescriptionDetail) {
      return _i34.PrescriptionDetail.fromJson(data) as T;
    }
    if (t == _i35.PrescriptionList) {
      return _i35.PrescriptionList.fromJson(data) as T;
    }
    if (t == _i36.MonthlyBreakdown) {
      return _i36.MonthlyBreakdown.fromJson(data) as T;
    }
    if (t == _i37.PrescriptionStats) {
      return _i37.PrescriptionStats.fromJson(data) as T;
    }
    if (t == _i38.StockReport) {
      return _i38.StockReport.fromJson(data) as T;
    }
    if (t == _i39.TopMedicine) {
      return _i39.TopMedicine.fromJson(data) as T;
    }
    if (t == _i40.Roster) {
      return _i40.Roster.fromJson(data) as T;
    }
    if (t == _i41.Rosterlists) {
      return _i41.Rosterlists.fromJson(data) as T;
    }
    if (t == _i42.RosterUserRole) {
      return _i42.RosterUserRole.fromJson(data) as T;
    }
    if (t == _i43.ShiftType) {
      return _i43.ShiftType.fromJson(data) as T;
    }
    if (t == _i44.StaffProfileDto) {
      return _i44.StaffProfileDto.fromJson(data) as T;
    }
    if (t == _i45.TestResult) {
      return _i45.TestResult.fromJson(data) as T;
    }
    if (t == _i46.UserListItem) {
      return _i46.UserListItem.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.InventoryCategory?>()) {
      return (data != null ? _i2.InventoryCategory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.InventoryItemInfo?>()) {
      return (data != null ? _i3.InventoryItemInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.PrescribedItem?>()) {
      return (data != null ? _i4.PrescribedItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.StaffInfo?>()) {
      return (data != null ? _i5.StaffInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AdminProfileRespond?>()) {
      return (data != null ? _i6.AdminProfileRespond.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.AmbulanceContact?>()) {
      return (data != null ? _i7.AmbulanceContact.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.AuditEntry?>()) {
      return (data != null ? _i8.AuditEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.DashboardAnalytics?>()) {
      return (data != null ? _i9.DashboardAnalytics.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.DispenseItemDetail?>()) {
      return (data != null ? _i10.DispenseItemDetail.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.DispenseItemRequest?>()) {
      return (data != null ? _i11.DispenseItemRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.DispensedItemInput?>()) {
      return (data != null ? _i12.DispensedItemInput.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.DispenserProfileR?>()) {
      return (data != null ? _i13.DispenserProfileR.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.DoctorProfile?>()) {
      return (data != null ? _i14.DoctorProfile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.ExternalReportFile?>()) {
      return (data != null ? _i15.ExternalReportFile.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.Greeting?>()) {
      return (data != null ? _i16.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.InventoryAuditLog?>()) {
      return (data != null ? _i17.InventoryAuditLog.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.InventoryTransactionInfo?>()) {
      return (data != null
              ? _i18.InventoryTransactionInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i19.LabTenHistory?>()) {
      return (data != null ? _i19.LabTenHistory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.LabToday?>()) {
      return (data != null ? _i20.LabToday.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.LoginResponse?>()) {
      return (data != null ? _i21.LoginResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.MedicineAlternative?>()) {
      return (data != null ? _i22.MedicineAlternative.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i23.MedicineDetail?>()) {
      return (data != null ? _i23.MedicineDetail.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.NotificationInfo?>()) {
      return (data != null ? _i24.NotificationInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.OndutyStaff?>()) {
      return (data != null ? _i25.OndutyStaff.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.PatientExternalReport?>()) {
      return (data != null ? _i26.PatientExternalReport.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i27.PatientPrescriptionListItem?>()) {
      return (data != null
              ? _i27.PatientPrescriptionListItem.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i28.PatientPrescribedItem?>()) {
      return (data != null ? _i28.PatientPrescribedItem.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i29.PatientPrescriptionDetails?>()) {
      return (data != null
              ? _i29.PatientPrescriptionDetails.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i30.PatientProfileDto?>()) {
      return (data != null ? _i30.PatientProfileDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.PatientReportDto?>()) {
      return (data != null ? _i31.PatientReportDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.LabTests?>()) {
      return (data != null ? _i32.LabTests.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.Prescription?>()) {
      return (data != null ? _i33.Prescription.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.PrescriptionDetail?>()) {
      return (data != null ? _i34.PrescriptionDetail.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i35.PrescriptionList?>()) {
      return (data != null ? _i35.PrescriptionList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.MonthlyBreakdown?>()) {
      return (data != null ? _i36.MonthlyBreakdown.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.PrescriptionStats?>()) {
      return (data != null ? _i37.PrescriptionStats.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.StockReport?>()) {
      return (data != null ? _i38.StockReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.TopMedicine?>()) {
      return (data != null ? _i39.TopMedicine.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.Roster?>()) {
      return (data != null ? _i40.Roster.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.Rosterlists?>()) {
      return (data != null ? _i41.Rosterlists.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i42.RosterUserRole?>()) {
      return (data != null ? _i42.RosterUserRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.ShiftType?>()) {
      return (data != null ? _i43.ShiftType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.StaffProfileDto?>()) {
      return (data != null ? _i44.StaffProfileDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.TestResult?>()) {
      return (data != null ? _i45.TestResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.UserListItem?>()) {
      return (data != null ? _i46.UserListItem.fromJson(data) : null) as T;
    }
    if (t == List<_i36.MonthlyBreakdown>) {
      return (data as List)
              .map((e) => deserialize<_i36.MonthlyBreakdown>(e))
              .toList()
          as T;
    }
    if (t == List<_i39.TopMedicine>) {
      return (data as List)
              .map((e) => deserialize<_i39.TopMedicine>(e))
              .toList()
          as T;
    }
    if (t == List<_i38.StockReport>) {
      return (data as List)
              .map((e) => deserialize<_i38.StockReport>(e))
              .toList()
          as T;
    }
    if (t == List<_i28.PatientPrescribedItem>) {
      return (data as List)
              .map((e) => deserialize<_i28.PatientPrescribedItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i4.PrescribedItem>) {
      return (data as List)
              .map((e) => deserialize<_i4.PrescribedItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i47.UserListItem>) {
      return (data as List)
              .map((e) => deserialize<_i47.UserListItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i48.Roster>) {
      return (data as List).map((e) => deserialize<_i48.Roster>(e)).toList()
          as T;
    }
    if (t == List<_i49.Rosterlists>) {
      return (data as List)
              .map((e) => deserialize<_i49.Rosterlists>(e))
              .toList()
          as T;
    }
    if (t == List<_i50.AuditEntry>) {
      return (data as List).map((e) => deserialize<_i50.AuditEntry>(e)).toList()
          as T;
    }
    if (t == List<_i51.InventoryCategory>) {
      return (data as List)
              .map((e) => deserialize<_i51.InventoryCategory>(e))
              .toList()
          as T;
    }
    if (t == List<_i52.InventoryItemInfo>) {
      return (data as List)
              .map((e) => deserialize<_i52.InventoryItemInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i53.InventoryTransactionInfo>) {
      return (data as List)
              .map((e) => deserialize<_i53.InventoryTransactionInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i54.InventoryAuditLog>) {
      return (data as List)
              .map((e) => deserialize<_i54.InventoryAuditLog>(e))
              .toList()
          as T;
    }
    if (t == List<_i55.Prescription>) {
      return (data as List)
              .map((e) => deserialize<_i55.Prescription>(e))
              .toList()
          as T;
    }
    if (t == List<_i56.DispenseItemRequest>) {
      return (data as List)
              .map((e) => deserialize<_i56.DispenseItemRequest>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String?>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String?>(v)),
          )
          as T;
    }
    if (t == List<_i57.PrescribedItem>) {
      return (data as List)
              .map((e) => deserialize<_i57.PrescribedItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i58.PatientExternalReport>) {
      return (data as List)
              .map((e) => deserialize<_i58.PatientExternalReport>(e))
              .toList()
          as T;
    }
    if (t == List<_i59.PatientPrescriptionListItem>) {
      return (data as List)
              .map((e) => deserialize<_i59.PatientPrescriptionListItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i60.LabTests>) {
      return (data as List).map((e) => deserialize<_i60.LabTests>(e)).toList()
          as T;
    }
    if (t == List<_i61.TestResult>) {
      return (data as List).map((e) => deserialize<_i61.TestResult>(e)).toList()
          as T;
    }
    if (t == List<_i62.LabTenHistory>) {
      return (data as List)
              .map((e) => deserialize<_i62.LabTenHistory>(e))
              .toList()
          as T;
    }
    if (t == List<_i63.NotificationInfo>) {
      return (data as List)
              .map((e) => deserialize<_i63.NotificationInfo>(e))
              .toList()
          as T;
    }
    if (t == Map<String, int>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<int>(v)),
          )
          as T;
    }
    if (t == List<_i64.PatientReportDto>) {
      return (data as List)
              .map((e) => deserialize<_i64.PatientReportDto>(e))
              .toList()
          as T;
    }
    if (t == List<_i65.PrescriptionList>) {
      return (data as List)
              .map((e) => deserialize<_i65.PrescriptionList>(e))
              .toList()
          as T;
    }
    if (t == List<_i66.StaffInfo>) {
      return (data as List).map((e) => deserialize<_i66.StaffInfo>(e)).toList()
          as T;
    }
    if (t == List<_i67.AmbulanceContact>) {
      return (data as List)
              .map((e) => deserialize<_i67.AmbulanceContact>(e))
              .toList()
          as T;
    }
    if (t == List<_i68.OndutyStaff>) {
      return (data as List)
              .map((e) => deserialize<_i68.OndutyStaff>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.InventoryCategory => 'InventoryCategory',
      _i3.InventoryItemInfo => 'InventoryItemInfo',
      _i4.PrescribedItem => 'PrescribedItem',
      _i5.StaffInfo => 'StaffInfo',
      _i6.AdminProfileRespond => 'AdminProfileRespond',
      _i7.AmbulanceContact => 'AmbulanceContact',
      _i8.AuditEntry => 'AuditEntry',
      _i9.DashboardAnalytics => 'DashboardAnalytics',
      _i10.DispenseItemDetail => 'DispenseItemDetail',
      _i11.DispenseItemRequest => 'DispenseItemRequest',
      _i12.DispensedItemInput => 'DispensedItemInput',
      _i13.DispenserProfileR => 'DispenserProfileR',
      _i14.DoctorProfile => 'DoctorProfile',
      _i15.ExternalReportFile => 'ExternalReportFile',
      _i16.Greeting => 'Greeting',
      _i17.InventoryAuditLog => 'InventoryAuditLog',
      _i18.InventoryTransactionInfo => 'InventoryTransactionInfo',
      _i19.LabTenHistory => 'LabTenHistory',
      _i20.LabToday => 'LabToday',
      _i21.LoginResponse => 'LoginResponse',
      _i22.MedicineAlternative => 'MedicineAlternative',
      _i23.MedicineDetail => 'MedicineDetail',
      _i24.NotificationInfo => 'NotificationInfo',
      _i25.OndutyStaff => 'OndutyStaff',
      _i26.PatientExternalReport => 'PatientExternalReport',
      _i27.PatientPrescriptionListItem => 'PatientPrescriptionListItem',
      _i28.PatientPrescribedItem => 'PatientPrescribedItem',
      _i29.PatientPrescriptionDetails => 'PatientPrescriptionDetails',
      _i30.PatientProfileDto => 'PatientProfileDto',
      _i31.PatientReportDto => 'PatientReportDto',
      _i32.LabTests => 'LabTests',
      _i33.Prescription => 'Prescription',
      _i34.PrescriptionDetail => 'PrescriptionDetail',
      _i35.PrescriptionList => 'PrescriptionList',
      _i36.MonthlyBreakdown => 'MonthlyBreakdown',
      _i37.PrescriptionStats => 'PrescriptionStats',
      _i38.StockReport => 'StockReport',
      _i39.TopMedicine => 'TopMedicine',
      _i40.Roster => 'Roster',
      _i41.Rosterlists => 'Rosterlists',
      _i42.RosterUserRole => 'RosterUserRole',
      _i43.ShiftType => 'ShiftType',
      _i44.StaffProfileDto => 'StaffProfileDto',
      _i45.TestResult => 'TestResult',
      _i46.UserListItem => 'UserListItem',
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
      case _i2.InventoryCategory():
        return 'InventoryCategory';
      case _i3.InventoryItemInfo():
        return 'InventoryItemInfo';
      case _i4.PrescribedItem():
        return 'PrescribedItem';
      case _i5.StaffInfo():
        return 'StaffInfo';
      case _i6.AdminProfileRespond():
        return 'AdminProfileRespond';
      case _i7.AmbulanceContact():
        return 'AmbulanceContact';
      case _i8.AuditEntry():
        return 'AuditEntry';
      case _i9.DashboardAnalytics():
        return 'DashboardAnalytics';
      case _i10.DispenseItemDetail():
        return 'DispenseItemDetail';
      case _i11.DispenseItemRequest():
        return 'DispenseItemRequest';
      case _i12.DispensedItemInput():
        return 'DispensedItemInput';
      case _i13.DispenserProfileR():
        return 'DispenserProfileR';
      case _i14.DoctorProfile():
        return 'DoctorProfile';
      case _i15.ExternalReportFile():
        return 'ExternalReportFile';
      case _i16.Greeting():
        return 'Greeting';
      case _i17.InventoryAuditLog():
        return 'InventoryAuditLog';
      case _i18.InventoryTransactionInfo():
        return 'InventoryTransactionInfo';
      case _i19.LabTenHistory():
        return 'LabTenHistory';
      case _i20.LabToday():
        return 'LabToday';
      case _i21.LoginResponse():
        return 'LoginResponse';
      case _i22.MedicineAlternative():
        return 'MedicineAlternative';
      case _i23.MedicineDetail():
        return 'MedicineDetail';
      case _i24.NotificationInfo():
        return 'NotificationInfo';
      case _i25.OndutyStaff():
        return 'OndutyStaff';
      case _i26.PatientExternalReport():
        return 'PatientExternalReport';
      case _i27.PatientPrescriptionListItem():
        return 'PatientPrescriptionListItem';
      case _i28.PatientPrescribedItem():
        return 'PatientPrescribedItem';
      case _i29.PatientPrescriptionDetails():
        return 'PatientPrescriptionDetails';
      case _i30.PatientProfileDto():
        return 'PatientProfileDto';
      case _i31.PatientReportDto():
        return 'PatientReportDto';
      case _i32.LabTests():
        return 'LabTests';
      case _i33.Prescription():
        return 'Prescription';
      case _i34.PrescriptionDetail():
        return 'PrescriptionDetail';
      case _i35.PrescriptionList():
        return 'PrescriptionList';
      case _i36.MonthlyBreakdown():
        return 'MonthlyBreakdown';
      case _i37.PrescriptionStats():
        return 'PrescriptionStats';
      case _i38.StockReport():
        return 'StockReport';
      case _i39.TopMedicine():
        return 'TopMedicine';
      case _i40.Roster():
        return 'Roster';
      case _i41.Rosterlists():
        return 'Rosterlists';
      case _i42.RosterUserRole():
        return 'RosterUserRole';
      case _i43.ShiftType():
        return 'ShiftType';
      case _i44.StaffProfileDto():
        return 'StaffProfileDto';
      case _i45.TestResult():
        return 'TestResult';
      case _i46.UserListItem():
        return 'UserListItem';
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
      return deserialize<_i2.InventoryCategory>(data['data']);
    }
    if (dataClassName == 'InventoryItemInfo') {
      return deserialize<_i3.InventoryItemInfo>(data['data']);
    }
    if (dataClassName == 'PrescribedItem') {
      return deserialize<_i4.PrescribedItem>(data['data']);
    }
    if (dataClassName == 'StaffInfo') {
      return deserialize<_i5.StaffInfo>(data['data']);
    }
    if (dataClassName == 'AdminProfileRespond') {
      return deserialize<_i6.AdminProfileRespond>(data['data']);
    }
    if (dataClassName == 'AmbulanceContact') {
      return deserialize<_i7.AmbulanceContact>(data['data']);
    }
    if (dataClassName == 'AuditEntry') {
      return deserialize<_i8.AuditEntry>(data['data']);
    }
    if (dataClassName == 'DashboardAnalytics') {
      return deserialize<_i9.DashboardAnalytics>(data['data']);
    }
    if (dataClassName == 'DispenseItemDetail') {
      return deserialize<_i10.DispenseItemDetail>(data['data']);
    }
    if (dataClassName == 'DispenseItemRequest') {
      return deserialize<_i11.DispenseItemRequest>(data['data']);
    }
    if (dataClassName == 'DispensedItemInput') {
      return deserialize<_i12.DispensedItemInput>(data['data']);
    }
    if (dataClassName == 'DispenserProfileR') {
      return deserialize<_i13.DispenserProfileR>(data['data']);
    }
    if (dataClassName == 'DoctorProfile') {
      return deserialize<_i14.DoctorProfile>(data['data']);
    }
    if (dataClassName == 'ExternalReportFile') {
      return deserialize<_i15.ExternalReportFile>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i16.Greeting>(data['data']);
    }
    if (dataClassName == 'InventoryAuditLog') {
      return deserialize<_i17.InventoryAuditLog>(data['data']);
    }
    if (dataClassName == 'InventoryTransactionInfo') {
      return deserialize<_i18.InventoryTransactionInfo>(data['data']);
    }
    if (dataClassName == 'LabTenHistory') {
      return deserialize<_i19.LabTenHistory>(data['data']);
    }
    if (dataClassName == 'LabToday') {
      return deserialize<_i20.LabToday>(data['data']);
    }
    if (dataClassName == 'LoginResponse') {
      return deserialize<_i21.LoginResponse>(data['data']);
    }
    if (dataClassName == 'MedicineAlternative') {
      return deserialize<_i22.MedicineAlternative>(data['data']);
    }
    if (dataClassName == 'MedicineDetail') {
      return deserialize<_i23.MedicineDetail>(data['data']);
    }
    if (dataClassName == 'NotificationInfo') {
      return deserialize<_i24.NotificationInfo>(data['data']);
    }
    if (dataClassName == 'OndutyStaff') {
      return deserialize<_i25.OndutyStaff>(data['data']);
    }
    if (dataClassName == 'PatientExternalReport') {
      return deserialize<_i26.PatientExternalReport>(data['data']);
    }
    if (dataClassName == 'PatientPrescriptionListItem') {
      return deserialize<_i27.PatientPrescriptionListItem>(data['data']);
    }
    if (dataClassName == 'PatientPrescribedItem') {
      return deserialize<_i28.PatientPrescribedItem>(data['data']);
    }
    if (dataClassName == 'PatientPrescriptionDetails') {
      return deserialize<_i29.PatientPrescriptionDetails>(data['data']);
    }
    if (dataClassName == 'PatientProfileDto') {
      return deserialize<_i30.PatientProfileDto>(data['data']);
    }
    if (dataClassName == 'PatientReportDto') {
      return deserialize<_i31.PatientReportDto>(data['data']);
    }
    if (dataClassName == 'LabTests') {
      return deserialize<_i32.LabTests>(data['data']);
    }
    if (dataClassName == 'Prescription') {
      return deserialize<_i33.Prescription>(data['data']);
    }
    if (dataClassName == 'PrescriptionDetail') {
      return deserialize<_i34.PrescriptionDetail>(data['data']);
    }
    if (dataClassName == 'PrescriptionList') {
      return deserialize<_i35.PrescriptionList>(data['data']);
    }
    if (dataClassName == 'MonthlyBreakdown') {
      return deserialize<_i36.MonthlyBreakdown>(data['data']);
    }
    if (dataClassName == 'PrescriptionStats') {
      return deserialize<_i37.PrescriptionStats>(data['data']);
    }
    if (dataClassName == 'StockReport') {
      return deserialize<_i38.StockReport>(data['data']);
    }
    if (dataClassName == 'TopMedicine') {
      return deserialize<_i39.TopMedicine>(data['data']);
    }
    if (dataClassName == 'Roster') {
      return deserialize<_i40.Roster>(data['data']);
    }
    if (dataClassName == 'Rosterlists') {
      return deserialize<_i41.Rosterlists>(data['data']);
    }
    if (dataClassName == 'RosterUserRole') {
      return deserialize<_i42.RosterUserRole>(data['data']);
    }
    if (dataClassName == 'ShiftType') {
      return deserialize<_i43.ShiftType>(data['data']);
    }
    if (dataClassName == 'StaffProfileDto') {
      return deserialize<_i44.StaffProfileDto>(data['data']);
    }
    if (dataClassName == 'TestResult') {
      return deserialize<_i45.TestResult>(data['data']);
    }
    if (dataClassName == 'UserListItem') {
      return deserialize<_i46.UserListItem>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
