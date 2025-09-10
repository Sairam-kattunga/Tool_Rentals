import 'package:flutter/material.dart';
import '../widgets/animated_button.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  bool _loading = false;

  // Success tick animation
  late AnimationController _tickController;
  late Animation<double> _tickAnimation;
  bool _showTick = false;

  @override
  void initState() {
    super.initState();
    _tickController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tickAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _tickController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tickController.dispose();
    super.dispose();
  }

  void _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    await _auth.sendPasswordResetEmail(_emailController.text);

    setState(() {
      _loading = false;
      _showTick = true;
    });

    _tickController.forward();

    // Show a dialog with a custom message after the email is sent
    await Future.delayed(const Duration(milliseconds: 1000));
    _showSuccessDialog("Success", "A password reset link has been sent to your email. Please check your inbox and **your spam folder** if you don't see it.");
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pop(context); // Go back to login screen
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

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
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          "Reset Password",
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                        controller: _emailController,
                        hint: "Enter your email",
                        icon: Icons.email),
                    const SizedBox(height: 30),
                    _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : AnimatedButton(
                        text: "Send Reset Email", onTap: _sendReset),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
                      label: const Text("Back to Login",
                          style: TextStyle(color: Colors.greenAccent)),
                    ),
                    const SizedBox(height: 30),
                    if (_showTick)
                      ScaleTransition(
                        scale: _tickAnimation,
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 80,
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (val) =>
      val == null || val.isEmpty ? "$hint cannot be empty" : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}