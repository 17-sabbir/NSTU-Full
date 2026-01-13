import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:backend_client/backend_client.dart';

import '../cloudinary_upload.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Initial doctor data (kept as sensible defaults until loaded)
  String initialName = "";
  String initialEmail = "";
  String initialPhone = "";
  String initialDesignation = "";
  String initialQualifications = "";

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _designationController;
  late final TextEditingController _qualificationsController;

  File? _profileImage;
  File? _signatureImage; // newly added signature image
  String? _profileImageUrl; // remote URL from server
  String? _signatureImageUrl;
  int? _doctorId;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _webProfileImageBytes; // web-only profile image
  Uint8List? _webSignatureImageBytes; // web-only signature image

  bool _isChanged = false;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _normalizePhoneLocal(String? phone) {
    if (phone == null) return null;
    final trimmed = phone.trim();

    final regex = RegExp(r'^(\+88)?0\d{10}$');
    if (!regex.hasMatch(trimmed)) return null;

    if (trimmed.startsWith('0')) {
      return '+88${trimmed.substring(1)}';
    }

    return trimmed;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: initialEmail);
    _phoneController = TextEditingController(text: initialPhone);
    _designationController = TextEditingController(text: initialDesignation);
    _qualificationsController = TextEditingController(
      text: initialQualifications,
    );

    _nameController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges); // listen for email changes
    _phoneController.addListener(_checkChanges);
    _qualificationsController.addListener(_checkChanges);
    _designationController.addListener(_checkChanges);
    // _ageController.addListener(_checkChanges); // listen for age changes

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    _qualificationsController.dispose();
    // _shiftController.dispose();
    // _ageController.dispose(); // dispose age controller
    super.dispose();
  }

  void _checkChanges() {
    final changed =
        _nameController.text != initialName ||
        _emailController.text !=
            initialEmail || // include email in change detection
        _phoneController.text != initialPhone ||
        _designationController.text != initialDesignation ||
        _qualificationsController.text != initialQualifications ||
        // _ageController.text != initialAge || // include age in change detection
        _profileImage != null ||
        _webProfileImageBytes != null ||
        _signatureImage != null ||
        _webSignatureImageBytes != null;

    if (changed != _isChanged) {
      if (!mounted) return;
      setState(() {
        _isChanged = changed;
      });
    }
  }

  // Build avatar showing local file (mobile), memory bytes (web), or remote URL.
  Widget _buildAvatar({double radius = 52}) {
    if (_profileImage != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        backgroundImage: FileImage(_profileImage!),
      );
    }

    if (_webProfileImageBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        backgroundImage: MemoryImage(_webProfileImageBytes!),
      );
    }

    if (_profileImageUrl != null && _profileImageUrl!.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(_profileImageUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: const Icon(Icons.person, size: 56, color: Colors.grey),
    );
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('user_id');
      final id = int.tryParse(stored ?? '');
      if (id == null) {
        setState(() => _isLoading = false);
        return;
      }

      _doctorId = id;

      // Backend resolves doctorId from authenticated session
      final DoctorProfile? profile = await client.doctor.getDoctorProfile(0);
      if (profile != null) {
        initialName = profile.name ?? '';
        initialEmail = profile.email ?? '';
        // Inside _loadProfileFromServer, when setting the phone text:
        if (profile.phone != null && profile.phone!.startsWith('+88')) {
          _phoneController.text = profile.phone!;
        } else {
          _phoneController.text = profile.phone ?? '';
        }
        initialPhone =
            _phoneController.text; // Update initial state for change detection
        initialDesignation = profile.designation ?? '';
        initialQualifications = profile.qualification ?? '';

        _profileImageUrl = profile.profilePictureUrl;
        _signatureImageUrl = profile.signatureUrl;

        if (!mounted) return;
        setState(() {
          _nameController.text = initialName;
          _emailController.text = initialEmail;
          _phoneController.text = initialPhone;
          _designationController.text = initialDesignation;
          _qualificationsController.text = initialQualifications;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    }
  }

  Future<String?> _uploadDoctorImageToCloudinary({
    required Uint8List bytes,
    required String folder,
    required String filePrefix,
  }) {
    final fileName =
        '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return CloudinaryUpload.uploadBytes(
      bytes: bytes,
      folder: folder,
      fileName: fileName,
      isPdf: false,
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _profileImage = null;
          _profileImageUrl = null;
          _webProfileImageBytes = bytes;
        });
      } else {
        final file = File(image.path);
        final int bytes = await file.length();
        if (bytes > 2 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected image exceeds 2 MB')),
          );
          return;
        }
        if (!mounted) return;
        setState(() {
          _profileImage = file;
          _profileImageUrl = null;
        });
      }
      // Ensure change detection runs after state updated
      if (!mounted) return;
      _checkChanges();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _pickSignatureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _signatureImage = null;
          _signatureImageUrl = null;
          _webSignatureImageBytes = bytes;
        });
      } else {
        final file = File(image.path);
        final int bytes = await file.length();
        if (bytes > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected signature exceeds 2 MB')),
          );
          return;
        }
        setState(() {
          _signatureImage = file;
          _signatureImageUrl = null;
        });
      }
      _checkChanges();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick signature: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (_doctorId == null) return;
    if (!mounted) return;
    setState(() {
      _isSaving = true;
    });

    try {
      // Email validation
      final email = _emailController.text.trim();
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid email address')));
        setState(() => _isSaving = false);
        return;
      }

      // Phone normalization
      final normalizedPhone = _normalizePhoneLocal(_phoneController.text);
      if (normalizedPhone == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone must be 14 digits (+88017XXXXXXXX)'),
          ),
        );
        setState(() => _isSaving = false);
        return;
      }

      String? profileUrl = _profileImageUrl;
      String? signatureUrl = _signatureImageUrl;
      // Profile upload
      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        profileUrl = await _uploadDoctorImageToCloudinary(
          bytes: bytes,
          folder: 'doctor_profiles',
          filePrefix: 'doctor_profile',
        );
        if (profileUrl == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload profile image')),
          );
          setState(() {
            _isSaving = false;
          });
          return;
        }
      } else if (_webProfileImageBytes != null) {
        profileUrl = await _uploadDoctorImageToCloudinary(
          bytes: _webProfileImageBytes!,
          folder: 'doctor_profiles',
          filePrefix: 'doctor_profile',
        );
        if (profileUrl == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload profile image')),
          );
          setState(() {
            _isSaving = false;
          });
          return;
        }
      }

      // Signature upload
      if (_signatureImage != null) {
        final bytes = await _signatureImage!.readAsBytes();
        signatureUrl = await _uploadDoctorImageToCloudinary(
          bytes: bytes,
          folder: 'doctor_signatures',
          filePrefix: 'doctor_signature',
        );
        if (signatureUrl == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload signature')),
          );
          setState(() {
            _isSaving = false;
          });
          return;
        }
      } else if (_webSignatureImageBytes != null) {
        signatureUrl = await _uploadDoctorImageToCloudinary(
          bytes: _webSignatureImageBytes!,
          folder: 'doctor_signatures',
          filePrefix: 'doctor_signature',
        );
        if (signatureUrl == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload signature')),
          );
          setState(() {
            _isSaving = false;
          });
          return;
        }
      }

      bool ok = false;
      try {
        ok = await client.doctor.updateDoctorProfile(
          _doctorId!,
          _nameController.text.trim(),
          _emailController.text.trim(),
          normalizedPhone,
          profileUrl!,
          _designationController.text.trim(),
          _qualificationsController.text.trim(),
          signatureUrl,
        );
      } catch (err) {
        final emsg = err.toString();
        if (emsg.contains('Phone number already registered')) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number already registered')),
          );
          setState(() {
            _isSaving = false;
          });
          return;
        }
        rethrow;
      }

      if (ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            backgroundColor: Colors.green,
          ),
        );
        // reload
        _profileImage = null;
        _signatureImage = null;
        _webProfileImageBytes = null;
        _webSignatureImageBytes = null;
        await _loadProfile();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save profile')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _isChanged = false;
      });
    }
  }

  // Navigate to rostering system

  // Added: show logout confirmation dialog and perform logout
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              () async {
                try {
                  try {
                    await client.auth.logout();
                  } catch (_) {}
                  // ignore: deprecated_member_use
                  await client.authenticationKeyManager?.remove();
                } catch (_) {}

                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('user_id');
                  await prefs.remove('user_email');
                  await prefs.remove('user_role');
                } catch (_) {}

                if (!mounted) return;
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logged out successfully"),
                    duration: Duration(seconds: 2),
                  ),
                );

                Navigator.pushNamedAndRemoveUntil(
                  // ignore: use_build_context_synchronously
                  context,
                  '/',
                  (route) => false,
                );
              }();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget safeNetworkImage({
    required String? url,
    double radius = 40,
    IconData fallbackIcon = Icons.person,
  }) {
    if (url == null || url.isEmpty || !url.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        child: Icon(fallbackIcon, size: radius),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, _) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Doctor Profile",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),

        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top card with avatar and basic info
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade200,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar and edit overlay (shows web/local/remote image)
                    Stack(
                      children: [
                        _buildAvatar(radius: 52),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.deepPurple,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Name and role
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                _designationController.text,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Personal Information Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Name
                      TextField(
                        controller: _nameController,
                        readOnly: false,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.deepPurple,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Email (now editable)
                      TextField(
                        controller: _emailController,
                        readOnly: false, // made editable
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.deepPurple,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          // keep or remove lock icon as desired
                        ),
                        style: TextStyle(color: Colors.grey[700]),
                      ),

                      const SizedBox(height: 12),

                      // Phone
                      TextField(
                        controller: _phoneController,
                        readOnly: false,
                        keyboardType: TextInputType.phone,
                        // Remove digitsOnly and length limit to allow +88
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Colors.deepPurple,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // designation (moved before Qualifications)
                      TextField(
                        controller: _designationController,
                        readOnly: false,
                        decoration: InputDecoration(
                          labelText: "Designation",
                          prefixIcon: const Icon(
                            Icons.medical_services,
                            color: Colors.deepPurple,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Qualifications (moved after Designation)
                      TextField(
                        controller: _qualificationsController,
                        maxLines: 2,
                        readOnly: false,
                        decoration: InputDecoration(
                          labelText: "Qualifications",
                          prefixIcon: const Icon(
                            Icons.school,
                            color: Colors.deepPurple,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Signature row with preview
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Signature',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      _signatureImage != null
                                          ? Image.file(
                                              _signatureImage!,
                                              height: 44,
                                              width: 120,
                                              fit: BoxFit.cover,
                                            )
                                          : (_webSignatureImageBytes != null)
                                          ? Image.memory(
                                              _webSignatureImageBytes!,
                                              height: 44,
                                              width: 120,
                                              fit: BoxFit.cover,
                                            )
                                          : (_signatureImageUrl != null &&
                                                _signatureImageUrl!.startsWith(
                                                  'http',
                                                ))
                                          ? Image.network(
                                              _signatureImageUrl!,
                                              height: 44,
                                              width: 120,
                                              fit: BoxFit.contain,
                                            )
                                          : Text('No signature uploaded'),

                                      const Spacer(),
                                      ElevatedButton.icon(
                                        onPressed: _pickSignatureImage,
                                        icon: const Icon(
                                          Icons.upload_file,
                                          size: 18,
                                        ),
                                        label: const Text('Upload'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
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
              ),

              const SizedBox(height: 18),

              // Action buttons (Change Password, Save)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/change-password'),
                      icon: const Icon(Icons.lock_reset, size: 20),
                      label: const Text("Change Password"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isChanged && !_isSaving ? _saveProfile : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isChanged
                            ? Colors.deepPurple
                            : Colors.grey,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Save Changes",
                              style: TextStyle(
                                color: _isChanged
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
}
