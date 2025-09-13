// app_settings_screen.dart
import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text("App Settings", style: TextStyle(color: Colors.white)),
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
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle("General"),
            _buildSettingTile(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (val) {
                  setState(() {
                    _isDarkMode = val;
                  });
                },
              ),
            ),
            _buildSettingTile(
              icon: Icons.language,
              title: "Language",
              trailing:
              const Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () => _showLanguageDialog(),
            ),

            const SizedBox(height: 16),

            _buildSectionTitle("Privacy & Location"),
            _buildSettingTile(
              icon: Icons.notifications,
              title: "Notifications",
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (val) {
                  setState(() {
                    _notificationsEnabled = val;
                  });
                },
              ),
            ),
            _buildSettingTile(
              icon: Icons.location_on,
              title: "Location Settings",
              trailing:
              const Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                    Text("Redirecting to location settings... (TODO)"),
                  ),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.security,
              title: "Privacy Settings",
              trailing:
              const Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Opening Privacy Settings... (TODO)"),
                  ),
                );
              },
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.15),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF203a43),
        title: const Text("Select Language",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: const Text("English",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Language set to English")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: const Text("Hindi",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Language set to Hindi")),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white70)),
          )
        ],
      ),
    );
  }
}
