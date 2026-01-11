import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // Uint8List এর জন্য
import 'package:backend_client/backend_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class LabTesterProfile extends StatefulWidget {
  const LabTesterProfile({super.key});

  @override
  State<LabTesterProfile> createState() => _LabTesterProfileState();
}

class _LabTesterProfileState extends State<LabTesterProfile> with SingleTickerProviderStateMixin {
  // joining date removed as requested

  // Fields populated from backend
  String name = '';
  String email = '';
  String phone = '';
  String designation = '';
  String qualification = '';
  String? _profilePictureUrl;
  bool _isLoading = true;

  XFile? _pickedFile;       // File? এর পরিবর্তে XFile?
  Uint8List? _imageBytes;   // প্রিভিউ এবং আপলোডের জন্য বাইটস

  // Editable controllers and initial copies for change detection
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl; // added
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _specCtrl;
  late final TextEditingController _qualCtrl;
  // String? _initialProfileUrl; // removed unused
  bool _isChanged = false;
  bool _isSaving = false;

  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController(); // init
    _phoneCtrl = TextEditingController();
    _specCtrl = TextEditingController();
    _qualCtrl = TextEditingController();

    _nameCtrl.addListener(_onChanged);
    _emailCtrl.addListener(_onChanged); // listen
    _phoneCtrl.addListener(_onChanged);
    _specCtrl.addListener(_onChanged);
    _qualCtrl.addListener(_onChanged);

    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose(); // dispose
    _phoneCtrl.dispose();
    _specCtrl.dispose();
    _qualCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final currentPhone = _normalizePhoneForBackend(_phoneCtrl.text.trim());

    final changed =
        _nameCtrl.text.trim() != name ||
            _emailCtrl.text.trim() != email ||
            currentPhone != _normalizePhoneForBackend(phone) ||
            _specCtrl.text.trim() != designation ||
            _qualCtrl.text.trim() != qualification ||
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
      final uidStr = prefs.getString('user_id') ?? '';
      final uid = int.tryParse(uidStr);

      if (uid == null) {
        setState(() => _isLoading = false);
        return;
      }

      // ✅ FIX: Use the typed class instead of Map<String, dynamic>
      // Note: Use 'client.lab.getStaffProfile' (the endpoint you showed in the previous message)
      StaffProfileDto? profile = await client.lab.getStaffProfile(uid);

      if (profile != null) {
        if (!mounted) return;
        setState(() {
          // ✅ Access fields directly like an object, not a Map
          name = profile.name;
          email = profile.email;
          phone = profile.phone;
          designation = profile.designation;
          qualification = profile.qualification;
          _profilePictureUrl = profile.profilePictureUrl;

          _nameCtrl.text = name;
          _emailCtrl.text = email; // set email
          _phoneCtrl.text = phone;
          _specCtrl.text = designation;
          _qualCtrl.text = qualification;
          // _initialProfileUrl = _profilePictureUrl;

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Failed to load staff profile: $e');
      setState(() => _isLoading = false);
    }
  }
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      // ২ মেগাবাইট চেক (মোবাইল ও ওয়েব উভয়ের জন্য কাজ করবে)
      final int length = await pickedFile.length();
      if (length > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image exceeds 2 MB limit'), backgroundColor: Colors.red));
        return;
      }

      // ইমেজ বাইটস রিড করা (প্রিভিউ এবং আপলোডের জন্য)
      final Uint8List bytes = await pickedFile.readAsBytes();

      setState(() {
        _pickedFile = pickedFile;
        _imageBytes = bytes;
      });
      _onChanged();
    }
  }

  // Save changes locally and upload image; backend persistence not implemented here
  Future<void> _saveProfile() async {
    if (!mounted) return;
    setState(() => _isSaving = true);
    String emailText = _emailCtrl.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email'),
          backgroundColor: Colors.red,
        ),
      );
      return; // stop saving
    }
    String? finalImageUrl = _profilePictureUrl;
    try {
      // ১. যদি নতুন ইমেজ পিক করা থাকে (মোবাইল বা ওয়েব যেটাই হোক)
      if (_imageBytes != null && _pickedFile != null) {
        try {
          final String base64String = base64Encode(_imageBytes!);
          final uploadedUrl = await client.lab.uploadProfileImage(
            base64String,
          );


          if (uploadedUrl == null || uploadedUrl.isEmpty) {
            throw Exception('Cloudinary upload failed');
          }
          finalImageUrl = uploadedUrl;
        } catch (e) {
          debugPrint('Upload error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image upload error'), backgroundColor: Colors.red)
          );
          setState(() => _isSaving = false);
          return;
        }
      }

      // ২. সার্ভার থেকে User ID নেওয়া
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('user_id') ?? '';
      final uid = int.tryParse(stored);

      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not signed in')));
        setState(() => _isSaving = false);
        return;
      }

      // ৩. ব্যাকএন্ডে ডেটা সেভ করা
      final normalized = _normalizePhoneForBackend(_phoneCtrl.text.trim());
      final success = await client.lab.updateStaffProfile(
        userId: uid,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: normalized,
        designation: _specCtrl.text.trim(),
        qualification: _qualCtrl.text.trim(),
        profilePictureUrl: finalImageUrl,
      );

      if (success) {
        setState(() {
          name = _nameCtrl.text.trim();
          phone = _phoneCtrl.text.trim();
          designation = _specCtrl.text.trim();
          qualification = _qualCtrl.text.trim();
          _profilePictureUrl = finalImageUrl;
          _isChanged = false;
          // _initialProfileUrl = _profilePictureUrl;
          _imageBytes = null; // সেভ হয়ে গেলে লোকাল বাইটস ক্লিয়ার করে দিন
          _pickedFile = null;
        });
        // If email was changed in the UI, backend may not support changing it via this endpoint.
        if (_emailCtrl.text.trim() != email) {
          // Update local email variable and show notice that backend email change may not be applied.
          email = _emailCtrl.text.trim();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated. Note: email change may require admin action.'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green)
          );
        }
      } else {
        throw Exception('Server update failed');
      }
    } catch (e) {
      debugPrint('Save failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save changes'), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
              Navigator.pop(context); // close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Logged out successfully"),
                  duration: Duration(seconds: 2),
                ),
              );

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/', // তোমার HomePage route name
                (route) => false, // আগের সব route মুছে দেয়
              );
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

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(responsiveWidth(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top gradient card with avatar and basic info
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
                          BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 10, offset: const Offset(0, 8)),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Row(
                        children: [
                          // Avatar with overlay edit icon
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white.withAlpha(30),
                                backgroundImage: _imageBytes != null
                                    ? MemoryImage(_imageBytes!) as ImageProvider // নতুন পিক করা ইমেজ
                                    : (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty)
                                    ? NetworkImage(_profilePictureUrl!) as ImageProvider // সার্ভারের ইমেজ
                                    : null,
                                child: (_imageBytes == null && (_profilePictureUrl == null || _profilePictureUrl!.isEmpty))
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
                                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 4)],
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(Icons.edit, size: 18, color: Colors.blueAccent),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 16),

                          // Name + designation badge + quick info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nameCtrl.text.isNotEmpty ? _nameCtrl.text : (name.isNotEmpty ? name : 'Unnamed'),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                // removed header designation badge (designation is editable below)
                                const SizedBox.shrink(),
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
                    ),

                    const SizedBox(height: 20),

                    // Details Card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Contact & Professional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),

                            // Editable fields
                            _buildEditableField(_nameCtrl, Icons.person, 'Full Name'),
                            const SizedBox(height: 12),
                            _buildEditableField(_emailCtrl, Icons.email, 'Email'), // Email field
                            const SizedBox(height: 12),
                            _buildEditableField(_phoneCtrl, Icons.phone, 'Phone'),
                            const SizedBox(height: 12),
                            _buildEditableField(_qualCtrl, Icons.school, 'Qualification'),
                            const SizedBox(height: 12),
                            _buildEditableField(_specCtrl, Icons.work, 'Designation'),
                            const SizedBox(height: 12),
                            // joined date field and code removed as requested


                            const SizedBox(height: 18),
                           ],
                         ),
                       ),
                     ),

                     const SizedBox(height: 20),

                     // Buttons: Save Changes (center), Change Password and Logout
                     Center(
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
                                       backgroundColor: _isChanged ? Colors.green.shade600 : Colors.grey.shade300,
                                       foregroundColor: _isChanged ? Colors.white : Colors.grey.shade600,
                                       elevation: _isChanged ? 6 : 0,
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                     ),
                                     child: Text(
                                       'Save Changes',
                                       style: TextStyle(fontWeight: FontWeight.bold, color: _isChanged ? Colors.white : Colors.grey.shade600),
                                     ),
                                   ),
                           ),
                           const SizedBox(height: 12),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               ElevatedButton.icon(
                                 onPressed: () => Navigator.pushNamed(context, '/change-password'),
                                 icon: const Icon(Icons.lock_reset, size: 18),
                                 label: const Text('Change Password'),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.deepOrange.shade600,
                                   foregroundColor: Colors.white,
                                   elevation: 4,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),

                     const SizedBox(height: 40),
                   ],
                 ),
               ),
             ),
     );
   }

  Widget _buildEditableField(TextEditingController ctrl, IconData icon, String label) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  // Ensure phone field uses digits only and shows +88 prefix in UI
  // Update where _buildEditableField is called for phone: it uses _phoneCtrl already; no change needed to call site.

  String _normalizePhoneForBackend(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length == 11) return '+88$d';
    if (d.length == 13 && d.startsWith('88')) return '+$d';
    return raw;
  }
}
