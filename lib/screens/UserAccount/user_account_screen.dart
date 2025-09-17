import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  // Placeholder functions
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

  void _handleHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to History...')),
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
              _buildSectionTitle("My Items"),
              _buildListTile(
                  Icons.handyman, "Shared Items", _handleSharedItems),
              _buildListTile(
                  Icons.shopping_bag, "Borrowed Items", _handleBorrowedItems),
              _buildListTile(
                  Icons.history, "History", _handleHistory),
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
    return Container(); // Removed user info section
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