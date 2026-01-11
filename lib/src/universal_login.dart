import 'package:flutter/material.dart';
import 'package:backend_client/backend_client.dart'; // Import from package
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  // Focus nodes to support keyboard 'Enter' behavior
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // New: control password visibility
  bool _obscurePassword = true;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final email = value.trim();
    // Basic format check
    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}");
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';

    // Domain restriction: only NSTU domain or gmail allowed
    if (email.endsWith('nstu.edu.bd') || email.endsWith('@gmail.com')) {
      return null;
    }

    return 'Use a valid institution email domain.';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  // Helper method to show dialogs
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, textAlign: TextAlign.center),
          content: Text(message, textAlign: TextAlign.center),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // No-op for now, but keep so focus nodes can be prepared if needed
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _idController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // Use the client that's initialized in the package
        // The 'client' variable is available from backend_client package
        final response = await client.auth.login(email, password);

        if (!response.success) {
          _showDialog('Login Failed', response.error ?? 'Unknown error');
        } else {
          // Use profile data included in LoginResponse to avoid an extra DB query
          final name = response.userName ?? '';
          final profilePictureUrl = response.profilePictureUrl;

          // persist profile info locally so page refresh / hot restart can restore
          try {
            // Persist only the user_id so pages fetch fresh profile data from backend.
            final prefs = await SharedPreferences.getInstance();
            if (response.userId != null) {
              await prefs.setString('user_id', response.userId!);
            }
            // Also persist the email to allow pages to load profile by email
            if (email.isNotEmpty) {
              await prefs.setString('user_email', email);
            }
          } catch (e) {
            // non-fatal local storage error, continue navigation
            debugPrint('Failed to persist profile: $e');
          }

          _navigateToDashboard(
            role: response.role ?? '',
            name: name,
            email: email,
            phone: response.phone,
            bloodGroup: response.bloodGroup,
            allergies: response.allergies,
            profilePictureUrl: profilePictureUrl,
          );
        }
      } catch (e) {
        _showDialog('Login Error', 'An error occurred during login: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToDashboard({
    required String role,
    required String name,
    required String email,
    String? phone,
    String? bloodGroup,
    String? allergies,
    String? profilePictureUrl,
  }) async {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        Navigator.pushNamed(context, '/admin-dashboard');
        break;

      case 'STUDENT':
      case 'TEACHER':
      case 'STAFF':
        // Navigate without passing profile data — the dashboard will query the backend
        // for fresh profile information using the stored user_id.
        Navigator.pushNamed(context, '/patient-dashboard');
        break;

      case 'DOCTOR':
        Navigator.pushNamed(context, '/doctor-dashboard');
        break;

      case 'DISPENSER':
        Navigator.pushNamed(context, '/dispenser-dashboard');
        break;

      case 'LABSTAFF':
        Navigator.pushNamed(context, '/lab-dashboard');
        break;

      default:
        _showDialog('Unknown Role', 'Role $role not recognized');
    }

  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double horizontalPadding;
    if (screenWidth < 600) {
      horizontalPadding = 20.0;
    } else {
      horizontalPadding = screenWidth * 0.3;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),
                // Icon with shadow
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    Icons.local_hospital,
                    size: 60,
                    color: Colors.blue.shade700,
                  ),
                ),

                const SizedBox(height: 20),
                // Title
                Text(
                  'NSTU Campus Clinic',//e-Campus care //
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.blue.shade700,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 30),

                // ID/Email Field
                TextFormField(
                  controller: _idController,
                  focusNode: _emailFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    // Move focus to password field when user presses Enter/Next
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  obscureText: false,
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Enter your Email',
                    hintText: 'user@example.nstu.edu.bd',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: _validateEmail,
                ),

                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) async {
                    // Submit form when user presses Enter/Done on keyboard
                    await _login();
                  },
                  obscureText: _obscurePassword,
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Enter Your Password',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                    // Suffix icon to toggle password visibility
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: _validatePassword,
                ),

                const SizedBox(height: 40),

                // Login Button
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 50,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 6,
                            shadowColor: Colors.blue.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 16,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                // Forget Password Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Forget Password?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgotpassword');
                      },
                      child: const Text('Click here'),
                    ),
                  ],
                ),

                // SignUp Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Not yet registered?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/patient-signup');
                      },
                      child: const Text('SignUp'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
