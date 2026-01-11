import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // for MediaType
import 'package:image_picker/image_picker.dart';
import 'package:backend_client/backend_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class PatientProfilePage extends StatefulWidget {
  // Make userId optional: the page will try to load the id from SharedPreferences
  // if it is not passed by the caller. This keeps backward compatibility.
  final String? userId;
  const PatientProfilePage({super.key, this.userId});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage>
    with SingleTickerProviderStateMixin {
  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bloodGroupController;
  late final TextEditingController _allergiesController;
  String? _initialName;
  String? _initialPhone;
  String? _initialAllergies;

  // Profile image
  Uint8List? _profileImageBytes;
  String? _profileImageBase64;
  final ImagePicker _picker = ImagePicker();

  // Track state
  bool _isChanged = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _resolvedUserId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _allergiesController = TextEditingController();

    _loadProfileData();

    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _allergiesController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bloodGroupController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Resolve user id: prefer provided numeric id, otherwise try stored 'user_id' in prefs.
      int? resolvedNumericId;
      if (widget.userId != null && widget.userId!.isNotEmpty) {
        resolvedNumericId = int.tryParse(widget.userId!);
      }
      if (resolvedNumericId == null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final storedId = prefs.getString('user_id');
          if (storedId != null && storedId.isNotEmpty) {
            resolvedNumericId = int.tryParse(storedId);
          }
        } catch (e) {
          // ignore prefs error
        }
      }

      if (resolvedNumericId == null) {
        _showDialog('Error', 'Session expired. Please sign in again.');
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      // Fetch profile using numeric user id (client methods expect int)
      final profile = await client.patient.getPatientProfile(resolvedNumericId);

      if (profile != null) {
        // ✅ Set initial values here (AFTER fetching profile)
        _initialName = profile.name;
        _initialPhone = profile.phone;
        _initialAllergies = profile.allergies;

        if (!mounted) return;
        setState(() {
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _phoneController.text = profile.phone;
          _bloodGroupController.text = profile.bloodGroup;
          _allergiesController.text = profile.allergies;
          _profileImageBase64 = profile.profilePictureUrl;
          _isLoading = false;
        });
      } else {
        // Show more friendly info: prefer email if we have it
        final who = (_resolvedUserId != null && _resolvedUserId!.contains('@'))
            ? _resolvedUserId
            : widget.userId ?? 'user';
        _showDialog('Error', 'Profile not found for: $who');
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showDialog('Error', 'Failed to load profile: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _checkChanges() {
    final changed =
        _nameController.text != _initialName ||
        _phoneController.text != _initialPhone ||
        _allergiesController.text != _initialAllergies ||
        (_profileImageBytes != null); // only if new image selected

    if (changed != _isChanged) {
      if (!mounted) return;
      setState(() => _isChanged = changed);
    }
  }

  Future<void> _pickImage() async {
    debugPrint('Starting image picker...');
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Opening image picker...')));

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image == null) {
        debugPrint('Image picker returned null (user cancelled)');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No image selected')));
        return;
      }

      debugPrint('Image picked: path=${image.path}, name=${image.name}');
      final bytes = await image.readAsBytes();

      if (bytes.isEmpty) {
        debugPrint('Picked image bytes empty');
        _showDialog('Error', 'Selected file is empty or could not be read.');
        return;
      }

      if (bytes.length > 1024 * 1024 * 2) {
        _showDialog(
          'Image Too Large',
          'Please select an image smaller than 2MB',
        );
        return;
      }

      if (!mounted) return;
      setState(() => _profileImageBytes = bytes);
      _checkChanges();
      debugPrint('Image bytes set in state, size=${bytes.length}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image selected')));
    } catch (e, st) {
      debugPrint('Failed to pick image: $e\n$st');
      if (!mounted) return;
      _showDialog('Error', 'Failed to pick image: $e');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  // Inside _PatientProfilePageState

  // 1. Add the Cloudinary Upload Helper (Reuse your credentials)
  Future<String?> _uploadProfileToCloudinary(Uint8List bytes) async {
    const String cloudName = "dfrzizwb1";
    const String uploadPreset = "sabbir";

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final json = jsonDecode(utf8.decode(responseData));
        return json['secure_url']; // Returns the HTTPS link
      }
    } catch (e) {
      debugPrint("Cloudinary Profile Error: $e");
    }
    return null;
  }

  // 2. Fix the Save Logic to use the URL instead of Base64
  Future<void> _saveProfile() async {
    if (!_isChanged) return;

    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      final phoneToSend = _normalizePhone(_phoneController.text);
      if (phoneToSend == null) {
        _showDialog(
          'Invalid Phone',
          'Phone must start with +8801 and be exactly 14 characters.',
        );
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      String? finalImageUrl = _profileImageBase64;

      if (_profileImageBytes != null) {
        final uploadedUrl = await _uploadProfileToCloudinary(
          _profileImageBytes!,
        );
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        } else {
          _showDialog('Error', 'Image upload to cloud failed.');
          if (mounted) setState(() => _isSaving = false);
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final uidInt = int.tryParse(prefs.getString('user_id') ?? '');

      if (uidInt == null) {
        _showDialog('Error', 'Session expired. Please login again.');
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      final result = await client.patient.updatePatientProfile(
        uidInt,
        _nameController.text.trim(),
        phoneToSend,
        _allergiesController.text.trim(),
        finalImageUrl,
      );

      if (result.contains('successfully')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Updated!'),
            backgroundColor: Colors.green,
          ),
        );
        _profileImageBytes = null;
        await _loadProfileData(); // refresh UI with DB data
        if (!mounted) return;
        setState(() => _isChanged = false);
      }
    } catch (e) {
      _showDialog('Error', 'Update failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _normalizePhone(String raw) {
    final trimmed = raw.trim();

    if (!trimmed.startsWith('+8801')) return null; // must start with +8801
    if (trimmed.length != 14)
      return null; // must be exactly 14 chars including +

    return trimmed; // valid phone
  }

  // Build avatar widget: prefer local picked bytes, otherwise network URL
  Widget _buildProfileImage() {
    final bool hasNetworkUrl =
        _profileImageBase64 != null &&
        _profileImageBase64!.trim().isNotEmpty &&
        _profileImageBase64!.startsWith('http');

    ImageProvider? provider;
    if (_profileImageBytes != null) {
      provider = MemoryImage(_profileImageBytes!);
    } else if (hasNetworkUrl) {
      provider = NetworkImage(_profileImageBase64!);
    }

    return GestureDetector(
      onTap: () {},
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 65,
            backgroundColor: Colors.blue.shade100,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: provider,
              child: provider == null
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 18,
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
                onPressed: _pickImage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double responsiveWidth(double w) => size.width * w / 375;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Profile"),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
        centerTitle: true,

        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(responsiveWidth(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // Top card with gradient background
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7DFF), Color(0xFF6A9CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          _buildProfileImage(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    _nameController.text.isNotEmpty
                                        ? _capitalize(_nameController.text)
                                        : 'Unnamed',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: const Duration(milliseconds: 350),
                                  child: Text(
                                    _emailController.text,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    if (_bloodGroupController.text.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            0.18,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.bloodtype,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _bloodGroupController.text,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            color: Colors.white70,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _phoneController.text.isNotEmpty
                                                ? _phoneController.text
                                                : 'No phone',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Form card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              _nameController,
                              'Full Name',
                              Icons.person,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              _emailController,
                              'Email',
                              Icons.mail,
                              readOnly: true,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              _phoneController,
                              'Phone Number',
                              Icons.phone,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Medical Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              _bloodGroupController,
                              'Blood Group',
                              Icons.bloodtype,
                              readOnly: true,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              _allergiesController,
                              'Allergies (if any)',
                              Icons.health_and_safety,
                            ),

                            const SizedBox(height: 20),

                            // Save button (stable for web): replaced AnimatedSwitcher + MaterialStateProperty.resolveWith
                            Center(
                              child: SizedBox(
                                height: 35,
                                width: size.width * 0.40,
                                child: _isSaving
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : ElevatedButton(
                                        onPressed: _isChanged
                                            ? _saveProfile
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isChanged
                                              ? const Color(0xFF2E7DFF)
                                              : Colors.grey.shade300,
                                          foregroundColor: _isChanged
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                          elevation: _isChanged ? 6 : 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 22,
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          _isChanged
                                              ? 'Save Changes'
                                              : 'Up to date',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Decorative hint
                            Center(
                              child: Text(
                                _isChanged
                                    ? 'You have unsaved changes'
                                    : 'All changes saved',
                                style: TextStyle(
                                  color: _isChanged
                                      ? Colors.orange.shade700
                                      : Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                            // Change Password Button (add here)
                            Center(
                              child: SizedBox(
                                width: size.width * 0.40,
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    '/change-password',
                                  ),
                                  icon: const Icon(Icons.lock_reset, size: 18),
                                  label: const Text('Change Password'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool readOnly = false,
  }) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    final isPhone = label.toLowerCase().contains('phone');

    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: null,
      inputFormatters: isPhone
          ? [
              FilteringTextInputFormatter.allow(
                RegExp(r'[0-9+]'),
              ), // allow only digits + +
              LengthLimitingTextInputFormatter(14), // max 14 chars
            ]
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        enabledBorder: baseBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
        ),
        border: baseBorder,
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
