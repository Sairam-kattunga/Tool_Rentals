// policies_screen.dart
import 'package:flutter/material.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Policies", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: [
            _buildPolicyTile(
              context,
              title: "Return & Refund Policy",
              content: "Our policy on returns and refunds for rentals outlines the conditions, timelines, and process for users to request a return or a refund. Please review this section carefully before making a transaction.",
            ),
            _buildPolicyTile(
              context,
              title: "Terms & Conditions / Terms of Use",
              content: "These terms govern your use of the app and all its services. By using our platform, you agree to abide by these terms, which cover user responsibilities, intellectual property, and acceptable use.",
            ),
            _buildPolicyTile(
              context,
              title: "Privacy Policy",
              content: "Our privacy policy explains how we collect, use, and protect your personal data. We are committed to safeguarding your information and this policy details your rights and our obligations regarding your data.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyTile(BuildContext context, {required String title, required String content}) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white70,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}