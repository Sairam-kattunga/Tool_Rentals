import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tool_rental_app/services/auth_service.dart';
import 'package:tool_rental_app/screens/Profile/AddressesScreen.dart';
// Import the new EditProfileScreen
import 'edit_profile_screen.dart';

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
  String? _age;
  String? _memberSince;
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      _user = user;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
        final data = doc.data() as Map<String, dynamic>?;

        setState(() {
          _name = data?["name"] ?? (user.displayName ?? "User");
          _email = data?["email"] ?? user.email;
          _contact = data?["contact"] ?? "N/A";
          _age = data?["age"] ?? "N/A";

          final Timestamp? createdAt = data?['createdAt'];
          if (createdAt != null) {
            _memberSince = "Member since ${DateFormat('MMMM yyyy').format(createdAt.toDate())}";
          } else {
            _memberSince = "Member since: Date not available";
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleEditProfile() {
    if (_user == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditProfileScreen(user: _user!)),
    ).then((_) {
      // reload profile after returning from edit
      _loadUserData();
    });
  }

  void _handleAddresses() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddressesScreen()),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap, {bool destructive = false}) {
    return Card(
      color: Colors.white.withOpacity(0.06),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: destructive ? Colors.redAccent : Colors.white70),
        title: Text(
          title,
          style: TextStyle(color: destructive ? Colors.redAccent : Colors.white, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProfileDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.greenAccent, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white24, height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2c5364),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.greenAccent, width: 3),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2c5364), Color(0xFF203a43)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 80, color: Colors.greenAccent),
                  ),

                  const SizedBox(height: 12),
                  // Member since line (from edit profile screen)
                  Text(
                    _memberSince ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  // Profile items
                  _buildProfileDetailItem(icon: Icons.person_outline, label: "Name", value: _name ?? "N/A"),
                  _buildProfileDetailItem(icon: Icons.email_outlined, label: "Email", value: _email ?? "N/A"),
                  _buildProfileDetailItem(icon: Icons.phone_outlined, label: "Contact", value: _contact ?? "N/A"),
                  _buildProfileDetailItem(icon: Icons.cake_outlined, label: "Age", value: _age ?? "N/A"),

                  const SizedBox(height: 6),
                  // Action tiles
                  _buildActionTile(Icons.edit, "Edit Profile", _handleEditProfile),
                  _buildActionTile(Icons.location_on, "Addresses", _handleAddresses),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}