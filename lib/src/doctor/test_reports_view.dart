import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
// Clipboard
import 'package:backend_client/backend_client.dart'; // আপনার ক্লায়েন্ট ইমপোর্ট করুন
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TestReportsView extends StatefulWidget {
  final int doctorId;
  const TestReportsView({super.key, required this.doctorId});

  @override
  State<TestReportsView> createState() => _TestReportsViewState();
}

class _TestReportsViewState extends State<TestReportsView> {
  List<PatientExternalReport> _reports = [];
  bool _isLoading = true;
  String? _error;
  bool sheetOpen = true;
  bool isPrefillLoading = true;
  bool isSubmitting = false;
  final TextEditingController adviceController = TextEditingController();
  final List<Map<String, dynamic>> itemCtrls = [];
  List<String?> nameErrors = [];
  List<String?> durationErrors = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  @override
  void dispose() {
    adviceController.dispose();

    for (final m in itemCtrls) {
      (m['name'] as TextEditingController?)?.dispose();
      (m['duration'] as TextEditingController?)?.dispose();
      (m['mealTime'] as TextEditingController?)?.dispose();
      (m['dosage'] as TextEditingController?)?.dispose();
      (m['mealTiming'] as ValueNotifier<String?>?)?.dispose();
    }

    super.dispose();
  }

  bool _isPdf(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  bool _isImage(String url) {
    return url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.webp');
  }

  Future<void> _openPdfInApp(String url) async {
    if (kIsWeb) {
      await launchUrl(Uri.parse(url));
      return;
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load PDF');
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/report.pdf');
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Report PDF')),
            body: PDFView(filePath: file.path),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open PDF: $e')));
    }
  }

  Future<void> _fetchReports() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await client.doctor.getReportsForDoctor(widget.doctorId);
      if (!mounted) return;
      setState(() {
        _reports = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // review a click korle bottom sheet UI (interactive)
  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.blue.shade700),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ],
    );
  }

  Future<void> _onReviewReport(PatientExternalReport report) async {
    sheetOpen = true;
    isPrefillLoading = true;
    isSubmitting = false;
    itemCtrls.clear();
    if (report.prescriptionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This report has no prescription linked.'),
        ),
      );
      return;
    }

    void addEmptyRow() {
      setState(() {
        itemCtrls.add({
          'name': TextEditingController(),
          'duration': TextEditingController(),
          'mealTime': TextEditingController(),
          'mealTiming': ValueNotifier<String?>(null),
          'dosage': TextEditingController(),
        });
        nameErrors.add(null);
        durationErrors.add(null);
      });
    }

    // ensure at least one row exists so submit doesn't send empty list unintentionally
    void ensureAtLeastOneRow() {
      if (itemCtrls.isEmpty) addEmptyRow();
    }

    List<PrescribedItem> buildItems(int prescriptionId) {
      final items = <PrescribedItem>[];

      for (final m in itemCtrls) {
        final name = (m['name'] as TextEditingController).text.trim();
        final durationText = (m['duration'] as TextEditingController).text
            .trim();
        final dosageTimes = (m['dosage'] as TextEditingController).text.trim();
        final mealTiming = (m['mealTiming'] as ValueNotifier<String?>).value;
        final mealTime = (m['mealTime'] as TextEditingController).text.trim();

        if (name.isEmpty) continue;

        final duration = durationText.isEmpty
            ? null
            : int.tryParse(durationText);
        if (duration == null) {
          // skip invalid item (validation happens before submit too)
          continue;
        }

        // Combine time + before/after (like prescription_page.dart)
        // Combine time before/after (never save null if user provided time)
        String? combinedMealTiming;

        // if checkbox not selected but time is given -> default to 'before'
        final normalizedTiming = (mealTiming != null && mealTiming.isNotEmpty)
            ? mealTiming
            : (mealTime.isNotEmpty ? 'before' : null);

        if (normalizedTiming != null && normalizedTiming.isNotEmpty) {
          combinedMealTiming = mealTime.isEmpty
              ? normalizedTiming
              : '$mealTime $normalizedTiming';
        }

        // IMPORTANT: backend creates a NEW prescription id; do not bind items to old id from client.
        items.add(
          PrescribedItem(
            prescriptionId: 0,
            medicineName: name,
            dosageTimes: dosageTimes.isEmpty ? null : dosageTimes,
            mealTiming: combinedMealTiming,
            duration: duration,
          ),
        );
      }

      return items;
    }

    String buildCloudinaryDownloadUrl(String url) {
      if (url.isEmpty) return url;

      // image urls
      if (url.contains('/image/upload/')) {
        return url.replaceFirst(
          '/image/upload/',
          '/image/upload/fl_attachment/',
        );
      }

      // raw urls (pdf usually)
      if (url.contains('/raw/upload/')) {
        return url.replaceFirst('/raw/upload/', '/raw/upload/fl_attachment/');
      }

      // fallback: general /upload/
      if (url.contains('/upload/')) {
        return url.replaceFirst('/upload/', '/upload/fl_attachment/');
      }

      return url;
    }

    Future<void> prefillFromExisting(StateSetter setSheetState) async {
      try {
        debugPrint('Prefill prescriptionId=${report.prescriptionId}');

        final detail = await client.doctor.getPrescriptionDetails(
          prescriptionId: report.prescriptionId!,
        );

        if (detail == null) {
          setSheetState(() => addEmptyRow());
          return;
        }

        final existingAdvice = (detail.advice ?? '').trim();
        setSheetState(() {
          adviceController.text = existingAdvice;
          itemCtrls.clear();
        });

        for (final item in detail.items) {
          final dosageText = item.dosageTimes ?? '';

          final raw = (item.mealTiming ?? '').trim();
          final lower = raw.toLowerCase();

          String? selectedTiming;
          String timePart = raw;

          if (lower.contains('before') || lower.contains('আগে')) {
            selectedTiming = 'before';
            timePart = raw
                .replaceAll(RegExp('before', caseSensitive: false), '')
                .replaceAll('আগে', '')
                .trim();
          } else if (lower.contains('after') || lower.contains('পরে')) {
            selectedTiming = 'after';
            timePart = raw
                .replaceAll(RegExp('after', caseSensitive: false), '')
                .replaceAll('পরে', '')
                .trim();
          }

          timePart = timePart
              .replaceAll(',', ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          debugPrint('DB mealTiming raw="${item.mealTiming}"');
          debugPrint(
            'Parsed selectedTiming="$selectedTiming", timePart="$timePart"',
          );
          setSheetState(() {
            itemCtrls.add({
              'name': TextEditingController(text: item.medicineName),
              'duration': TextEditingController(
                text: item.duration?.toString() ?? '',
              ),
              'mealTime': TextEditingController(text: timePart),
              'mealTiming': ValueNotifier<String?>(selectedTiming),
              'dosage': TextEditingController(text: dosageText),
            });
          });
        }

        if (itemCtrls.isEmpty) {
          setSheetState(() => addEmptyRow());
        }
      } catch (e) {
        debugPrint('Prefill error: $e');
        setSheetState(() => addEmptyRow());
      }
    }

    // --- Only DB stored URL ---
    String? previewUrl;

    void loadDbUrl(StateSetter setSheetState) {
      if (previewUrl != null) return;
      previewUrl = report.filePath; // direct DB value
      if (!sheetOpen) return;
      setSheetState(() {});
    }

    Widget buildReportPreview(String url) {
      if (url.isEmpty) {
        return const Text('No file available');
      }

      // IMAGE PREVIEW (tappable -> full screen)
      if (_isImage(url)) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                if (!mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullScreenImagePage(imageUrl: url),
                  ),
                );
              },
              child: Hero(
                tag: url,
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 5.0,
                  panEnabled: true,
                  scaleEnabled: true,
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    url,
                    fit: BoxFit.fitWidth,
                    loadingBuilder: (c, w, p) {
                      if (p == null) return w;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text('Failed to load image')),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      // PDF PREVIEW (same pattern as prescription)
      if (_isPdf(url)) {
        return InkWell(
          onTap: () {
            _openPdfInApp(url);
          },
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0x1AFF0000),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                SizedBox(height: 10),
                Text(
                  'Tap to open PDF',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Text(
          'Unsupported file format',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          // kick off prefill once
          if (isPrefillLoading) {
            isPrefillLoading = false;
            prefillFromExisting(setSheetState).whenComplete(() {
              if (!sheetOpen) return;
              setSheetState(() {});
            });
          }

          if (previewUrl == null) {
            loadDbUrl(setSheetState);
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header card (improved)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.blue.shade300,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.fact_check,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Review Report',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                report.type,
                                style: TextStyle(
                                  color: Colors.blueGrey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            sheetOpen = false;
                            Navigator.of(sheetContext).pop();
                          },

                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.close, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Preview spot now shows link only
                  if (previewUrl != null) ...[
                    buildReportPreview(previewUrl!),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final dl = buildCloudinaryDownloadUrl(previewUrl!);
                          await launchUrl(
                            Uri.parse(dl),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 14),

                  // Prescription editor section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0B000000),
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionTitle(Icons.edit_note, 'Update prescription'),
                        const SizedBox(height: 12),
                        TextField(
                          controller: adviceController,
                          decoration: InputDecoration(
                            labelText: 'New Advice',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue.shade400,
                                width: 1.5,
                              ),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        _sectionTitle(
                          Icons.medication_outlined,
                          'Medicines (edit + add)',
                        ),
                        const SizedBox(height: 10),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: itemCtrls.length,
                          itemBuilder: (context, index) {
                            final row = itemCtrls[index];
                            final nameCtrl =
                                row['name'] as TextEditingController;
                            final durationCtrl =
                                row['duration'] as TextEditingController;
                            final mealTimeCtrl =
                                row['mealTime'] as TextEditingController;
                            final mealTiming =
                                row['mealTiming'] as ValueNotifier<String?>;
                            final dosageCtrl =
                                row['dosage'] as TextEditingController;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Medicine #${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Remove',
                                        onPressed: itemCtrls.length <= 1
                                            ? null
                                            : () {
                                                setSheetState(() {
                                                  itemCtrls.removeAt(index);
                                                });
                                              },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: itemCtrls.length <= 1
                                              ? Colors.grey
                                              : Colors.red.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  TextField(
                                    controller: nameCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'Medication Name',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: dosageCtrl,
                                          decoration: InputDecoration(
                                            labelText: 'Dosage Times',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 120,
                                        child: TextField(
                                          controller: durationCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Duration',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        child: TextField(
                                          controller: mealTimeCtrl,
                                          decoration: InputDecoration(
                                            labelText: 'Time',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ValueListenableBuilder<String?>(
                                          valueListenable: mealTiming,
                                          builder: (context, val, child) {
                                            return Wrap(
                                              spacing: 12,
                                              runSpacing: 6,
                                              children: [
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  onTap: () {
                                                    mealTiming.value =
                                                        val == 'before'
                                                        ? null
                                                        : 'before';
                                                    setSheetState(() {});
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Checkbox(
                                                        value: val == 'before',
                                                        onChanged: (v) {
                                                          mealTiming.value =
                                                              v == true
                                                              ? 'before'
                                                              : null;
                                                          setSheetState(() {});
                                                        },
                                                      ),
                                                      const Text('খাবার আগে'),
                                                    ],
                                                  ),
                                                ),
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  onTap: () {
                                                    mealTiming.value =
                                                        val == 'after'
                                                        ? null
                                                        : 'after';
                                                    setSheetState(() {});
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Checkbox(
                                                        value: val == 'after',
                                                        onChanged: (v) {
                                                          mealTiming.value =
                                                              v == true
                                                              ? 'after'
                                                              : null;
                                                          setSheetState(() {});
                                                        },
                                                      ),
                                                      const Text('খাবার পরে'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              setSheetState(() {
                                addEmptyRow();
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add medicine'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue.shade700,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    final advice = adviceController.text.trim();

                                    if (advice.isEmpty) {
                                      ScaffoldMessenger.of(
                                        sheetContext,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Advice is required'),
                                        ),
                                      );
                                      return;
                                    }

                                    ensureAtLeastOneRow();

                                    // extra validation: at least one medicine with valid duration
                                    final hasAnyMedicine = itemCtrls.any((m) {
                                      final name =
                                          (m['name'] as TextEditingController)
                                              .text
                                              .trim();
                                      return name.isNotEmpty;
                                    });
                                    if (!hasAnyMedicine) {
                                      ScaffoldMessenger.of(
                                        sheetContext,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please add at least 1 medicine',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // Build items (backend will attach to new prescription id)
                                    final items = buildItems(
                                      report.prescriptionId!,
                                    );
                                    if (items.isEmpty) {
                                      ScaffoldMessenger.of(
                                        sheetContext,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please provide valid duration for medicines',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final rootMessenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    final sheetMessenger = ScaffoldMessenger.of(
                                      sheetContext,
                                    );
                                    final navigator = Navigator.of(
                                      sheetContext,
                                    );

                                    setSheetState(() => isSubmitting = true);
                                    try {
                                      final newId = await client.doctor
                                          .revisePrescription(
                                            originalPrescriptionId:
                                                report.prescriptionId!,
                                            newAdvice: advice,
                                            newItems: items,
                                          );

                                      if (!mounted) return;

                                      if (newId <= 0) {
                                        setSheetState(
                                          () => isSubmitting = false,
                                        );
                                        sheetMessenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Failed to save revised prescription',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      navigator.pop();
                                      rootMessenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Prescription revised successfully',
                                          ),
                                        ),
                                      );
                                      _fetchReports();
                                    } catch (e) {
                                      setSheetState(() => isSubmitting = false);
                                      sheetMessenger.showSnackBar(
                                        SnackBar(content: Text('Failed: $e')),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isSubmitting
                                  ? const SizedBox(
                                      key: ValueKey('loading'),
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Submit',
                                      key: ValueKey('submit'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      sheetOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Review Test Reports',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              await Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _fetchReports,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Failed to load reports',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchReports,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _reports.isEmpty
          ? const Center(child: Text('No reports found'))
          : RefreshIndicator(
              onRefresh: _fetchReports,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                itemCount: _reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  final createdAt = report.createdAt;
                  final dateText = createdAt == null
                      ? '-'
                      : '${createdAt.year.toString().padLeft(4, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

                  final isPdf = report.filePath.toLowerCase().endsWith('.pdf');

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _onReviewReport(report),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0B000000),
                            blurRadius: 10,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: isPdf
                                  ? const Color(0x1AFF0000)
                                  : const Color(0x1A607D8B),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isPdf
                                  ? Icons.picture_as_pdf
                                  : Icons.insert_drive_file,
                              color: isPdf ? Colors.red : Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.type,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Date: $dateText',
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade700,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade600,
                                  Colors.blue.shade400,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class FullScreenImagePage extends StatefulWidget {
  final String imageUrl;
  const FullScreenImagePage({Key? key, required this.imageUrl})
    : super(key: key);

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  AnimationController? _animationController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animationController!.addListener(() {
      if (_animation != null) {
        _transformationController.value = _animation!.value;
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails?.localPosition ?? Offset.zero;
    final current = _transformationController.value;
    final identity = Matrix4.identity();

    if (!mounted) return;

    // If currently zoomed, animate back to identity
    if (current != identity) {
      _animation = Matrix4Tween(begin: current, end: identity).animate(
        CurveTween(curve: Curves.easeOut).animate(_animationController!),
      );
      _animationController!..forward(from: 0);
      return;
    }

    // Otherwise zoom in centered on the tapped position
    const double zoom = 3.0;
    final renderBox = context.findRenderObject() as RenderBox?;
    final _ = renderBox?.size ?? MediaQuery.of(context).size;
    final dx = position.dx;
    final dy = position.dy;

    // Compute translation so the tapped point stays roughly under the finger when scaled
    final translateX = -dx * (zoom - 1);
    final translateY = -dy * (zoom - 1);

    final Matrix4 target = Matrix4.identity()
      ..translate(translateX, translateY)
      ..scale(zoom);

    _animation = Matrix4Tween(
      begin: current,
      end: target,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_animationController!));
    _animationController!..forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Fullscreen InteractiveViewer
            Positioned.fill(
              child: GestureDetector(
                onDoubleTapDown: (details) => _doubleTapDetails = details,
                onDoubleTap: _handleDoubleTap,
                child: Hero(
                  tag: widget.imageUrl,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
                    maxScale: 5.0,
                    panEnabled: true,
                    scaleEnabled: true,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: Image.network(
                          widget.imageUrl,
                          // set a reasonable width/height so FittedBox can size correctly
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          loadingBuilder: (c, w, p) {
                            if (p == null) return w;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Close button overlay (top-left)
            Positioned(
              left: 12,
              top: 12,
              child: Material(
                color: Colors.black38,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
