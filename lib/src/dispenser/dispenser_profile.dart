import 'dart:convert';
import 'dart:typed_data';
import 'package:backend_client/backend_client.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('user_id') ?? '');
      if (userId == null) return;

      final profile = await client.dispenser.getDispenserProfile(0);
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
        _phoneCtrl.text = phone;
        _qualificationCtrl.text = qualification;
        _designationCtrl.text = designation;

        _isChanged = false;
      });
    } catch (e) {
      debugPrint('Failed to load dispenser profile: $e');
    }
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

    String? base64Image;
    if (_imageBytes != null) base64Image = base64Encode(_imageBytes!);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('user_id') ?? '');
      if (userId == null) return;

      await client.dispenser.updateDispenserProfile(
        userId: 0,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        qualification: _qualificationCtrl.text.trim(),
        designation: _designationCtrl.text.trim(), // ✅ Pass designation
        base64Image: base64Image,
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
                            _nameCtrl.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Dispenser',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _field(_nameCtrl, Icons.person, 'Name'),
                      const SizedBox(height: 12),
                      _field(_emailCtrl, Icons.email, 'Email'),
                      const SizedBox(height: 12),
                      _field(_designationCtrl, Icons.work, 'Designation'),
                      const SizedBox(height: 12),
                      _field(_phoneCtrl, Icons.phone, 'Phone'),
                      const SizedBox(height: 12),
                      _field(_qualificationCtrl, Icons.school, 'Qualification'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 44,
                  child: _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _isChanged ? _saveProfile : null,
                          child: const Text('Save Changes'),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/change-password'),
                    icon: const Icon(Icons.lock_reset, size: 18),
                    label: const Text('Change Password'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, IconData i, String l) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: l,
        prefixIcon: Icon(i),
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
