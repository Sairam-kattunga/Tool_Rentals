import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF203a43), // Solid color for visibility
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
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
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const SizedBox(height: 20),
                  // Theme Toggle
                  _buildSettingsTile(
                    icon: Icons.lightbulb_outline,
                    title: "Toggle Light/Dark Mode",
                    onTap: () {
                      // TODO: Implement theme change logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Theme change feature coming soon!")),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  // About Us
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: "About Us",
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(color: Colors.white24),
                  // Rate App
                  _buildSettingsTile(
                    icon: Icons.star_border,
                    title: "Rate This App",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Redirecting to app store...")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("About ToolRental"),
        content: const Text(
            "ToolRental is an app designed to help you easily rent and lend tools for your projects."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}