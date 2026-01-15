import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:backend_client/backend_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../cloudinary_upload.dart';

class PatientProfilePage extends StatefulWidget {
  final String? userId;
  const PatientProfilePage({super.key, this.userId});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  // ================= Controllers & State =================
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bloodGroupController;

  DateTime? _dateOfBirth;
  String? _gender;
  String? _initialName;
  String? _initialPhone;
  DateTime? _initialDob;

  Uint8List? _profileImageBytes;
  String? _profileImageBase64;
  final ImagePicker _picker = ImagePicker();

  bool _isChanged = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bloodGroupController = TextEditingController();

    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  // ================= Logic Methods =================

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await client.patient.getPatientProfile();
      if (profile != null) {
        _initialName = profile.name;
        _initialPhone = profile.phone;
        _initialDob = profile.dateOfBirth;

        setState(() {
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _phoneController.text = profile.phone;
          _bloodGroupController.text = profile.bloodGroup ?? '';
          _dateOfBirth = profile.dateOfBirth;
          _gender = profile.gender;
          _profileImageBase64 = profile.profilePictureUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      _showDialog('Error', 'Failed to load profile: $e');
      setState(() => _isLoading = false);
    }
  }

  void _checkChanges() {
    final changed =
        _nameController.text != _initialName ||
        _phoneController.text != _initialPhone ||
        _dateOfBirth != _initialDob ||
        _profileImageBytes != null;

    if (changed != _isChanged && mounted) {
      setState(() => _isChanged = changed);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (bytes.length > 2 * 1024 * 1024) {
      _showDialog('Image Too Large', 'Please select an image < 2MB');
      return;
    }
    setState(() => _profileImageBytes = bytes);
    _checkChanges();
  }

  Future<String?> _uploadProfileToCloudinary(Uint8List bytes) {
    return CloudinaryUpload.uploadBytes(
      bytes: bytes,
      folder: 'patient_profiles',
      fileName: 'patient_profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      isPdf: false,
    );
  }

  Future<void> _saveProfile() async {
    if (!_isChanged) return;
    setState(() => _isSaving = true);
    try {
      String? imageUrl = _profileImageBase64;
      if (_profileImageBytes != null) {
        imageUrl = await _uploadProfileToCloudinary(_profileImageBytes!);
        if (imageUrl == null) throw Exception("Image upload failed");
      }
      await client.patient.updatePatientProfile(
        0,
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _bloodGroupController.text.isEmpty ? null : _bloodGroupController.text,
        _dateOfBirth,
        _gender,
        imageUrl,
      );

      _profileImageBytes = null;
      await _loadProfileData();
      setState(() {
        _isChanged = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    } catch (e) {
      _showDialog('Error', 'Update failed: $e');
    } finally {
      setState(() => _isSaving = false);
    }
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
      await client.auth.logout();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  String _formatDob(DateTime? d) {
    if (d == null) return 'Not set';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  // ================= UI Components =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'Personal Information',
                    children: [
                      _buildModernField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                      ),
                      _buildModernField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.mail_outline,
                        readOnly: true,
                      ),
                      _buildModernField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Medical Information',
                    children: [
                      _buildModernField(
                        controller: _bloodGroupController,
                        label: 'Blood Group',
                        icon: Icons.water_drop_outlined,
                        readOnly: true,
                      ),
                      _buildGenderDisplay(),
                      _buildDobDisplay(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A86F7), Color(0xFF2D63D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A86F7).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatarStack(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty ? 'User' : _nameController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _emailController.text,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _modernChip(
                      Icons.bloodtype,
                      _bloodGroupController.text.isEmpty
                          ? 'N/A'
                          : _bloodGroupController.text,
                    ),
                    _modernChip(Icons.phone, _phoneController.text),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    ImageProvider? image;
    if (_profileImageBytes != null) {
      image = MemoryImage(_profileImageBytes!);
    } else if (_profileImageBase64 != null &&
        _profileImageBase64!.startsWith('http'))
      image = NetworkImage(_profileImageBase64!);

    return Stack(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: Colors.white,
          backgroundImage: image,
          child: image == null
              ? const Icon(Icons.person, size: 40, color: Colors.grey)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Color(0xFF4A86F7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: !readOnly,
          readOnly: readOnly,
          onChanged: (_) => _checkChanges(),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? const Color(0xFFF3F4F7) : Colors.white,
            prefixIcon: Icon(
              icon,
              color: readOnly ? Colors.grey : const Color(0xFF4A86F7),
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDobDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Date of Birth",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cake_outlined,
                color: Color(0xFF4A86F7),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                _formatDob(_dateOfBirth),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDisplay() {
    final gender = (_gender ?? '').trim();
    final label = gender.isEmpty
        ? 'Not set'
        : (gender.toLowerCase() == 'male'
              ? 'Male'
              : (gender.toLowerCase() == 'female' ? 'Female' : gender));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.wc_outlined, color: Color(0xFF4A86F7), size: 20),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _modernChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isChanged ? _saveProfile : null,
            icon: const Icon(Icons.save_outlined),
            label: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save Changes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4A86F7),
              disabledForegroundColor: Colors.grey,
              side: BorderSide(
                color: _isChanged ? const Color(0xFF4A86F7) : Colors.grey,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 420;

            final changePasswordButton = OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/change-password'),
              icon: const Icon(Icons.lock_reset, color: Color(0xFF4A86F7)),
              label: const Text(
                'Change Password',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF4A86F7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4A86F7)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            );

            final logoutButton = OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text(
                'Logout',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            );

            if (isNarrow) {
              return Column(
                children: [
                  SizedBox(width: double.infinity, child: changePasswordButton),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: logoutButton),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: changePasswordButton),
                const SizedBox(width: 12),
                Expanded(child: logoutButton),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
