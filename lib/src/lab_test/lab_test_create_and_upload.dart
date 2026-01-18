// ignore_for_file: use_build_context_synchronously, duplicate_ignore, unnecessary_underscores

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:backend_client/backend_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cloudinary_upload.dart';
import '../date_time_utils.dart';
import '../route_refresh.dart';

class LabTestCreateAndUpload extends StatefulWidget {
  const LabTestCreateAndUpload({super.key});

  @override
  State<LabTestCreateAndUpload> createState() => _LabTestCreateAndUploadState();
}

class _LabTestCreateAndUploadState extends State<LabTestCreateAndUpload>
    with RouteRefreshMixin<LabTestCreateAndUpload> {
  List<TestResult> results = [];
  bool loading = true;
  // key: resultId, value: picked file data
  Map<int, Uint8List> pickedFiles = {};
  Map<int, String> pickedFileNames = {};

  // List of available lab tests fetched from backend
  List<LabTests> availableTests = [];

  Future<void> fetchTests() async {
    try {
      availableTests = await client.lab.getAllLabTests();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('Failed to fetch lab tests: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchResults();
    fetchTests();
  }

  @override
  Future<void> refreshOnFocus() async {
    await Future.wait([fetchResults(), fetchTests()]);
  }

  Future<void> fetchResults() async {
    setState(() => loading = true);
    results = await client.lab.getAllTestResults();
    setState(() => loading = false);
  }

  String fmt(DateTime? dt) {
    if (dt == null) return '';
    return AppDateTime.formatLocalDateTime(dt, pattern: 'dd/MM/yyyy HH:mm');
  }

  // Helper to display patient type nicely
  String _displayType(String? t) {
    if (t == null || t.isEmpty) return 'STUDENT';
    final s = t.toUpperCase();
    if (s == 'STUDENT') return 'Student';
    if (s == 'TEACHER') return 'Teacher';
    if (s == 'OUTSIDE') return 'Outside';
    return s[0] + s.substring(1).toLowerCase();
  }

  // ------------------ UPDATED TILE ------------------
  Widget buildTile(TestResult r) {
    final bytes = pickedFiles[r.resultId];
    final fileName = pickedFileNames[r.resultId];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          "${r.patientName} (${r.mobileNumber}) — ${_displayType(r.patientType)}",
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.submittedAt != null
                  ? "Result submitted"
                  : (r.isUploaded ? "File uploaded" : "No file selected"),
            ),
            Text(
              "Created: ${fmt(r.createdAt)}",
              style: const TextStyle(fontSize: 10),
            ),
            if (fileName != null)
              Text("Selected: $fileName", style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // View previous attachment if exists
            if (r.attachmentPath != null)
              IconButton(
                icon: const Icon(Icons.remove_red_eye),
                onPressed: () => _showPreviewDialog(r),
              ),

            // Pick File button
            if (r.submittedAt == null)
              IconButton(
                icon: const Icon(
                  Icons.file_upload_outlined,
                  color: Colors.orange,
                ),
                onPressed: () async {
                  final res = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    withData: true,
                  );
                  if (res != null && res.files.isNotEmpty) {
                    final file = res.files.first;
                    setState(() {
                      pickedFiles[r.resultId!] = file.bytes!;
                      pickedFileNames[r.resultId!] = file.name;
                    });
                  }
                },
              ),

            // Submit button (only if file selected)
            if (bytes != null && r.submittedAt == null)
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () async {
                  if (r.resultId == null) return;
                  setState(() => loading = true);

                  final pickedName =
                      fileName ??
                      'lab_report_${DateTime.now().millisecondsSinceEpoch}';
                  final isPdf = pickedName.toLowerCase().endsWith('.pdf');
                  final uploadedUrl = await CloudinaryUpload.uploadBytes(
                    bytes: bytes,
                    folder: 'lab_reports',
                    fileName: pickedName,
                    isPdf: isPdf,
                  );

                  if (uploadedUrl == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cloudinary upload failed')),
                    );
                    setState(() => loading = false);
                    return;
                  }

                  final ok = await client.lab.submitResultWithUrl(
                    resultId: r.resultId!,
                    attachmentUrl: uploadedUrl,
                  );

                  if (ok) {
                    setState(() {
                      r.submittedAt = DateTime.now();
                      r.isUploaded = true;
                      r.attachmentPath = uploadedUrl;
                      pickedFiles.remove(r.resultId);
                      pickedFileNames.remove(r.resultId);
                    });
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Result submitted')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Submit failed')),
                    );
                  }

                  setState(() => loading = false);
                },
              ),

            // Completed icon
            if (r.submittedAt != null)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  // Optimized Preview Dialog for Web/Mobile
  void _showPreviewDialog(TestResult r) {
    if (r.attachmentPath == null) return;

    final String url = r.attachmentPath!;
    final bool isPdf = url.toLowerCase().endsWith('.pdf');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16), // screen margin
        child: isPdf
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 🔴 no extra height
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "PDF Document",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("Open PDF"),
                      onPressed: () => _launchURL(url),
                    ),
                  ],
                ),
              )
            : InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  url,
                  fit: BoxFit.contain, // 🔥 exact image size
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(40),
                    child: Text("Failed to load image"),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _launchURL(String urlPath) async {
    final Uri url = Uri.parse(urlPath);
    try {
      // LaunchMode.externalApplication দিলে Web-এ নতুন ট্যাব এবং
      // Mobile-এ ডিফল্ট ব্রাউজার/PDF Viewer ব্যবহার করবে।
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  // ... rest of fetch methods ...
  // ------------------ CREATE TEST ------------------
  void openCreateDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    LabTests? selectedTest;
    String selectedPatientType = 'STUDENT';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // final formKey = GlobalKey<FormState>();

          return AlertDialog(
            title: const Text("Create Test"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Test selector fetched from backend
                  if (availableTests.isEmpty)
                    const Text('No tests available')
                  else
                    DropdownButtonFormField<LabTests>(
                      decoration: const InputDecoration(
                        labelText: 'Select Test',
                        border: OutlineInputBorder(),
                      ),
                      items: availableTests
                          .map(
                            (t) => DropdownMenuItem<LabTests>(
                              value: t,
                              child: Text(t.testName),
                            ),
                          )
                          .toList(),
                      initialValue: selectedTest,
                      onChanged: (v) => setDialogState(() => selectedTest = v),
                      validator: (v) =>
                          v == null ? 'Please select a test' : null,
                    ),
                  const SizedBox(height: 12),
                  // Patient Type dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Patient Type',
                      border: OutlineInputBorder(),
                    ),
                    // Bind current selection via `initialValue` so rebuilds show correct choice
                    initialValue: selectedPatientType,
                    items: const [
                      DropdownMenuItem(
                        value: 'STUDENT',
                        child: Text('STUDENT'),
                      ),
                      DropdownMenuItem(
                        value: 'TEACHER',
                        child: Text('TEACHER'),
                      ),
                      DropdownMenuItem(
                        value: 'OUTSIDE',
                        child: Text('OUTSIDE'),
                      ),
                    ],
                    onChanged: (v) => setDialogState(() {
                      selectedPatientType = v ?? 'STUDENT';
                      debugPrint('Selected patientType: $selectedPatientType');
                    }),
                    validator: (v) => v == null ? 'Please select type' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Patient Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: mobileCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    decoration: const InputDecoration(
                      labelText: "Mobile Number",
                      prefixText: '+88 ',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Mobile number is required';
                      }
                      final digitsOnly = RegExp(r'^0\d{10}$');
                      if (!digitsOnly.hasMatch(v.trim())) {
                        return 'Enter 11 digits after +88';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;

                  final name = nameCtrl.text.trim();
                  final mobilePart = mobileCtrl.text.trim();

                  if (selectedTest == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a test')),
                    );
                    return;
                  }

                  final testId = selectedTest!.id;
                  if (testId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selected test has no id in database'),
                      ),
                    );
                    return;
                  }

                  final mobileNumber = '+88$mobilePart';

                  // Read selected patient type from dialog state; default to STUDENT
                  final patientType = selectedPatientType;
                  debugPrint('Creating test with patientType: $patientType');

                  await client.lab.createTestResult(
                    testId: testId,
                    patientName: name,
                    mobileNumber: mobileNumber,
                    patientType: patientType,
                  );

                  Navigator.pop(ctx);
                  fetchResults();
                },
                child: const Text("Create"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    final pending = results.where((r) => r.submittedAt == null).toList();
    final completed = results.where((r) => r.submittedAt != null).toList();

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refreshFromPull,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                children: [
                  const Center(
                    child: Text(
                      "Pending Upload",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (pending.isEmpty)
                    const Center(child: Text("No pending results")),
                  ...pending.map(buildTile),

                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      "Completed",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (completed.isEmpty)
                    const Center(child: Text("No completed results")),
                  ...completed.map(buildTile),
                ],
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: openCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
