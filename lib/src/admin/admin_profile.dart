import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:backend_client/backend_client.dart';
import 'package:flutter/services.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  // Fields populated from backend
  String name = '';
  String email = '';
  String phone = '';
  String designation = '';
  String qualification = '';
  String? _profilePictureUrl;
  bool _isLoading = true;

  // Removed unused _pickedFile; keep image bytes only
  Uint8List? _imageBytes;

  // Editable controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _designationCtrl;
  late final TextEditingController _qualificationCtrl;

  bool _isChanged = false;
  bool _isSaving = false;

  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _designationCtrl = TextEditingController();
    _qualificationCtrl = TextEditingController();

    _nameCtrl.addListener(_onChanged);
    _phoneCtrl.addListener(_onChanged);
    _emailCtrl.addListener(_onChanged);
    _designationCtrl.addListener(_onChanged);
    _qualificationCtrl.addListener(_onChanged);

    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _designationCtrl.dispose();
    _qualificationCtrl.dispose();
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _onChanged() {
    final changed =
        _nameCtrl.text.trim() != name ||
        _phoneCtrl.text.trim() != phone ||
        _emailCtrl.text.trim() != email ||
        _designationCtrl.text.trim() != designation ||
        _qualificationCtrl.text.trim() != qualification ||
        _imageBytes != null;

    if (changed != _isChanged && mounted) {
      setState(() => _isChanged = changed);
    }
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      // Try common keys for stored email
      final storedEmail =
          prefs.getString('email') ??
          prefs.getString('user_email') ??
          prefs.getString('userId');
      if (storedEmail == null || storedEmail.isEmpty) {
        // fallback to dummy data (previous behaviour)
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        setState(() {
          _profilePictureUrl = '';

          _nameCtrl.text = name;
          _phoneCtrl.text = phone;
          _emailCtrl.text = email;

          _isLoading = false;
        });
        return;
      }

      // Fetch from backend using generated client endpoint reference
      final AdminProfileRespond? profile = await client.adminEndpoints
          .getAdminProfile(storedEmail);

      if (profile != null) {
        setState(() {
          name = profile.name;
          email = profile.email;
          phone = profile.phone;
          _profilePictureUrl = profile.profilePictureUrl ?? '';
          designation = profile.designation ?? '';
          qualification = profile.qualification ?? '';

          _nameCtrl.text = name;
          _emailCtrl.text = email;
          _phoneCtrl.text = phone;
          _designationCtrl.text = designation;
          _qualificationCtrl.text = qualification;
          _isLoading = false;
        });
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('Failed to load admin profile: $e');
      if (!mounted) return;
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final int length = await pickedFile.length();
      if (length > 2 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image exceeds 2 MB limit'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final Uint8List bytes = await pickedFile.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
      });
      _onChanged();
    }
  }

  Future<void> _saveProfile() async {
    if (!_isChanged) return;
    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail =
          prefs.getString('email') ??
          prefs.getString('user_email') ??
          prefs.getString('userId');
      if (storedEmail == null || storedEmail.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No signed-in user')));
        setState(() => _isSaving = false);
        return;
      }

      String? profileData;
      if (_imageBytes != null) {
        profileData = 'data:image/jpeg;base64,' + base64Encode(_imageBytes!);
      }

      // Call backend update using generated client endpoint
      final phoneToSend = _normalizePhoneForBackend(_phoneCtrl.text.trim());
      final res = await client.adminEndpoints.updateAdminProfile(
        storedEmail,
        _nameCtrl.text.trim(),
        phoneToSend,
        profileData,
        _designationCtrl.text.trim(),
        _qualificationCtrl.text.trim(),
      );

      if (res == 'OK') {
        // refresh
        await _loadProfile();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $res')));
      }
    } catch (e) {
      debugPrint('Save failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save changes'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  void _logout() {
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
              Navigator.pop(context);
              () async {
                try {
                  try {
                    await client.auth.logout();
                  } catch (_) {}
                  await client.authenticationKeyManager?.remove();
                } catch (_) {}

                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('user_id');
                  await prefs.remove('user_email');
                  await prefs.remove('user_role');
                } catch (_) {}

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logged out successfully"),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pushNamedAndRemoveUntil(
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double responsiveWidth(double w) => size.width * w / 375;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Profile"),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              await Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(responsiveWidth(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopCard(),
                    const SizedBox(height: 20),
                    _buildDetailsCard(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTopCard() {
    return Container(
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
            color: const Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withAlpha(30),
                backgroundImage: _imageBytes != null
                    ? MemoryImage(_imageBytes!) as ImageProvider
                    : (_profilePictureUrl != null &&
                          _profilePictureUrl!.isNotEmpty)
                    ? NetworkImage(_profilePictureUrl!) as ImageProvider
                    : null,
                child:
                    (_imageBytes == null &&
                        (_profilePictureUrl == null ||
                            _profilePictureUrl!.isEmpty))
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Tooltip(
                  message: 'Edit photo',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: _pickProfileImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.blueAccent,
                      ),
                    ),
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
                  _nameCtrl.text.isNotEmpty
                      ? _nameCtrl.text
                      : (name.isNotEmpty ? name : 'Unnamed'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  email.isNotEmpty ? email : '',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableField(_nameCtrl, Icons.person, 'Full Name'),
            const SizedBox(height: 12),

            _buildEditableField(_phoneCtrl, Icons.phone, 'Phone'),
            const SizedBox(height: 12),

            _buildEditableField(_emailCtrl, Icons.email, 'Email'),
            const SizedBox(height: 12),

            _buildEditableField(_designationCtrl, Icons.badge, 'Designation'),
            const SizedBox(height: 12),

            _buildEditableField(
              _qualificationCtrl,
              Icons.school,
              'Qualification',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 44,
            width: 220,
            child: _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _isChanged ? _saveProfile : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isChanged
                          ? Colors.green.shade600
                          : Colors.grey.shade300,
                      foregroundColor: _isChanged
                          ? Colors.white
                          : Colors.grey.shade600,
                      elevation: _isChanged ? 6 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isChanged ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/change-password'),
                icon: const Icon(Icons.lock_reset, size: 18),
                label: const Text('Change Password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade700,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    TextEditingController ctrl,
    IconData icon,
    String label,
  ) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      inputFormatters: label.toLowerCase().contains('phone')
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
    );
  }

  String _normalizePhoneForBackend(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length == 11) return '+88$d';
    if (d.length == 13 && d.startsWith('88')) return '+$d';
    return raw;
  }
}
