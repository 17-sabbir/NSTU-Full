import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:backend_client/backend_client.dart';

// DESIGN: central theme colors and typography for this page
const Color _accent = Color(0xFF0EA5A5); // teal-ish
const Color _muted = Color(0xFF6B7280);

TextStyle _titleStyle = const TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w700,
  color: Colors.black87,
);
TextStyle _sectionLabel = const TextStyle(
  fontWeight: FontWeight.w600,
  color: Colors.black87,
);
InputDecoration _roundedInputDecoration([String? hint]) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: Colors.grey.shade50,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.grey.shade200),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: _accent),
  ),
);

class Medicine {
  TextEditingController nameController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController mealTimeController = TextEditingController();

  Map<String, bool> times = {'সকাল': true, 'দুপুর': true, 'রাত': true};
  int timesPerDay = 3;

  // only before / after
  String? mealTiming;

  // UI only
  String durationUnit = 'দিন';
}


class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({super.key});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  // patient controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  String? _selectedGender;

  // whether the current prescription has been successfully saved
  bool _isSaved = false;

  // Validation error messages for patient fields
  String? _nameError;
  String? _numberError;
  String? _ageError;
  String? _genderError;

  // Per-medicine validation errors (parallel to _medicineRows)
  List<String?> _medicineNameErrors = [];
  List<String?> _medicineDurationErrors = [];
  List<String?> _medicineMealErrors = [];

  // Doctor info for signature display
  String? _doctorSignatureUrl;
  String? _doctorName;
  bool _loadingDoctorInfo = true;

  // clinical notes
  final TextEditingController _complainController = TextEditingController();
  final TextEditingController _examinationController = TextEditingController();
  final TextEditingController _adviceController = TextEditingController();
  final TextEditingController _testsController = TextEditingController();

  // prescriptions
  final List<Medicine> _medicineRows = [];

  // misc
  final TextEditingController _nextVisitController = TextEditingController();
  bool _isOutside = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _addMedicineRow();
    // mark unsaved when any main field changes
    _nameController.addListener(_markUnsaved);
    _rollController.addListener(_markUnsaved);
    _ageController.addListener(_markUnsaved);
    _genderController.addListener(_markUnsaved);
    _complainController.addListener(_markUnsaved);
    _examinationController.addListener(_markUnsaved);
    _adviceController.addListener(_markUnsaved);
    _testsController.addListener(_markUnsaved);
    _nextVisitController.addListener(_markUnsaved);
    // Load doctor info (name + signature) for display
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDoctorInfo();
    });
  }

  Future<void> _loadDoctorInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('user_id');
      final id = int.tryParse(stored ?? '');
      if (id == null) {
        setState(() => _loadingDoctorInfo = false);
        return;
      }
      final info = await client.doctor.getDoctorInfo(id);
      setState(() {
        _doctorName = info['name'] ?? '';
        // server returns signature under key 'signature' (prescription_page.dart uses this)
        _doctorSignatureUrl =
            info['signature'] ?? info['signatureUrl'] ?? info['signature_url'];
      });
    } catch (e) {
      debugPrint('Failed to load doctor info: $e');
    } finally {
      if (mounted) setState(() => _loadingDoctorInfo = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _complainController.dispose();
    _examinationController.dispose();
    _adviceController.dispose();
    _testsController.dispose();
    _nextVisitController.dispose();
    for (var m in _medicineRows) {
      m.nameController.dispose();
      m.durationController.dispose();
      m.mealTimeController.dispose();
    }
    super.dispose();
  }

  void _addMedicineRow() {
    setState(() {
      _medicineRows.add(Medicine());
      // keep error arrays in sync
      _medicineNameErrors.add(null);
      _medicineDurationErrors.add(null);
      _medicineMealErrors.add(null);
      // listen to medicine fields to mark unsaved
      final m = _medicineRows.last;
      m.nameController.addListener(_markUnsaved);
      m.durationController.addListener(_markUnsaved);
      m.mealTimeController.addListener(_markUnsaved);
    });
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _rollController.clear();
      _ageController.clear();
      _genderController.clear();
      _selectedGender = null;
      // clear patient errors
      _nameError = null;
      _numberError = null;
      _ageError = null;
      _genderError = null;

      _complainController.clear();
      _examinationController.clear();
      _adviceController.clear();
      _testsController.clear();
      _nextVisitController.clear();
      for (var m in _medicineRows) {
        m.nameController.clear();
        m.durationController.clear();
        m.times = {'সকাল': true, 'দুপুর': true, 'রাত': true};
        m.timesPerDay = 3;
        m.mealTiming = null;
        m.mealTimeController.clear();
        m.durationUnit = 'দিন';
      }
      // reset medicine errors
      _medicineNameErrors = List<String?>.filled(_medicineRows.length, null);
      _medicineDurationErrors = List<String?>.filled(
        _medicineRows.length,
        null,
      );
      _medicineMealErrors = List<String?>.filled(_medicineRows.length, null);
      if (_medicineRows.isEmpty) _addMedicineRow();
      // clearing makes the form unsaved
      _isSaved = false;
    });
  }

  void _markUnsaved() {
    if (_isSaved) {
      setState(() {
        _isSaved = false;
      });
    }
  }

  void _markSaved() {
    if (!_isSaved) {
      setState(() {
        _isSaved = true;
      });
    }
  }

  /// Validate the form. Returns true if valid, otherwise sets error messages and returns false.
  bool _validateForm() {
    bool ok = true;

    // reset errors
    _nameError = null;
    _numberError = null;
    _ageError = null;
    _genderError = null;
    _medicineNameErrors = List<String?>.filled(_medicineRows.length, null);
    _medicineDurationErrors = List<String?>.filled(_medicineRows.length, null);
    _medicineMealErrors = List<String?>.filled(_medicineRows.length, null);

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _nameError = 'Name is required';
      ok = false;
    }

    // Inside _validateForm()
    final number = _rollController.text
        .trim(); // Controller only holds the 11 digits
    if (number.isEmpty) {
      _numberError = 'Number is required';
      ok = false;
    } else if (number.length != 11) {
      _numberError = 'Number must be 11 digits';
      ok = false;
    }

    final age = _ageController.text.trim();
    if (age.isEmpty) {
      _ageError = 'Age is required';
      ok = false;
    }

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      _genderError = 'Gender is required';
      ok = false;
    }

    // At least one medicine with a name
    bool hasMedicine = false;
    for (var i = 0; i < _medicineRows.length; i++) {
      final m = _medicineRows[i];
      final mName = m.nameController.text.trim();
      if (mName.isNotEmpty) hasMedicine = true;

      if (mName.isEmpty) {
        _medicineNameErrors[i] = 'Medicine name is required';
        ok = false;
      }

      // duration required
      final dur = m.durationController.text.trim();
      if (dur.isEmpty) {
        _medicineDurationErrors[i] = 'Duration is required';
        ok = false;
      } else if (int.tryParse(dur) == null) {
        _medicineDurationErrors[i] = 'Duration must be a number';
        ok = false;
      }

      // meal timing required (khabar age/por)
      if (m.mealTiming == null || m.mealTiming!.isEmpty) {
        _medicineMealErrors[i] = 'Select খাবার আগে/পরে';
        ok = false;
      }
    }

    if (!hasMedicine) {
      // mark first medicine name error as general
      if (_medicineRows.isNotEmpty) {
        _medicineNameErrors[0] = 'Add at least one medicine';
      }
      ok = false;
    }

    setState(() {});
    return ok;
  }

  void _savePrescription() async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorId = int.tryParse(prefs.getString('user_id') ?? '');

      if (doctorId == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doctor ID not found')));
        return;
      }

      // 1. Process Next Visit Text
      final rawNext = _nextVisitController.text.trim();
      String? formattedNextVisit = rawNext.isEmpty ? null : rawNext;

      // 2. Create Prescription Object
      final prescription = Prescription(
        doctorId: doctorId,
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        mobileNumber: "+88${_rollController.text.trim()}",
        gender: _selectedGender,
        prescriptionDate: DateTime.now(),
        cc: _complainController.text.trim(),
        oe: _examinationController.text.trim(),
        advice: _adviceController.text.trim(),
        test: _testsController.text.trim(),
        nextVisit: formattedNextVisit,
        isOutside: _isOutside,
      );

      // 3. Process Medicine Items
      final items = <PrescribedItem>[];
      for (var m in _medicineRows) {
        if (m.nameController.text.trim().isEmpty) continue;

        // Combine time and timing (e.g., "30 min before")
        String? mealTiming;
        if (m.mealTiming != null) {
          final timeVal = m.mealTimeController.text.trim();
          mealTiming = timeVal.isEmpty ? m.mealTiming : "$timeVal ${m.mealTiming}";
        }

        // Calculate duration in days (DB expects INTEGER)
        int? durationInDays = int.tryParse(m.durationController.text.trim());
        if (durationInDays != null && m.durationUnit == 'মাস') {
          durationInDays = durationInDays * 30; // Convert months to days for DB int
        }

        // Format Dosage
        String dosage = m.times.entries.where((e) => e.value).map((e) => e.key).join(', ');
        if (dosage.isEmpty) dosage = '${m.timesPerDay} times daily';

        items.add(PrescribedItem(
          prescriptionId: 0, // Placeholder
          medicineName: m.nameController.text.trim(),
          dosageTimes: dosage, // Ensure this matches your generated model field name
          mealTiming: mealTiming,
          duration: durationInDays,
        ));
      }

      // 4. Send to Backend
      final resultId = await client.doctor.createPrescription(
        prescription,
        items,
        _rollController.text.trim(), // Backend handles the +88 normalization
      );

      if (resultId > 0) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prescription saved successfully!')));
        _markSaved();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildLargeCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(title, style: _titleStyle),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(14), child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller, {String hint = ''}) {
    return TextField(
      controller: controller,
      maxLines: null,
      decoration: _roundedInputDecoration(hint),
    );
  }

  // Modified to accept an optional index and display a small numbered badge
  Widget _buildMedicineCard(Medicine medicine, [int? index]) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (index != null)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _accent.withAlpha(31),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _accent,
                      ),
                    ),
                  ),
                ),
              if (index != null) const SizedBox(width: 12),
              Text('Medication Name', style: _sectionLabel),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: medicine.nameController,
            decoration: _roundedInputDecoration('Medicine name'),
          ),
          if (_medicineNameErrors[index ?? 0] != null) ...[
            const SizedBox(height: 6),
            Text(
              _medicineNameErrors[index ?? 0]!,
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
          ],
          const SizedBox(height: 10),
          Text('Dosage Times', style: _sectionLabel),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<int>(
                  value: medicine.timesPerDay,
                  underline: const SizedBox.shrink(),
                  items: List.generate(6, (i) => i + 3)
                      .map(
                        (n) => DropdownMenuItem(
                      value: n,
                      child: Text(n.toString()),
                    ),
                  )
                      .toList(),
                  onChanged: (v) => setState(() {
                    medicine.timesPerDay = v ?? 3;
                    _markUnsaved();
                  }),
                ),
              ),
              const SizedBox(width: 12),
              if (medicine.timesPerDay == 3)
                Wrap(
                  spacing: 10,
                  children: medicine.times.keys.map((key) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: medicine.times[key],
                            onChanged: (v) => setState(() {
                              medicine.times[key] = v ?? false;
                              _markUnsaved();
                            }),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(key, style: const TextStyle(color: _muted)),
                      ],
                    );
                  }).toList(),
                )
              else
                Text(
                  'Every ${(24 / medicine.timesPerDay).round()} hours',
                  style: const TextStyle(color: _muted),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Insert a small "time" input field (hint: "time") before the meal timing checkboxes
          Row(
            children: [
              SizedBox(
                width: 110,
                child: TextField(
                  controller: medicine.mealTimeController,
                  decoration: InputDecoration(
                    hintText: 'time',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _accent),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: medicine.mealTiming == 'before',
                    onChanged: (v) => setState(() {
                      medicine.mealTiming = v == true ? 'before' : null;
                      _markUnsaved();
                    }),
                  ),
                  const SizedBox(width: 6),
                  const Text('খাবার আগে'),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: medicine.mealTiming == 'after',
                    onChanged: (v) => setState(() {
                      medicine.mealTiming = v == true ? 'after' : null;
                      _markUnsaved();
                    }),
                  ),
                  const SizedBox(width: 6),
                  const Text('খাবার পরে'),
                ],
              ),
            ],
          ),
          if (_medicineMealErrors[index ?? 0] != null) ...[
            const SizedBox(height: 6),
            Text(
              _medicineMealErrors[index ?? 0]!,
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: TextField(
                  controller: medicine.durationController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _roundedInputDecoration('Duration'),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Checkbox(
                          value: medicine.durationUnit == 'দিন',
                          onChanged: (v) => setState(() {
                            medicine.durationUnit = v == true ? 'দিন' : 'মাস';
                            _markUnsaved();
                          }),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('দিন'),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Checkbox(
                          value: medicine.durationUnit == 'মাস',
                          onChanged: (v) => setState(() {
                            medicine.durationUnit = v == true ? 'মাস' : 'দিন';
                            _markUnsaved();
                          }),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('মাস'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (_medicineDurationErrors[index ?? 0] != null) ...[
            const SizedBox(height: 6),
            Text(
              _medicineDurationErrors[index ?? 0]!,
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prescription',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: _addMedicineRow,
            icon: Icon(Icons.add, color: _accent),
            tooltip: 'Add medicine',
          ),
          IconButton(
            onPressed: _clearForm,
            icon: Icon(Icons.clear_all, color: Colors.red.shade400),
            tooltip: 'Clear form',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // University Logo
                  Image.asset(
                    'assets/images/nstu_logo.jpg',
                    height: screenWidth * 0.1,
                    width: screenWidth * 0.098,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.local_hospital, size: 40),
                  ),
                  const SizedBox(width: 8),

                  // University Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "মেডিকেল সেন্টার",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "নোয়াখালী বিজ্ঞান ও প্রযুক্তি বিশ্ববিদ্যালয়",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Noakhali Science and Technology University",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Patient Information card only contains patient fields and validation messages
            _buildLargeCard(
              title: 'Patient Information',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Row 1: Patient Name + Date
                  Row(
                    children: [
                      const Text(
                        'Patient Name:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 3,
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter patient name',
                            border: UnderlineInputBorder(),
                            contentPadding: EdgeInsets.only(bottom: 4),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Date:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 1,
                        child: TextField(
                          controller: TextEditingController(
                            text:
                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          ),
                          enabled: false, // make the date non-editable
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.only(bottom: 4),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 🔹 Row 2: Number + Age + Gender
                  Row(
                    children: [
                      const Text(
                        'Number:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 3,
                        child: TextField(
                          controller: _rollController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          decoration: const InputDecoration(
                            prefixText: "+88 ",
                            prefixStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            border: UnderlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.only(bottom: 4),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Age:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 1,
                        child: TextField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            hintText: 'Age',
                            border: UnderlineInputBorder(),
                            contentPadding: EdgeInsets.only(bottom: 4),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Gender:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 2,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_selectedGender == 'Male') {
                                    _selectedGender = null;
                                    _genderController.text = '';
                                  } else {
                                    _selectedGender = 'Male';
                                    _genderController.text = 'Male';
                                  }
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Checkbox(
                                      value: _selectedGender == 'Male',
                                      onChanged: (v) {
                                        setState(() {
                                          if (v == true) {
                                            _selectedGender = 'Male';
                                            _genderController.text = 'Male';
                                          } else {
                                            _selectedGender = null;
                                            _genderController.text = '';
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('M'),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_selectedGender == 'Female') {
                                    _selectedGender = null;
                                    _genderController.text = '';
                                  } else {
                                    _selectedGender = 'Female';
                                    _genderController.text = 'Female';
                                  }
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Checkbox(
                                      value: _selectedGender == 'Female',
                                      onChanged: (v) {
                                        setState(() {
                                          if (v == true) {
                                            _selectedGender = 'Female';
                                            _genderController.text = 'Female';
                                          } else {
                                            _selectedGender = null;
                                            _genderController.text = '';
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('F'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Show patient validation errors (if any)
                  if (_nameError != null ||
                      _numberError != null ||
                      _ageError != null ||
                      _genderError != null) ...[
                    const SizedBox(height: 6),
                    if (_nameError != null)
                      Text(
                        _nameError!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                      ),
                    if (_numberError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _numberError!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (_ageError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _ageError!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (_genderError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _genderError!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Clinical Details card (separate)
            _buildLargeCard(
              title: 'Clinical Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 C/C Section
                  const Text(
                    'C/C',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  _buildTextArea(_complainController, hint: 'Chief complaint'),
                  const SizedBox(height: 12),

                  // 🔹 O/E Section
                  const Text(
                    'O/E',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  _buildTextArea(
                    _examinationController,
                    hint: 'On examination',
                  ),
                  const SizedBox(height: 12),

                  // 🔹 Advice Section
                  const Text(
                    'Adv',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  _buildTextArea(_adviceController, hint: 'Advice'),
                  const SizedBox(height: 12),

                  // 🔹 Investigations Section
                  const Text(
                    'Inv',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  _buildTextArea(_testsController, hint: 'Investigations'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Rx full-width card (separate)
            _buildLargeCard(
              title: 'Rx',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: _medicineRows
                        .asMap()
                        .entries
                        .map((e) => _buildMedicineCard(e.value, e.key))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _addMedicineRow,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add Medicine'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Signature & options (aligned underlines)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side: Outside checkbox + Next visit (underline)
                Row(
                  children: [
                    Checkbox(
                      value: _isOutside,
                      onChanged: (v) => setState(() {
                        _isOutside = v ?? false;
                        _markUnsaved();
                      }),
                    ),
                    const SizedBox(width: 6),
                    const Text('Outside'),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 160,
                          child: TextField(
                            controller: _nextVisitController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Next visit',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 6,
                              ),
                            ),
                          ),
                        ),
                        Container(width: 160, height: 1, color: Colors.black),
                      ],
                    ),
                  ],
                ),

                // Right side: Signature with same underline width
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 60,
                      child: _loadingDoctorInfo
                          ? const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                          : (_doctorSignatureUrl != null &&
                          _doctorSignatureUrl!.startsWith('http'))
                          ? Image.network(
                        _doctorSignatureUrl!,
                        fit: BoxFit.contain,
                        // ignore: unnecessary_underscores
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('Invalid signature'),
                        ),
                      )
                          : const Center(child: Text('No signature uploaded')),
                    ),
                    const SizedBox(height: 6),
                    // show doctor name under signature (if available)
                    SizedBox(
                      width: 160,
                      child: Text(
                        'Name: ${_doctorName ?? ''}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                ElevatedButton(
                  onPressed: _savePrescription,
                  style: ElevatedButton.styleFrom(
                    // Blue when saved, red when not saved
                    backgroundColor: _isSaved ? Colors.blue : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: Text(
                      'Save',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _clearForm,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _accent),
                    foregroundColor: _accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text('Clear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
