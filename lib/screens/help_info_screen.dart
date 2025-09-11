// help_info_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpInfoScreen extends StatelessWidget {
  const HelpInfoScreen({super.key});

  // Placeholder for navigation logic, you will need to replace this
  void _handleNavigation(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Navigating to $title...")),
    );
    // Example of actual navigation:
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => SomeOtherScreen()));
  }

  // Function to launch a URL
  Future<void> _launchURL(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Info", style: TextStyle(color: Colors.white)),
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          children: [
            _buildSectionTitle("General"),
            _buildListTile(
              icon: Icons.info_outline,
              title: "About Us",
              onTap: () => _handleNavigation(context, "About Us"),
            ),
            _buildListTile(
              icon: Icons.contact_mail,
              title: "Contact Us",
              onTap: () => _handleNavigation(context, "Contact Us"),
            ),
            _buildListTile(
              icon: Icons.support_agent,
              title: "Raise a Ticket / Support",
              onTap: () => _handleNavigation(context, "Raise a Ticket"),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("Resources"),
            _buildListTile(
              icon: Icons.help_outline,
              title: "Frequently Asked Questions (FAQs)",
              onTap: () => _handleNavigation(context, "FAQs"),
            ),
            _buildListTile(
              icon: Icons.policy,
              title: "Refund Policy",
              onTap: () => _handleNavigation(context, "Refund Policy"),
            ),
            _buildListTile(
              icon: Icons.article_outlined,
              title: "Privacy & Terms",
              onTap: () => _handleNavigation(context, "Privacy & Terms"),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("App Information"),
            _buildListTile(
              icon: Icons.info,
              title: "Version Info",
              onTap: () => _showVersionDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }

  void _showVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          title: const Text("App Version", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Version 1.0.0",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }
}