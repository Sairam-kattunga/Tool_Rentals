import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class HelpInfoScreen extends StatelessWidget {
  const HelpInfoScreen({super.key});

  // Launch email
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'sairamkattunga333@gmail.com',
      query: 'subject=Customer Support&body=Hello, I need help with...',
    );
    await launchUrl(emailUri);
  }

  // Launch call
  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '9642736457');
    await launchUrl(phoneUri);
  }

  // Launch WhatsApp
  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse("https://wa.me/919642736457?text=Hello%20Support");
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }

  // Share app
  void _shareApp() {
    Share.share(
      "Check out Tools Rental App! Rent tools hassle-free.\nDownload here: https://play.google.com/store/apps/details?id=com.toolsrental.app",
    );
  }

  // Show About dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF203a43),
        title: const Text("About Us", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Tools Rental App helps users rent and manage tools easily.\n\n"
              "🚀 Mission: To make tool renting simple, affordable, and accessible.\n"
              "🔧 What we offer: Wide range of tools, quick booking, and secure payments.\n"
              "🌍 Vision: A connected marketplace for every tool rental need.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  // Show Privacy Policy
  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF203a43),
        title: const Text("Privacy & Terms", style: TextStyle(color: Colors.white)),
        content: const Text(
          "We respect your privacy. Your personal data is stored securely and "
              "never shared with third parties.\n\n"
              "By using this app, you agree to:\n"
              "• Our Terms of Service\n"
              "• Our Privacy Policy\n\n"
              "This ensures a safe and reliable rental experience.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  // Show Version Info (dynamic)
  Future<void> _showVersionDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF203a43),
        title: const Text("App Information", style: TextStyle(color: Colors.white)),
        content: Text(
          "📱 Version: ${packageInfo.version} (${packageInfo.buildNumber})\n"
              "👨‍💻 Developer: Rama Venkata Manikanta Sairam Kattunga\n"
              "📧 Email: sairamkattunga333@gmail.com\n"
              "🔗 GitHub: github.com/Sairam-kattunga",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Info", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
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
            _buildListTile(Icons.info_outline, "About Us", () => _showAboutDialog(context)),

            _buildSectionTitle("Contact"),
            _buildListTile(Icons.contact_mail, "Email Us", _launchEmail),
            _buildListTile(Icons.call, "Call Us", _launchPhone),
            _buildListTile(Icons.chat, "WhatsApp Support", _launchWhatsApp),

            _buildSectionTitle("Support"),
            _buildListTile(Icons.support_agent, "Raise a Ticket", () {
              Navigator.pushNamed(context, '/support');
            }),
            _buildListTile(Icons.chat_bubble_outline, "Live Chat (Coming Soon)", () {}),

            _buildSectionTitle("Resources"),
            _buildListTile(Icons.help_outline, "Frequently Asked Questions (FAQs)", () {
              Navigator.pushNamed(context, '/faq');
            }),
            _buildListTile(Icons.article_outlined, "Privacy & Terms", () => _showPrivacyDialog(context)),

            _buildSectionTitle("App Information"),
            _buildListTile(Icons.info, "Version Info", () => _showVersionDialog(context)),
            _buildListTile(Icons.star_rate, "Rate Us", () {
              launchUrl(Uri.parse("https://play.google.com/store/apps/details?id=com.toolsrental.app"));
            }),
            _buildListTile(Icons.share, "Share App", _shareApp),
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
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}
