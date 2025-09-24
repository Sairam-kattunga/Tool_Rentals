import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_rental_app/widgets/animated_button.dart';
import 'package:tool_rental_app/services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _showLoginSuccess = false;

  late AnimationController _tickController;
  late Animation<double> _tickAnimation;

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

    _checkLoginStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tickController.dispose();
    super.dispose();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  void _saveLoginSession(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setBool('isLoggedIn', true);
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _showLoginSuccess = false;
    });

    try {
      final user = await _auth.loginWithEmail(
          _emailController.text, _passwordController.text);

      if (user != null) {
        _saveLoginSession(_emailController.text, _passwordController.text);

        setState(() {
          _loading = false;
          _showLoginSuccess = true;
        });

        _tickController.forward();
        await Future.delayed(const Duration(milliseconds: 1000));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _loading = false);
        _showErrorDialog("Login Failed", "Invalid email or password.");
      }
    } catch (e) {
      setState(() => _loading = false);
      _showErrorDialog("Error", "An unexpected error occurred. Check your login credentials and TRY AGAIN");
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.black)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
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
                    const SizedBox(height: 60),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                        controller: _emailController,
                        hint: "Email",
                        icon: Icons.email,
                        autofillHints: const [AutofillHints.username, AutofillHints.email]),
                    const SizedBox(height: 20),
                    _buildTextField(
                        controller: _passwordController,
                        hint: "Password",
                        icon: Icons.lock,
                        obscure: _obscurePassword,
                        toggleObscure: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        autofillHints: const [AutofillHints.password]),
                    const SizedBox(height: 30),
                    if (_loading)
                      const CircularProgressIndicator(color: Colors.white)
                    else if (_showLoginSuccess)
                      ScaleTransition(
                        scale: _tickAnimation,
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent,
                          size: 60,
                        ),
                      )
                    else
                      AnimatedButton(text: "Login", onTap: _login),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen()),
                        );
                      },
                      icon: const Icon(Icons.lock_reset, color: Colors.lightBlue),
                      label: const Text("Forgot Password?",
                          style: TextStyle(color: Colors.lightBlue)),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        );
                      },
                      icon: const Icon(Icons.person_add, color: Colors.greenAccent),
                      label: const Text("Don't have an account? Register",
                          style: TextStyle(color: Colors.greenAccent)),
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
    List<String>? autofillHints,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      autofillHints: autofillHints,
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
        contentPadding:
        const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}