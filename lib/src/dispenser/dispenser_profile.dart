import 'dart:typed_data';
import 'package:backend_client/backend_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cloudinary_upload.dart';

class DispenserProfile extends StatefulWidget {
  const DispenserProfile({super.key});

  @override
  State<DispenserProfile> createState() => _DispenserProfileState();
}

class _DispenserProfileState extends State<DispenserProfile> {
  String name = '';
  String email = '';
  String phone = '';
  String qualification = '';
  String designation = '';
  String profileImageUrl = '';

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _designationCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _qualificationCtrl;

  bool _isChanged = false;
  bool _isSaving = false;

  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  // Password controllers
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _designationCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _qualificationCtrl = TextEditingController();

    _nameCtrl.addListener(_onChanged);
    _emailCtrl.addListener(_onChanged);
    _designationCtrl.addListener(_onChanged);
    _phoneCtrl.addListener(_onChanged);
    _qualificationCtrl.addListener(_onChanged);

    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _designationCtrl.dispose();
    _phoneCtrl.dispose();
    _qualificationCtrl.dispose();
    _oldPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  void _onChanged() {
    final changed =
        _nameCtrl.text.trim() != name ||
        _emailCtrl.text.trim() != email ||
        _phoneCtrl.text.trim() != phone ||
        _qualificationCtrl.text.trim() != qualification ||
        _designationCtrl.text.trim() != designation ||
        _imageBytes != null;

    if (changed != _isChanged) {
      setState(() => _isChanged = changed);
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await client.dispenser.getDispenserProfile();
      if (profile == null) return;

      if (!mounted) return;

      setState(() {
        name = profile.name;
        email = profile.email;
        phone = profile.phone;
        qualification = profile.qualification;
        designation = profile.designation;
        profileImageUrl = profile.profilePictureUrl ?? '';

        _nameCtrl.text = name;
        _emailCtrl.text = email;
        _phoneCtrl.text = _normalizeBdPhoneForEdit(phone);
        _qualificationCtrl.text = qualification;
        _designationCtrl.text = designation;

        _isChanged = false;
      });
    } catch (e) {
      debugPrint('Failed to load dispenser profile: $e');
    }
  }

  String _normalizeBdPhoneForEdit(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    // Convert stored forms like +8801XXXXXXXXX / 8801XXXXXXXXX -> 01XXXXXXXXX
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digitsOnly.startsWith('+88')) {
      final rest = digitsOnly.substring(3);
      return rest.startsWith('01') ? rest : rest;
    }
    if (digitsOnly.startsWith('88') && digitsOnly.length >= 13) {
      final rest = digitsOnly.substring(2);
      return rest.startsWith('01') ? rest : rest;
    }
    return digitsOnly.startsWith('01') ? digitsOnly : digitsOnly;
  }

  bool _isValidBdLocalPhone(String local) {
    // Expect local part without country code: 01 + 9 digits (11 digits total)
    return RegExp(r'^01\d{9}$').hasMatch(local);
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

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
      await prefs.remove('user_role');
      await prefs.remove('user_email');
    } catch (_) {}

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (bytes.length > 2 * 1024 * 1024) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be under 2MB')),
        );
        return;
      }

      setState(() => _imageBytes = bytes);
      _onChanged();
    }
  }

  Future<void> _saveProfile() async {
    if (!_isChanged) return;
    setState(() => _isSaving = true);

    final localPhone = _phoneCtrl.text.trim();
    if (localPhone.isNotEmpty && !_isValidBdLocalPhone(localPhone)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone must be like +8801XXXXXXXXX (total 14 chars)'),
          ),
        );
        setState(() => _isSaving = false);
      }
      return;
    }

    String? profileUrl = profileImageUrl.isEmpty ? null : profileImageUrl;
    if (_imageBytes != null) {
      final uploadedUrl = await CloudinaryUpload.uploadBytes(
        bytes: _imageBytes!,
        folder: 'dispenser_profiles',
        fileName:
            'dispenser_profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        isPdf: false,
      );
      if (uploadedUrl == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload profile image')),
        );
        setState(() => _isSaving = false);
        return;
      }
      profileUrl = uploadedUrl;
    }

    try {
      await client.dispenser.updateDispenserProfile(
        name: _nameCtrl.text.trim(),
        phone: localPhone.isEmpty ? '' : '+88$localPhone',
        qualification: _qualificationCtrl.text.trim(),
        designation: _designationCtrl.text.trim(), // ✅ Pass designation
        profilePictureUrl: profileUrl,
      );

      await _loadProfile();

      setState(() {
        _imageBytes = null;
        _isChanged = false;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      debugPrint('Failed to update profile: $e');
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _imageBytes != null
                              ? MemoryImage(_imageBytes!)
                              : (profileImageUrl.isNotEmpty
                                        ? NetworkImage(profileImageUrl)
                                        : null)
                                    as ImageProvider<Object>?,
                          child:
                              (_imageBytes == null && profileImageUrl.isEmpty)
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickImage,
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.edit, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameCtrl.text.isEmpty
                                ? 'Dispenser'
                                : _nameCtrl.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _emailCtrl.text.isEmpty
                                ? 'Dispenser'
                                : _emailCtrl.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                         if (designation.isNotEmpty)
                            Text(
                              designation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _field(_nameCtrl, Icons.person, 'Name'),
                      const SizedBox(height: 12),
                      _field(_emailCtrl, Icons.email, 'Email', readOnly: true),
                      const SizedBox(height: 12),
                      _field(_designationCtrl, Icons.work, 'Designation'),
                      const SizedBox(height: 12),
                      _field(
                        _phoneCtrl,
                        Icons.phone,
                        'Phone',
                        prefixText: '+88 ',
                        hintText: '01XXXXXXXXX',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _field(_qualificationCtrl, Icons.school, 'Qualification'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final contentWidth = maxWidth > 520 ? 520.0 : maxWidth;
                  return SizedBox(
                    width: contentWidth,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 46,
                          width: double.infinity,
                          child: _isSaving
                              ? const Center(
                                  child: SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _isChanged ? _saveProfile : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Save Changes'),
                                ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    '/change-password',
                                  ),
                                  icon: const Icon(Icons.lock_reset, size: 18),
                                  label: const Text('Change Password'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.deepOrange,
                                    side: const BorderSide(
                                      color: Colors.deepOrange,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton.icon(
                                  onPressed: _confirmLogout,
                                  icon: const Icon(Icons.logout, size: 18),
                                  label: const Text('Logout'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    IconData i,
    String l, {
    bool readOnly = false,
    String? prefixText,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: c,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: l,
        prefixIcon: Icon(i),
        prefixText: prefixText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
