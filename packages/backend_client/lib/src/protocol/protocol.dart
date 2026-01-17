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
import 'admin_dashboard_overview.dart' as _i6;
import 'admin_profile.dart' as _i7;
import 'ambulance_contact.dart' as _i8;
import 'audit_entry.dart' as _i9;
import 'dashboard_analytics.dart' as _i10;
import 'dispense_history_entry.dart' as _i11;
import 'dispense_item_detail.dart' as _i12;
import 'dispense_request.dart' as _i13;
import 'dispensed_item_input.dart' as _i14;
import 'dispensed_item_summary.dart' as _i15;
import 'dispenser_profile_r.dart' as _i16;
import 'doctor_home_data.dart' as _i17;
import 'doctor_home_recent_item.dart' as _i18;
import 'doctor_home_reviewed_report.dart' as _i19;
import 'doctor_profile.dart' as _i20;
import 'external_report_file.dart' as _i21;
import 'greeting.dart' as _i22;
import 'inventory_audit_log.dart' as _i23;
import 'inventory_transaction.dart' as _i24;
import 'lab_ten_history.dart' as _i25;
import 'lab_today.dart' as _i26;
import 'login_response.dart' as _i27;
import 'medicine_alternative.dart' as _i28;
import 'medicine_details.dart' as _i29;
import 'notification.dart' as _i30;
import 'onduty_staff.dart' as _i31;
import 'otp_challenge_response.dart' as _i32;
import 'patient_external_report.dart' as _i33;
import 'patient_record_list.dart' as _i34;
import 'patient_record_prescribed_item.dart' as _i35;
import 'patient_record_prescription_details.dart' as _i36;
import 'patient_reponse.dart' as _i37;
import 'patient_report.dart' as _i38;
import 'patient_return_tests.dart' as _i39;
import 'prescription.dart' as _i40;
import 'prescription_detail.dart' as _i41;
import 'prescription_list.dart' as _i42;
import 'report_lab_test_range.dart' as _i43;
import 'report_medicine_stock_range.dart' as _i44;
import 'report_monthly.dart' as _i45;
import 'report_prescription.dart' as _i46;
import 'report_stock.dart' as _i47;
import 'report_top_medicine.dart' as _i48;
import 'roster_data.dart' as _i49;
import 'roster_lists.dart' as _i50;
import 'roster_user_role.dart' as _i51;
import 'shift_type.dart' as _i52;
import 'staff_profile.dart' as _i53;
import 'test_result_create_upload.dart' as _i54;
import 'user_list_item.dart' as _i55;
import 'package:backend_client/src/protocol/InventoryItemInfo.dart' as _i56;
import 'package:backend_client/src/protocol/inventory_audit_log.dart' as _i57;
import 'package:backend_client/src/protocol/prescription.dart' as _i58;
import 'package:backend_client/src/protocol/dispense_request.dart' as _i59;
import 'package:backend_client/src/protocol/dispense_history_entry.dart'
    as _i60;
import 'package:backend_client/src/protocol/PrescribedItem.dart' as _i61;
import 'package:backend_client/src/protocol/patient_external_report.dart'
    as _i62;
import 'package:backend_client/src/protocol/patient_record_list.dart' as _i63;
import 'package:backend_client/src/protocol/patient_return_tests.dart' as _i64;
import 'package:backend_client/src/protocol/test_result_create_upload.dart'
    as _i65;
import 'package:backend_client/src/protocol/lab_ten_history.dart' as _i66;
import 'package:backend_client/src/protocol/notification.dart' as _i67;
import 'package:backend_client/src/protocol/patient_report.dart' as _i68;
import 'package:backend_client/src/protocol/prescription_list.dart' as _i69;
import 'package:backend_client/src/protocol/StaffInfo.dart' as _i70;
import 'package:backend_client/src/protocol/ambulance_contact.dart' as _i71;
import 'package:backend_client/src/protocol/onduty_staff.dart' as _i72;
export 'InventoryCategory.dart';
export 'InventoryItemInfo.dart';
export 'PrescribedItem.dart';
export 'StaffInfo.dart';
export 'admin_dashboard_overview.dart';
export 'admin_profile.dart';
export 'ambulance_contact.dart';
export 'audit_entry.dart';
export 'dashboard_analytics.dart';
export 'dispense_history_entry.dart';
export 'dispense_item_detail.dart';
export 'dispense_request.dart';
export 'dispensed_item_input.dart';
export 'dispensed_item_summary.dart';
export 'dispenser_profile_r.dart';
export 'doctor_home_data.dart';
export 'doctor_home_recent_item.dart';
export 'doctor_home_reviewed_report.dart';
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
export 'report_lab_test_range.dart';
export 'report_medicine_stock_range.dart';
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
    if (t == _i6.AdminDashboardOverview) {
      return _i6.AdminDashboardOverview.fromJson(data) as T;
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
    if (t == _i11.DispenseHistoryEntry) {
      return _i11.DispenseHistoryEntry.fromJson(data) as T;
    }
    if (t == _i12.DispenseItemDetail) {
      return _i12.DispenseItemDetail.fromJson(data) as T;
    }
    if (t == _i13.DispenseItemRequest) {
      return _i13.DispenseItemRequest.fromJson(data) as T;
    }
    if (t == _i14.DispensedItemInput) {
      return _i14.DispensedItemInput.fromJson(data) as T;
    }
    if (t == _i15.DispensedItemSummary) {
      return _i15.DispensedItemSummary.fromJson(data) as T;
    }
    if (t == _i16.DispenserProfileR) {
      return _i16.DispenserProfileR.fromJson(data) as T;
    }
    if (t == _i17.DoctorHomeData) {
      return _i17.DoctorHomeData.fromJson(data) as T;
    }
    if (t == _i18.DoctorHomeRecentItem) {
      return _i18.DoctorHomeRecentItem.fromJson(data) as T;
    }
    if (t == _i19.DoctorHomeReviewedReport) {
      return _i19.DoctorHomeReviewedReport.fromJson(data) as T;
    }
    if (t == _i20.DoctorProfile) {
      return _i20.DoctorProfile.fromJson(data) as T;
    }
    if (t == _i21.ExternalReportFile) {
      return _i21.ExternalReportFile.fromJson(data) as T;
    }
    if (t == _i22.Greeting) {
      return _i22.Greeting.fromJson(data) as T;
    }
    if (t == _i23.InventoryAuditLog) {
      return _i23.InventoryAuditLog.fromJson(data) as T;
    }
    if (t == _i24.InventoryTransactionInfo) {
      return _i24.InventoryTransactionInfo.fromJson(data) as T;
    }
    if (t == _i25.LabTenHistory) {
      return _i25.LabTenHistory.fromJson(data) as T;
    }
    if (t == _i26.LabToday) {
      return _i26.LabToday.fromJson(data) as T;
    }
    if (t == _i27.LoginResponse) {
      return _i27.LoginResponse.fromJson(data) as T;
    }
    if (t == _i28.MedicineAlternative) {
      return _i28.MedicineAlternative.fromJson(data) as T;
    }
    if (t == _i29.MedicineDetail) {
      return _i29.MedicineDetail.fromJson(data) as T;
    }
    if (t == _i30.NotificationInfo) {
      return _i30.NotificationInfo.fromJson(data) as T;
    }
    if (t == _i31.OndutyStaff) {
      return _i31.OndutyStaff.fromJson(data) as T;
    }
    if (t == _i32.OtpChallengeResponse) {
      return _i32.OtpChallengeResponse.fromJson(data) as T;
    }
    if (t == _i33.PatientExternalReport) {
      return _i33.PatientExternalReport.fromJson(data) as T;
    }
    if (t == _i34.PatientPrescriptionListItem) {
      return _i34.PatientPrescriptionListItem.fromJson(data) as T;
    }
    if (t == _i35.PatientPrescribedItem) {
      return _i35.PatientPrescribedItem.fromJson(data) as T;
    }
    if (t == _i36.PatientPrescriptionDetails) {
      return _i36.PatientPrescriptionDetails.fromJson(data) as T;
    }
    if (t == _i37.PatientProfile) {
      return _i37.PatientProfile.fromJson(data) as T;
    }
    if (t == _i38.PatientReportDto) {
      return _i38.PatientReportDto.fromJson(data) as T;
    }
    if (t == _i39.LabTests) {
      return _i39.LabTests.fromJson(data) as T;
    }
    if (t == _i40.Prescription) {
      return _i40.Prescription.fromJson(data) as T;
    }
    if (t == _i41.PrescriptionDetail) {
      return _i41.PrescriptionDetail.fromJson(data) as T;
    }
    if (t == _i42.PrescriptionList) {
      return _i42.PrescriptionList.fromJson(data) as T;
    }
    if (t == _i43.LabTestRangeRow) {
      return _i43.LabTestRangeRow.fromJson(data) as T;
    }
    if (t == _i44.MedicineStockRangeRow) {
      return _i44.MedicineStockRangeRow.fromJson(data) as T;
    }
    if (t == _i45.MonthlyBreakdown) {
      return _i45.MonthlyBreakdown.fromJson(data) as T;
    }
    if (t == _i46.PrescriptionStats) {
      return _i46.PrescriptionStats.fromJson(data) as T;
    }
    if (t == _i47.StockReport) {
      return _i47.StockReport.fromJson(data) as T;
    }
    if (t == _i48.TopMedicine) {
      return _i48.TopMedicine.fromJson(data) as T;
    }
    if (t == _i49.Roster) {
      return _i49.Roster.fromJson(data) as T;
    }
    if (t == _i50.Rosterlists) {
      return _i50.Rosterlists.fromJson(data) as T;
    }
    if (t == _i51.RosterUserRole) {
      return _i51.RosterUserRole.fromJson(data) as T;
    }
    if (t == _i52.ShiftType) {
      return _i52.ShiftType.fromJson(data) as T;
    }
    if (t == _i53.StaffProfileDto) {
      return _i53.StaffProfileDto.fromJson(data) as T;
    }
    if (t == _i54.TestResult) {
      return _i54.TestResult.fromJson(data) as T;
    }
    if (t == _i55.UserListItem) {
      return _i55.UserListItem.fromJson(data) as T;
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
    if (t == _i1.getType<_i6.AdminDashboardOverview?>()) {
      return (data != null ? _i6.AdminDashboardOverview.fromJson(data) : null)
          as T;
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
    if (t == _i1.getType<_i11.DispenseHistoryEntry?>()) {
      return (data != null ? _i11.DispenseHistoryEntry.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.DispenseItemDetail?>()) {
      return (data != null ? _i12.DispenseItemDetail.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.DispenseItemRequest?>()) {
      return (data != null ? _i13.DispenseItemRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.DispensedItemInput?>()) {
      return (data != null ? _i14.DispensedItemInput.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.DispensedItemSummary?>()) {
      return (data != null ? _i15.DispensedItemSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.DispenserProfileR?>()) {
      return (data != null ? _i16.DispenserProfileR.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.DoctorHomeData?>()) {
      return (data != null ? _i17.DoctorHomeData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.DoctorHomeRecentItem?>()) {
      return (data != null ? _i18.DoctorHomeRecentItem.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.DoctorHomeReviewedReport?>()) {
      return (data != null
              ? _i19.DoctorHomeReviewedReport.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i20.DoctorProfile?>()) {
      return (data != null ? _i20.DoctorProfile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.ExternalReportFile?>()) {
      return (data != null ? _i21.ExternalReportFile.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i22.Greeting?>()) {
      return (data != null ? _i22.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.InventoryAuditLog?>()) {
      return (data != null ? _i23.InventoryAuditLog.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.InventoryTransactionInfo?>()) {
      return (data != null
              ? _i24.InventoryTransactionInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i25.LabTenHistory?>()) {
      return (data != null ? _i25.LabTenHistory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.LabToday?>()) {
      return (data != null ? _i26.LabToday.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.LoginResponse?>()) {
      return (data != null ? _i27.LoginResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.MedicineAlternative?>()) {
      return (data != null ? _i28.MedicineAlternative.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i29.MedicineDetail?>()) {
      return (data != null ? _i29.MedicineDetail.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.NotificationInfo?>()) {
      return (data != null ? _i30.NotificationInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.OndutyStaff?>()) {
      return (data != null ? _i31.OndutyStaff.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.OtpChallengeResponse?>()) {
      return (data != null ? _i32.OtpChallengeResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i33.PatientExternalReport?>()) {
      return (data != null ? _i33.PatientExternalReport.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i34.PatientPrescriptionListItem?>()) {
      return (data != null
              ? _i34.PatientPrescriptionListItem.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i35.PatientPrescribedItem?>()) {
      return (data != null ? _i35.PatientPrescribedItem.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i36.PatientPrescriptionDetails?>()) {
      return (data != null
              ? _i36.PatientPrescriptionDetails.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i37.PatientProfile?>()) {
      return (data != null ? _i37.PatientProfile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.PatientReportDto?>()) {
      return (data != null ? _i38.PatientReportDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.LabTests?>()) {
      return (data != null ? _i39.LabTests.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.Prescription?>()) {
      return (data != null ? _i40.Prescription.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.PrescriptionDetail?>()) {
      return (data != null ? _i41.PrescriptionDetail.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i42.PrescriptionList?>()) {
      return (data != null ? _i42.PrescriptionList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.LabTestRangeRow?>()) {
      return (data != null ? _i43.LabTestRangeRow.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.MedicineStockRangeRow?>()) {
      return (data != null ? _i44.MedicineStockRangeRow.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i45.MonthlyBreakdown?>()) {
      return (data != null ? _i45.MonthlyBreakdown.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.PrescriptionStats?>()) {
      return (data != null ? _i46.PrescriptionStats.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i47.StockReport?>()) {
      return (data != null ? _i47.StockReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i48.TopMedicine?>()) {
      return (data != null ? _i48.TopMedicine.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i49.Roster?>()) {
      return (data != null ? _i49.Roster.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i50.Rosterlists?>()) {
      return (data != null ? _i50.Rosterlists.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i51.RosterUserRole?>()) {
      return (data != null ? _i51.RosterUserRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i52.ShiftType?>()) {
      return (data != null ? _i52.ShiftType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i53.StaffProfileDto?>()) {
      return (data != null ? _i53.StaffProfileDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i54.TestResult?>()) {
      return (data != null ? _i54.TestResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i55.UserListItem?>()) {
      return (data != null ? _i55.UserListItem.fromJson(data) : null) as T;
    }
    if (t == List<_i45.MonthlyBreakdown>) {
      return (data as List)
              .map((e) => deserialize<_i45.MonthlyBreakdown>(e))
              .toList()
          as T;
    }
    if (t == List<_i48.TopMedicine>) {
      return (data as List)
              .map((e) => deserialize<_i48.TopMedicine>(e))
              .toList()
          as T;
    }
    if (t == List<_i47.StockReport>) {
      return (data as List)
              .map((e) => deserialize<_i47.StockReport>(e))
              .toList()
          as T;
    }
    if (t == List<_i15.DispensedItemSummary>) {
      return (data as List)
              .map((e) => deserialize<_i15.DispensedItemSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i18.DoctorHomeRecentItem>) {
      return (data as List)
              .map((e) => deserialize<_i18.DoctorHomeRecentItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i19.DoctorHomeReviewedReport>) {
      return (data as List)
              .map((e) => deserialize<_i19.DoctorHomeReviewedReport>(e))
              .toList()
          as T;
    }
    if (t == List<_i35.PatientPrescribedItem>) {
      return (data as List)
              .map((e) => deserialize<_i35.PatientPrescribedItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i4.PrescribedItem>) {
      return (data as List)
              .map((e) => deserialize<_i4.PrescribedItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i56.InventoryItemInfo>) {
      return (data as List)
              .map((e) => deserialize<_i56.InventoryItemInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i57.InventoryAuditLog>) {
      return (data as List)
              .map((e) => deserialize<_i57.InventoryAuditLog>(e))
              .toList()
          as T;
    }
    if (t == List<_i58.Prescription>) {
      return (data as List)
              .map((e) => deserialize<_i58.Prescription>(e))
              .toList()
          as T;
    }
    if (t == List<_i59.DispenseItemRequest>) {
      return (data as List)
              .map((e) => deserialize<_i59.DispenseItemRequest>(e))
              .toList()
          as T;
    }
    if (t == List<_i60.DispenseHistoryEntry>) {
      return (data as List)
              .map((e) => deserialize<_i60.DispenseHistoryEntry>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String?>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String?>(v)),
          )
          as T;
    }
    if (t == List<_i61.PrescribedItem>) {
      return (data as List)
              .map((e) => deserialize<_i61.PrescribedItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i62.PatientExternalReport>) {
      return (data as List)
              .map((e) => deserialize<_i62.PatientExternalReport>(e))
              .toList()
          as T;
    }
    if (t == List<_i63.PatientPrescriptionListItem>) {
      return (data as List)
              .map((e) => deserialize<_i63.PatientPrescriptionListItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i64.LabTests>) {
      return (data as List).map((e) => deserialize<_i64.LabTests>(e)).toList()
          as T;
    }
    if (t == List<_i65.TestResult>) {
      return (data as List).map((e) => deserialize<_i65.TestResult>(e)).toList()
          as T;
    }
    if (t == List<_i66.LabTenHistory>) {
      return (data as List)
              .map((e) => deserialize<_i66.LabTenHistory>(e))
              .toList()
          as T;
    }
    if (t == List<_i67.NotificationInfo>) {
      return (data as List)
              .map((e) => deserialize<_i67.NotificationInfo>(e))
              .toList()
          as T;
    }
    if (t == Map<String, int>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<int>(v)),
          )
          as T;
    }
    if (t == List<_i68.PatientReportDto>) {
      return (data as List)
              .map((e) => deserialize<_i68.PatientReportDto>(e))
              .toList()
          as T;
    }
    if (t == List<_i69.PrescriptionList>) {
      return (data as List)
              .map((e) => deserialize<_i69.PrescriptionList>(e))
              .toList()
          as T;
    }
    if (t == List<_i70.StaffInfo>) {
      return (data as List).map((e) => deserialize<_i70.StaffInfo>(e)).toList()
          as T;
    }
    if (t == List<_i71.AmbulanceContact>) {
      return (data as List)
              .map((e) => deserialize<_i71.AmbulanceContact>(e))
              .toList()
          as T;
    }
    if (t == List<_i72.OndutyStaff>) {
      return (data as List)
              .map((e) => deserialize<_i72.OndutyStaff>(e))
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
      _i6.AdminDashboardOverview => 'AdminDashboardOverview',
      _i7.AdminProfileRespond => 'AdminProfileRespond',
      _i8.AmbulanceContact => 'AmbulanceContact',
      _i9.AuditEntry => 'AuditEntry',
      _i10.DashboardAnalytics => 'DashboardAnalytics',
      _i11.DispenseHistoryEntry => 'DispenseHistoryEntry',
      _i12.DispenseItemDetail => 'DispenseItemDetail',
      _i13.DispenseItemRequest => 'DispenseItemRequest',
      _i14.DispensedItemInput => 'DispensedItemInput',
      _i15.DispensedItemSummary => 'DispensedItemSummary',
      _i16.DispenserProfileR => 'DispenserProfileR',
      _i17.DoctorHomeData => 'DoctorHomeData',
      _i18.DoctorHomeRecentItem => 'DoctorHomeRecentItem',
      _i19.DoctorHomeReviewedReport => 'DoctorHomeReviewedReport',
      _i20.DoctorProfile => 'DoctorProfile',
      _i21.ExternalReportFile => 'ExternalReportFile',
      _i22.Greeting => 'Greeting',
      _i23.InventoryAuditLog => 'InventoryAuditLog',
      _i24.InventoryTransactionInfo => 'InventoryTransactionInfo',
      _i25.LabTenHistory => 'LabTenHistory',
      _i26.LabToday => 'LabToday',
      _i27.LoginResponse => 'LoginResponse',
      _i28.MedicineAlternative => 'MedicineAlternative',
      _i29.MedicineDetail => 'MedicineDetail',
      _i30.NotificationInfo => 'NotificationInfo',
      _i31.OndutyStaff => 'OndutyStaff',
      _i32.OtpChallengeResponse => 'OtpChallengeResponse',
      _i33.PatientExternalReport => 'PatientExternalReport',
      _i34.PatientPrescriptionListItem => 'PatientPrescriptionListItem',
      _i35.PatientPrescribedItem => 'PatientPrescribedItem',
      _i36.PatientPrescriptionDetails => 'PatientPrescriptionDetails',
      _i37.PatientProfile => 'PatientProfile',
      _i38.PatientReportDto => 'PatientReportDto',
      _i39.LabTests => 'LabTests',
      _i40.Prescription => 'Prescription',
      _i41.PrescriptionDetail => 'PrescriptionDetail',
      _i42.PrescriptionList => 'PrescriptionList',
      _i43.LabTestRangeRow => 'LabTestRangeRow',
      _i44.MedicineStockRangeRow => 'MedicineStockRangeRow',
      _i45.MonthlyBreakdown => 'MonthlyBreakdown',
      _i46.PrescriptionStats => 'PrescriptionStats',
      _i47.StockReport => 'StockReport',
      _i48.TopMedicine => 'TopMedicine',
      _i49.Roster => 'Roster',
      _i50.Rosterlists => 'Rosterlists',
      _i51.RosterUserRole => 'RosterUserRole',
      _i52.ShiftType => 'ShiftType',
      _i53.StaffProfileDto => 'StaffProfileDto',
      _i54.TestResult => 'TestResult',
      _i55.UserListItem => 'UserListItem',
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
      case _i6.AdminDashboardOverview():
        return 'AdminDashboardOverview';
      case _i7.AdminProfileRespond():
        return 'AdminProfileRespond';
      case _i8.AmbulanceContact():
        return 'AmbulanceContact';
      case _i9.AuditEntry():
        return 'AuditEntry';
      case _i10.DashboardAnalytics():
        return 'DashboardAnalytics';
      case _i11.DispenseHistoryEntry():
        return 'DispenseHistoryEntry';
      case _i12.DispenseItemDetail():
        return 'DispenseItemDetail';
      case _i13.DispenseItemRequest():
        return 'DispenseItemRequest';
      case _i14.DispensedItemInput():
        return 'DispensedItemInput';
      case _i15.DispensedItemSummary():
        return 'DispensedItemSummary';
      case _i16.DispenserProfileR():
        return 'DispenserProfileR';
      case _i17.DoctorHomeData():
        return 'DoctorHomeData';
      case _i18.DoctorHomeRecentItem():
        return 'DoctorHomeRecentItem';
      case _i19.DoctorHomeReviewedReport():
        return 'DoctorHomeReviewedReport';
      case _i20.DoctorProfile():
        return 'DoctorProfile';
      case _i21.ExternalReportFile():
        return 'ExternalReportFile';
      case _i22.Greeting():
        return 'Greeting';
      case _i23.InventoryAuditLog():
        return 'InventoryAuditLog';
      case _i24.InventoryTransactionInfo():
        return 'InventoryTransactionInfo';
      case _i25.LabTenHistory():
        return 'LabTenHistory';
      case _i26.LabToday():
        return 'LabToday';
      case _i27.LoginResponse():
        return 'LoginResponse';
      case _i28.MedicineAlternative():
        return 'MedicineAlternative';
      case _i29.MedicineDetail():
        return 'MedicineDetail';
      case _i30.NotificationInfo():
        return 'NotificationInfo';
      case _i31.OndutyStaff():
        return 'OndutyStaff';
      case _i32.OtpChallengeResponse():
        return 'OtpChallengeResponse';
      case _i33.PatientExternalReport():
        return 'PatientExternalReport';
      case _i34.PatientPrescriptionListItem():
        return 'PatientPrescriptionListItem';
      case _i35.PatientPrescribedItem():
        return 'PatientPrescribedItem';
      case _i36.PatientPrescriptionDetails():
        return 'PatientPrescriptionDetails';
      case _i37.PatientProfile():
        return 'PatientProfile';
      case _i38.PatientReportDto():
        return 'PatientReportDto';
      case _i39.LabTests():
        return 'LabTests';
      case _i40.Prescription():
        return 'Prescription';
      case _i41.PrescriptionDetail():
        return 'PrescriptionDetail';
      case _i42.PrescriptionList():
        return 'PrescriptionList';
      case _i43.LabTestRangeRow():
        return 'LabTestRangeRow';
      case _i44.MedicineStockRangeRow():
        return 'MedicineStockRangeRow';
      case _i45.MonthlyBreakdown():
        return 'MonthlyBreakdown';
      case _i46.PrescriptionStats():
        return 'PrescriptionStats';
      case _i47.StockReport():
        return 'StockReport';
      case _i48.TopMedicine():
        return 'TopMedicine';
      case _i49.Roster():
        return 'Roster';
      case _i50.Rosterlists():
        return 'Rosterlists';
      case _i51.RosterUserRole():
        return 'RosterUserRole';
      case _i52.ShiftType():
        return 'ShiftType';
      case _i53.StaffProfileDto():
        return 'StaffProfileDto';
      case _i54.TestResult():
        return 'TestResult';
      case _i55.UserListItem():
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
    if (dataClassName == 'AdminDashboardOverview') {
      return deserialize<_i6.AdminDashboardOverview>(data['data']);
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
    if (dataClassName == 'DispenseHistoryEntry') {
      return deserialize<_i11.DispenseHistoryEntry>(data['data']);
    }
    if (dataClassName == 'DispenseItemDetail') {
      return deserialize<_i12.DispenseItemDetail>(data['data']);
    }
    if (dataClassName == 'DispenseItemRequest') {
      return deserialize<_i13.DispenseItemRequest>(data['data']);
    }
    if (dataClassName == 'DispensedItemInput') {
      return deserialize<_i14.DispensedItemInput>(data['data']);
    }
    if (dataClassName == 'DispensedItemSummary') {
      return deserialize<_i15.DispensedItemSummary>(data['data']);
    }
    if (dataClassName == 'DispenserProfileR') {
      return deserialize<_i16.DispenserProfileR>(data['data']);
    }
    if (dataClassName == 'DoctorHomeData') {
      return deserialize<_i17.DoctorHomeData>(data['data']);
    }
    if (dataClassName == 'DoctorHomeRecentItem') {
      return deserialize<_i18.DoctorHomeRecentItem>(data['data']);
    }
    if (dataClassName == 'DoctorHomeReviewedReport') {
      return deserialize<_i19.DoctorHomeReviewedReport>(data['data']);
    }
    if (dataClassName == 'DoctorProfile') {
      return deserialize<_i20.DoctorProfile>(data['data']);
    }
    if (dataClassName == 'ExternalReportFile') {
      return deserialize<_i21.ExternalReportFile>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i22.Greeting>(data['data']);
    }
    if (dataClassName == 'InventoryAuditLog') {
      return deserialize<_i23.InventoryAuditLog>(data['data']);
    }
    if (dataClassName == 'InventoryTransactionInfo') {
      return deserialize<_i24.InventoryTransactionInfo>(data['data']);
    }
    if (dataClassName == 'LabTenHistory') {
      return deserialize<_i25.LabTenHistory>(data['data']);
    }
    if (dataClassName == 'LabToday') {
      return deserialize<_i26.LabToday>(data['data']);
    }
    if (dataClassName == 'LoginResponse') {
      return deserialize<_i27.LoginResponse>(data['data']);
    }
    if (dataClassName == 'MedicineAlternative') {
      return deserialize<_i28.MedicineAlternative>(data['data']);
    }
    if (dataClassName == 'MedicineDetail') {
      return deserialize<_i29.MedicineDetail>(data['data']);
    }
    if (dataClassName == 'NotificationInfo') {
      return deserialize<_i30.NotificationInfo>(data['data']);
    }
    if (dataClassName == 'OndutyStaff') {
      return deserialize<_i31.OndutyStaff>(data['data']);
    }
    if (dataClassName == 'OtpChallengeResponse') {
      return deserialize<_i32.OtpChallengeResponse>(data['data']);
    }
    if (dataClassName == 'PatientExternalReport') {
      return deserialize<_i33.PatientExternalReport>(data['data']);
    }
    if (dataClassName == 'PatientPrescriptionListItem') {
      return deserialize<_i34.PatientPrescriptionListItem>(data['data']);
    }
    if (dataClassName == 'PatientPrescribedItem') {
      return deserialize<_i35.PatientPrescribedItem>(data['data']);
    }
    if (dataClassName == 'PatientPrescriptionDetails') {
      return deserialize<_i36.PatientPrescriptionDetails>(data['data']);
    }
    if (dataClassName == 'PatientProfile') {
      return deserialize<_i37.PatientProfile>(data['data']);
    }
    if (dataClassName == 'PatientReportDto') {
      return deserialize<_i38.PatientReportDto>(data['data']);
    }
    if (dataClassName == 'LabTests') {
      return deserialize<_i39.LabTests>(data['data']);
    }
    if (dataClassName == 'Prescription') {
      return deserialize<_i40.Prescription>(data['data']);
    }
    if (dataClassName == 'PrescriptionDetail') {
      return deserialize<_i41.PrescriptionDetail>(data['data']);
    }
    if (dataClassName == 'PrescriptionList') {
      return deserialize<_i42.PrescriptionList>(data['data']);
    }
    if (dataClassName == 'LabTestRangeRow') {
      return deserialize<_i43.LabTestRangeRow>(data['data']);
    }
    if (dataClassName == 'MedicineStockRangeRow') {
      return deserialize<_i44.MedicineStockRangeRow>(data['data']);
    }
    if (dataClassName == 'MonthlyBreakdown') {
      return deserialize<_i45.MonthlyBreakdown>(data['data']);
    }
    if (dataClassName == 'PrescriptionStats') {
      return deserialize<_i46.PrescriptionStats>(data['data']);
    }
    if (dataClassName == 'StockReport') {
      return deserialize<_i47.StockReport>(data['data']);
    }
    if (dataClassName == 'TopMedicine') {
      return deserialize<_i48.TopMedicine>(data['data']);
    }
    if (dataClassName == 'Roster') {
      return deserialize<_i49.Roster>(data['data']);
    }
    if (dataClassName == 'Rosterlists') {
      return deserialize<_i50.Rosterlists>(data['data']);
    }
    if (dataClassName == 'RosterUserRole') {
      return deserialize<_i51.RosterUserRole>(data['data']);
    }
    if (dataClassName == 'ShiftType') {
      return deserialize<_i52.ShiftType>(data['data']);
    }
    if (dataClassName == 'StaffProfileDto') {
      return deserialize<_i53.StaffProfileDto>(data['data']);
    }
    if (dataClassName == 'TestResult') {
      return deserialize<_i54.TestResult>(data['data']);
    }
    if (dataClassName == 'UserListItem') {
      return deserialize<_i55.UserListItem>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
