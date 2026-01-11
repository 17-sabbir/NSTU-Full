import 'package:serverpod/serverpod.dart';
import 'package:backend_server/src/generated/protocol.dart';

class AdminReportEndpoints extends Endpoint {



  Future<DashboardAnalytics> getDashboardAnalytics(Session session) async {
    try {
      // ---------- BASIC COUNTS ----------
      final totalPatients = await _getSingleInt(
        session,
        "SELECT COUNT(*) FROM users WHERE role IN ('STUDENT','TEACHER','OUTSIDE')",
      );

      final outPatients = await _getSingleInt(
        session,
        "SELECT COUNT(*) FROM users WHERE role = 'OUTSIDE'",
      );

      final totalPrescriptions = await _getSingleInt(
        session,
        "SELECT COUNT(*) FROM prescriptions",
      );

      final medicinesDispensed = await _getSingleInt(
        session,
        "SELECT COALESCE(SUM(quantity),0) FROM dispensed_items",
      );

      final doctorCount = await _getSingleInt(
        session,
        "SELECT COUNT(*) FROM users WHERE role = 'DOCTOR'",
      );

      // ---------- PRESCRIPTION STATS ----------
      final prescriptionStats = PrescriptionStats(
        today: await _getSingleInt(
          session,
          "SELECT COUNT(*) FROM prescriptions WHERE prescription_date = CURRENT_DATE",
        ),
        week: await _getSingleInt(
          session,
          "SELECT COUNT(*) FROM prescriptions WHERE prescription_date >= CURRENT_DATE - INTERVAL '7 days'",
        ),
        month: await _getSingleInt(
          session,
          "SELECT COUNT(*) FROM prescriptions WHERE prescription_date >= DATE_TRUNC('month', CURRENT_DATE)",
        ),
        year: await _getSingleInt(
          session,
          "SELECT COUNT(*) FROM prescriptions WHERE prescription_date >= DATE_TRUNC('year', CURRENT_DATE)",
        ),
      );

      // ---------- MONTHLY BREAKDOWN WITH REVENUE ----------
      final monthlyRows = await session.db.unsafeQuery('''
  SELECT 
    EXTRACT(MONTH FROM tr.created_at)::INT AS month,
    COUNT(*)::INT AS total,
    SUM(CASE WHEN tr.patient_type='STUDENT' THEN 1 ELSE 0 END)::INT AS student,
    SUM(CASE WHEN tr.patient_type='TEACHER' THEN 1 ELSE 0 END)::INT AS teacher,
    SUM(CASE WHEN tr.patient_type='OUTSIDE' THEN 1 ELSE 0 END)::INT AS outside,
    COALESCE(SUM(
      CASE tr.patient_type
        WHEN 'STUDENT' THEN lt.student_fee
        WHEN 'TEACHER' THEN lt.teacher_fee
        WHEN 'OUTSIDE' THEN lt.outside_fee
      END
    ),0) AS revenue
  FROM test_results tr
  LEFT JOIN lab_tests lt ON tr.test_id = lt.test_id
  GROUP BY month
  ORDER BY month
''');

      final monthlyBreakdown = monthlyRows.map((r) {
        final m = r.toColumnMap();
        return MonthlyBreakdown(
          month: _toInt(m['month']),
          total: _toInt(m['total']),
          student: _toInt(m['student']),
          teacher: _toInt(m['teacher']),
          outside: _toInt(m['outside']),
          revenue: m['revenue'] != null ? double.parse(m['revenue'].toString()) : 0.0,
        );
      }).toList();





      // ---------- TOP MEDICINES ----------
      final topMedRows = await session.db.unsafeQuery('''
        SELECT medicine_name, SUM(quantity)::INT AS used
        FROM dispensed_items
        GROUP BY medicine_name
        ORDER BY used DESC
        LIMIT 5
      ''');

      final topMedicines = topMedRows.map((r) {
        final m = r.toColumnMap();
        return TopMedicine(
          medicineName: m['medicine_name'].toString(),
          used: _toInt(m['used']),
        );
      }).toList();

      // ---------- STOCK REPORT ----------
      final stockRows = await session.db.unsafeQuery('''
        SELECT 
          i.item_name,
          COALESCE(t.total_in,0)::INT AS previous,
          COALESCE(s.current_quantity,0)::INT AS current,
          COALESCE(t.total_out,0)::INT AS used
        FROM inventory_item i
        LEFT JOIN inventory_stock s ON i.item_id = s.item_id
        LEFT JOIN (
          SELECT item_id,
          SUM(CASE WHEN transaction_type='IN' THEN quantity ELSE 0 END) AS total_in,
          SUM(CASE WHEN transaction_type='OUT' THEN quantity ELSE 0 END) AS total_out
          FROM inventory_transaction
          GROUP BY item_id
        ) t ON i.item_id = t.item_id
      ''');

      final stockReport = stockRows.map((r) {
        final m = r.toColumnMap();
        return StockReport(
          itemName: m['item_name'].toString(),
          previous: _toInt(m['previous']),
          current: _toInt(m['current']),
          used: _toInt(m['used']),
        );
      }).toList();

      // ---------- FINAL RETURN ----------
      return DashboardAnalytics(
        totalPatients: totalPatients,
        outPatients: outPatients,
        totalPrescriptions: totalPrescriptions,
        medicinesDispensed: medicinesDispensed,
        doctorCount: doctorCount,
        patientCount: totalPatients,
        prescriptionStats: prescriptionStats,
        monthlyBreakdown: monthlyBreakdown,
        topMedicines: topMedicines,
        stockReport: stockReport,
      );
    } catch (e, st) {
      session.log(
        'Dashboard analytics error: $e',
        level: LogLevel.error,
        stackTrace: st,
      );
      rethrow;
    }
  }

  // ---------- HELPERS ----------

  // Robust integer parsing from Dynamic DB values
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<int> _getSingleInt(Session session, String query) async {
    final res = await session.db.unsafeQuery(query);
    if (res.isEmpty) return 0;
    final val = res.first.toColumnMap().values.first;
    return _toInt(val);
  }
}