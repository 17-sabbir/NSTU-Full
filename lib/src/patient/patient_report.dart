import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:backend_client/backend_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientReports extends StatefulWidget {
  const PatientReports({super.key});

  @override
  State<PatientReports> createState() => _PatientReportsState();
}

class _PatientReportsState extends State<PatientReports> {
  final Color kPrimaryColor = const Color(0xFF00796B);

  bool isLoading = true;
  List<PatientReportDto> reports = [];

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // SAME key as dashboard
      final storedUserId = prefs.getString('user_id');

      if (storedUserId == null || storedUserId.isEmpty) {
        debugPrint("User not logged in (no user_id)");
        return;
      }

      final int? userId = int.tryParse(storedUserId);
      if (userId == null) {
        debugPrint("Invalid user_id format");
        return;
      }

      final data = await client.patient.getMyLabReports(userId);
      setState(() {
        reports = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to load reports: $e");
      setState(() => isLoading = false);
    }
  }
  Future<void> downloadReportFromLink(String url) async {
    // debugPrint("ORIGINAL URL = $url");

    final downloadUrl = url.replaceFirst(
      '/image/upload/',
      '/image/upload/fl_attachment/',
    );

    // debugPrint("DOWNLOAD URL = $downloadUrl");

    final uri = Uri.parse(downloadUrl);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "My Reports",
          style: TextStyle(color: Colors.blueAccent),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
          ? const Center(child: Text("No reports found"))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                report.testName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_month_outlined, size: 18),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormat('yyyy-MM-dd').format(report.date),
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          report.isUploaded
                              ? "Report available"
                              : "Report not uploaded yet",
                          style: TextStyle(
                            color: report.isUploaded
                                ? Colors.green
                                : Colors.red,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                onPressed:
                                    report.isUploaded && report.fileUrl != null
                                    ? () => downloadReportFromLink(
                                        report.fileUrl!,
                                      )
                                    : null,
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text("Download"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
