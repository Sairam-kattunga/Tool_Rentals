import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // Function to launch email client
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@toolrental.com', // Replace with your support email
      query: 'subject=Support Request&body=Hello, I need help with...',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Help / Support", style: TextStyle(color: Colors.white)),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "How can we help you?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Contact Support Tile
                    _buildSupportTile(
                      icon: Icons.email_outlined,
                      title: "Contact Support",
                      subtitle: "Send us an email with your issue",
                      onTap: _launchEmail,
                    ),
                    const Divider(color: Colors.white24),
                    // FAQ Tile
                    _buildSupportTile(
                      icon: Icons.help_outline,
                      title: "FAQ",
                      subtitle: "Find answers to common questions",
                      onTap: () {
                        // TODO: Navigate to FAQ page or show dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("FAQ feature coming soon!")),
                        );
                      },
                    ),
                    const Divider(color: Colors.white24),
                    // Call Us Tile
                    _buildSupportTile(
                      icon: Icons.phone_outlined,
                      title: "Call Us",
                      subtitle: "Talk to a support agent",
                      onTap: () async {
                        final Uri phoneLaunchUri = Uri(
                          scheme: 'tel',
                          path: '1234567890', // Replace with your support phone number
                        );
                        if (await canLaunchUrl(phoneLaunchUri)) {
                          await launchUrl(phoneLaunchUri);
                        } else {
                          throw 'Could not launch $phoneLaunchUri';
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: onTap,
    );
  }
}