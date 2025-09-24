import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tool_rental_app/widgets/animated_button.dart';
import 'package:tool_rental_app/services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedAgeRange;

  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  bool _obscurePassword = true;
  bool _isProcessing = false;
  String _buttonText = "Register";
  bool _agreedToTerms = false; // New state for the checkbox

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // =================== REGISTER LOGIC ===================
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAgeRange == null) {
      _showErrorDialog("Incomplete Form", "Please select an age range.");
      return;
    }

    if (!_agreedToTerms) {
      _showErrorDialog("Agreement Required", "You must agree to the terms and conditions.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog("Password Mismatch", "Passwords do not match.");
      return;
    }
    if (_contactController.text.trim().length != 10) {
      _showErrorDialog(
          "Invalid Phone Number", "Contact number must be 10 digits.");
      return;
    }

    setState(() {
      _isProcessing = true;
      _buttonText = "Processing...";
    });

    try {
      final registrationFuture = _auth.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final delayFuture = Future.delayed(const Duration(seconds: 4));

      final result = await Future.wait([registrationFuture, delayFuture]);
      final user = result[0];

      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "name": _nameController.text.trim(),
          "contact": _contactController.text.trim(),
          "email": _emailController.text.trim(),
          "age": _selectedAgeRange,
          "createdAt": FieldValue.serverTimestamp(),
        });

        await _showSuccessDialog(
            "Registration Successful", "Your account has been created.");
      } else {
        _showErrorDialog(
            "Registration Failed", "Could not complete registration.");
      }
    } catch (e) {
      String errorMessage = "An unexpected error occurred.";
      if (e.toString().contains('email-already-in-use')) {
        errorMessage =
        "This email is already in use. Please use a different one or login.";
      } else {
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      }
      _showErrorDialog("Registration Failed", errorMessage);
    } finally {
      setState(() {
        _isProcessing = false;
        _buttonText = "Register";
      });
    }
  }

  // =================== SUCCESS DIALOG ===================
  Future<void> _showSuccessDialog(String title, String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Go to Login", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // =================== ERROR DIALOG ===================
  Future<void> _showErrorDialog(String title, String message,
      {bool showReset = false}) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.black)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.black87)),
        actions: [
          if (showReset)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: const Text("Reset Password", style: TextStyle(color: Colors.blue)),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // =================== UI ===================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                        controller: _nameController,
                        hint: "Full Name",
                        icon: Icons.person),
                    const SizedBox(height: 20),
                    _buildTextField(
                        controller: _contactController,
                        hint: "Contact Number",
                        icon: Icons.phone,
                        keyboard: TextInputType.phone),
                    const SizedBox(height: 20),
                    _buildTextField(
                        controller: _emailController,
                        hint: "Email",
                        icon: Icons.email,
                        keyboard: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _buildAgeDropdown(),
                    const SizedBox(height: 20),
                    _buildTextField(
                        controller: _passwordController,
                        hint: "Password",
                        icon: Icons.lock,
                        obscure: _obscurePassword,
                        toggleObscure: () =>
                            setState(() => _obscurePassword = !_obscurePassword)),
                    const SizedBox(height: 20),
                    _buildTextField(
                        controller: _confirmPasswordController,
                        hint: "Confirm Password",
                        icon: Icons.lock,
                        obscure: _obscurePassword,
                        toggleObscure: () =>
                            setState(() => _obscurePassword = !_obscurePassword)),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _agreedToTerms = newValue!;
                            });
                          },
                          activeColor: Colors.greenAccent,
                        ),
                        const Expanded(
                          child: Text(
                            "I agree to the Terms and Conditions",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    AnimatedButton(
                      text: _buttonText,
                      onTap: () {
                        if (!_isProcessing) {
                          _register();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.login, color: Colors.greenAccent),
                      label: const Text(
                        "Already have an account? Login",
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return "$hint cannot be empty";
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        errorStyle: const TextStyle(color: Colors.redAccent),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: toggleObscure != null
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: toggleObscure,
        )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboard,
    );
  }

  Widget _buildAgeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedAgeRange,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: "Age Range",
          hintStyle: const TextStyle(color: Colors.white70),
          errorStyle: const TextStyle(color: Colors.redAccent),
          prefixIcon: const Icon(Icons.cake, color: Colors.white70),
          border: InputBorder.none,
        ),
        dropdownColor: const Color(0xFF2c5364),
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        items: <String>['0-18', '19-40', '40+']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedAgeRange = newValue;
          });
        },
        validator: (value) =>
        value == null ? "Please select an age range" : null,
      ),
    );
  }
}