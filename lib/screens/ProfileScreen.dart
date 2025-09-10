import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  String? _name;
  String? _email;
  String? _contact;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (mounted) {
        setState(() {
          _name = doc.data()?["name"] ?? "User";
          _email = doc.data()?["email"] ?? user.email;
          _contact = doc.data()?["contact"] ?? "N/A";
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('email');
    await prefs.remove('password');
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2c5364), // ✅ Added AppBar background
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // ✅ Made back button visible
      ),
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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      "lib/assets/Logo.png",
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Welcome, ${_name ?? "User"}!",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildDetailsContainer(),
                  const SizedBox(height: 40),
                  TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.redAccent, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
              icon: Icons.person_outline,
              label: "Name",
              value: _name ?? "Loading..."),
          const SizedBox(height: 16),
          _buildDetailRow(
              icon: Icons.email_outlined,
              label: "Email",
              value: _email ?? "Loading..."),
          const SizedBox(height: 16),
          _buildDetailRow(
              icon: Icons.phone_outlined,
              label: "Contact",
              value: _contact ?? "Loading..."),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: SingleChildScrollView( // ✅ Added SingleChildScrollView to prevent text wrapping
            scrollDirection: Axis.horizontal,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}