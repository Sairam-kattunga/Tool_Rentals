import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'AddressesScreen.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<void> _handleEditProfile() async {
    if (_user == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => _EditProfileScreen(user: _user!)),
    );
  }

  void _handleAddresses() {
    if (_user == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddressesScreen()),
    );
  }

  // Placeholder functions remain the same
  void _handleSharedItems() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Shared Items...')),
    );
  }

  void _handleBorrowedItems() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Borrowed Items...')),
    );
  }

  void _handleMyAds() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to My Ads...')),
    );
  }

  void _handleMyFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to My Favorites...')),
    );
  }

  void _handleMyContactRequests() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to My Contact Requests...')),
    );
  }

  void _handleMyNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to My Notifications...')),
    );
  }

  void _handleTransactions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Transactions...')),
    );
  }

  void _handleSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Subscription...')),
    );
  }

  Future<void> _handleDeleteAccount() async {
    if (_user == null) return;

    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          title: const Text("Confirm Deletion",
              style: TextStyle(color: Colors.white)),
          content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete",
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      try {
        // Step 1: Re-authenticate the user for security
        final credential = await showDialog<AuthCredential?>(
          context: context,
          builder: (BuildContext context) {
            final TextEditingController passwordController =
            TextEditingController();
            return AlertDialog(
              backgroundColor: const Color(0xFF203a43),
              title: const Text("Re-authenticate",
                  style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Please enter your password to confirm.",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: () {
                    final credential = EmailAuthProvider.credential(
                        email: _user!.email!,
                        password: passwordController.text);
                    Navigator.of(context).pop(credential);
                  },
                  child: const Text("Submit",
                      style: TextStyle(color: Colors.greenAccent)),
                ),
              ],
            );
          },
        );

        if (credential != null) {
          await _user!.reauthenticateWithCredential(credential);

          // Step 2: Delete user data from Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.uid)
              .delete();

          // Step 3: Delete user from Firebase Auth
          await _user!.delete();

          // Step 4: Logout and clear local data
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Account deleted successfully.')),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = "Failed to delete account.";
        if (e.code == 'requires-recent-login') {
          message =
          'This operation requires recent authentication. Please sign in again and retry.';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('email');
      await prefs.remove('password');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Account",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoSection(),
              const SizedBox(height: 30),
              _buildSectionTitle("General"),
              _buildListTile(Icons.edit, "Edit Profile", _handleEditProfile),
              _buildListTile(Icons.location_on, "Addresses", _handleAddresses),
              const SizedBox(height: 20),
              _buildSectionTitle("My Items"),
              _buildListTile(
                  Icons.handyman, "Shared Items", _handleSharedItems),
              _buildListTile(
                  Icons.shopping_bag, "Borrowed Items", _handleBorrowedItems),
              _buildListTile(Icons.campaign, "My Ads", _handleMyAds),
              _buildListTile(
                  Icons.favorite, "My Favorites", _handleMyFavorites),
              const SizedBox(height: 20),
              _buildSectionTitle("Activity & Communication"),
              _buildListTile(Icons.chat, "My Contact Requests",
                  _handleMyContactRequests),
              _buildListTile(Icons.notifications, "My Notifications",
                  _handleMyNotifications),
              _buildListTile(Icons.receipt_long, "Transactions / Invoices",
                  _handleTransactions),
              const SizedBox(height: 20),
              _buildSectionTitle("Subscription & Management"),
              _buildListTile(Icons.subscriptions, "Subscription Model / Plans",
                  _handleSubscription),
              _buildListTile(Icons.delete_forever, "Delete My Account",
                  _handleDeleteAccount,
                  isDestructive: true),
              _buildListTile(Icons.logout, "Logout", _handleLogout),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    if (_user == null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.person_off, size: 80, color: Colors.white70),
            const SizedBox(height: 16),
            const Text(
              "You are not signed in.",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Sign In / Sign Up",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String name = userData['name'] ?? 'User';
        String email = userData['email'] ?? _user!.email;
        Timestamp? createdAt = userData['createdAt'];
        String memberSince = "Date not available";
        if (createdAt != null) {
          memberSince =
          "Member since ${DateFormat('MMMM yyyy').format(createdAt.toDate())}";
        }
        return Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                email,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                memberSince,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return Card(
      color: Colors.white.withOpacity(0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon,
            color: isDestructive ? Colors.redAccent : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
              color: isDestructive ? Colors.redAccent : Colors.white,
              fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}

// =========================================================================
// NEW: Edit Profile Screen
// =========================================================================
class _EditProfileScreen extends StatefulWidget {
  final User user;
  const _EditProfileScreen({required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController(); // Added
  String? _selectedAgeRange; // Added
  bool _isLoading = false;

  final List<String> _ageRanges = ['0-18', '19-40', '40+'];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
      if (doc.exists) {
        var userData = doc.data() as Map<String, dynamic>;
        _nameController.text = userData['name'] ?? '';
        _contactController.text = userData['contact'] ?? '';
        _selectedAgeRange = userData['age'];
        setState(() {}); // Refresh UI with loaded data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load data: $e")),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'name': _nameController.text.trim(),
        'contact': _contactController.text.trim(),
        'age': _selectedAgeRange,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  hint: "Full Name",
                  icon: Icons.person,
                  validator: (val) =>
                  val!.isEmpty ? "Name cannot be empty" : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _contactController,
                  hint: "Contact Number",
                  icon: Icons.phone,
                  keyboard: TextInputType.phone,
                  validator: (val) {
                    if (val!.isEmpty) return "Contact number cannot be empty";
                    if (val.trim().length != 10) return "Number must be 10 digits";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildAgeDropdown(),
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.greenAccent,
                    ))
                    : ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Save Changes",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAgeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedAgeRange,
        isExpanded: true,
        decoration: const InputDecoration(
          hintText: "Age Range",
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.cake, color: Colors.white70),
          border: InputBorder.none,
        ),
        dropdownColor: const Color(0xFF2c5364),
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        items: _ageRanges.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedAgeRange = newValue;
          });
        },
        validator: (value) =>
        value == null ? "Please select an age range" : null,
      ),
    );
  }
}