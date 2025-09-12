// app_settings_screen.dart
import 'package:flutter/material.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings", style: TextStyle(color: Colors.white)),
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
              trailing: Switch(value: true, onChanged: (val) {}),
            ),
            _buildSettingTile(
              icon: Icons.language,
              title: "Language",
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
            ),

            const SizedBox(height: 16),

            _buildSectionTitle("Privacy & Location"),
            _buildSettingTile(
              icon: Icons.notifications,
              title: "Notifications",
              trailing: Switch(value: true, onChanged: (val) {}),
              onTap: () {
                // TODO: Add logic to navigate to a notification settings screen
              },
            ),
            _buildSettingTile(
              icon: Icons.location_on,
              title: "Location Settings",
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () {
                // TODO: Use a package like `geolocator` or `app_settings` to open device location settings
              },
            ),
            _buildSettingTile(
              icon: Icons.security,
              title: "Privacy Settings",
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () {
                // TODO: Navigate to a privacy policy screen or an in-app privacy settings page
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
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}