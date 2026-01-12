import 'dart:math' as math;

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:backend_client/backend_client.dart';
class ExportService {
  static Future<void> exportDashboardAsPDF({
    required DashboardAnalytics analytics,
    required pw.Font font,
    required int selectedMonthIndex,
    required List<String> months,
  }) async {
    final pdf = pw.Document();
    final monthData = analytics.monthlyBreakdown[selectedMonthIndex];

    // Colors and styles
    const primary = PdfColors.indigo;
    const success = PdfColors.teal;
    const muted = PdfColors.grey600;

    final baseStyle = pw.TextStyle(font: font);
    final h2 = baseStyle.copyWith(fontSize: 16, fontWeight: pw.FontWeight.bold);
    final body = baseStyle.copyWith(fontSize: 11, color: PdfColors.black);
    final smallMuted = baseStyle.copyWith(fontSize: 9, color: muted);
    pw.Widget buildWatermark() {
      return pw.Center(
        child: pw.Transform.rotate(
          angle: math.pi/4,
          child: pw.Opacity(
            opacity: 0.10,
            child: pw.Text(
              'NSTU MEDICAL CENTER REPORT',
              style: pw.TextStyle(
                fontSize: 40,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ),
      );
    }

    pw.Widget sectionTitle(String title) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: h2),
          pw.SizedBox(height: 4),
          // pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
        ],
      );
    }

    pw.Widget tableCell(String text, {bool isHeader = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          text,
          style: isHeader
              ? baseStyle.copyWith(fontWeight: pw.FontWeight.bold)
              : body,
          textAlign: pw.TextAlign.center,
        ),
      );
    }

    final diseasesData = [
      {'label': 'Flu', 'value': 35.0, 'color': PdfColors.blue},
      {'label': 'Fever', 'value': 25.0, 'color': PdfColors.orange},
      {'label': 'Cold', 'value': 20.0, 'color': PdfColors.teal},
      {'label': 'Others', 'value': 20.0, 'color': PdfColors.red},
    ];


    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(70),
          theme: pw.ThemeData.withFont(
            base: font,
            bold: font,
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: buildWatermark(),
          ),
        ),
        header: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Dishari - Admin Dashboard',
                  style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold)),
              pw.Text('Report Generated: ${DateTime.now().toString().split(' ')[0]}',
                  style: smallMuted),
            ],
          ),
        ),
        build: (context) {
          final ratio = (analytics.patientCount /
              (analytics.doctorCount == 0 ? 1 : analytics.doctorCount))
              .toStringAsFixed(0);

          return [
            // 1. Header Banner
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                  color: primary, borderRadius: pw.BorderRadius.circular(12)),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Dashboard Analytics',
                          style: baseStyle.copyWith(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white)),
                      pw.Text('Overview of patients, activity and inventory',
                          style: baseStyle.copyWith(
                              color: PdfColors.white, fontSize: 11)),
                    ],
                  ),
                  pw.Text('Month: ${months[selectedMonthIndex]}',
                      style: baseStyle.copyWith(
                          color: PdfColors.white, fontSize: 10)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // 2. Key Metrics
            // 2. Key Metrics (CHANGED TO TABLE)
            sectionTitle('Key Metrics'),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    tableCell('Total Patients', isHeader: true),
                    tableCell('Outpatients', isHeader: true),
                    tableCell('Medicines Dispensed', isHeader: true),
                    tableCell('Prescriptions', isHeader: true),
                  ],
                ),
                // Data Row
                pw.TableRow(
                  children: [
                    tableCell('${analytics.totalPatients}'),
                    tableCell('${analytics.outPatients}'),
                    tableCell('${analytics.medicinesDispensed}'),
                    tableCell('${analytics.totalPrescriptions}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // 3. Prescription Activity (CHANGED TO TABLE)
            sectionTitle('Prescription Activity'),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    tableCell('Today', isHeader: true),
                    tableCell('This Week', isHeader: true),
                    tableCell('This Month', isHeader: true),
                    tableCell('This Year', isHeader: true),
                  ],
                ),
                // Data Row
                pw.TableRow(
                  children: [
                    tableCell('${analytics.prescriptionStats.today}'),
                    tableCell('${analytics.prescriptionStats.week}'),
                    tableCell('${analytics.prescriptionStats.month}'),
                    tableCell('${analytics.prescriptionStats.year}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 25),

            // 4. Doctor-Patient Ratio
            sectionTitle('Doctor-Patient Ratio'),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Doctors: ${analytics.doctorCount}', style: body),
                pw.Text('Total Patients: ${analytics.patientCount}', style: body),
                pw.Text('Ratio: 1 : $ratio',
                    style: body.copyWith(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber800)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              height: 10,
              width: double.infinity,
              decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(5),
                  color: PdfColors.grey200),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: analytics.doctorCount,
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            color: PdfColors.indigo,
                            borderRadius: pw.BorderRadius.circular(5))),
                  ),
                  pw.Expanded(
                    flex: analytics.patientCount,
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            color: success,
                            borderRadius: pw.BorderRadius.circular(5))),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 25),

            // 5. Monthly Breakdown
            sectionTitle('Lab Tests Breakdown (${months[selectedMonthIndex]})'),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Category',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Count / Revenue',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...[
                  ['Student', monthData.student],
                  ['Teacher/Family', monthData.teacher],
                  ['Outside', monthData.outside],
                  ['Total Patients', monthData.total],
                  ['Revenue', '\$${monthData.revenue}']
                ].map((r) => pw.TableRow(children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(r[0].toString(), style: body)),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(r[1].toString(), style: body)),
                ])),
              ],
            ),
            pw.SizedBox(height: 25),

            // 6. Top Diseases
            sectionTitle('Disease Trending'),
            pw.Row(
              children: [
                pw.SizedBox(
                  width: 100,
                  height: 100,
                  child: pw.Chart(
                    grid: pw.PieGrid(),
                    datasets: diseasesData
                        .map((e) => pw.PieDataSet(
                        value: e['value'] as double,
                        color: e['color'] as PdfColor,
                        drawSurface: true))
                        .toList(),
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: diseasesData
                      .map((e) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(children: [
                      pw.Container(
                          width: 8,
                          height: 8,
                          decoration: pw.BoxDecoration(
                              color: e['color'] as PdfColor,
                              shape: pw.BoxShape.circle)),
                      pw.SizedBox(width: 8),
                      pw.Text('${e['label']}: ${e['value']}%',
                          style: body),
                    ]),
                  ))
                      .toList(),
                ),
              ],
            ),
            pw.SizedBox(height: 25),

            // 7. Stock Report
            sectionTitle('Stock Report'),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Medicine', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Prev.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Current', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Used', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...analytics.stockReport.map((item) {
                  final double percentage = item.previous > 0 ? (item.current / item.previous) * 100 : 0;
                  final bool isLow = percentage < 30;

                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(item.itemName, style: body)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${item.previous}', style: body)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${item.current}', style: body)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${item.used}', style: body)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(isLow ? 'Low' : 'Good', style: body.copyWith(color: isLow ? PdfColors.red : PdfColors.green))),
                    ],
                  );


                }),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

}
