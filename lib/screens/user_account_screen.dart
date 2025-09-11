// user_account_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Placeholder functions for navigation/actions
  void _handleSignIn() {
    // Navigate to the sign-in screen
    Navigator.of(context).pushNamed('/login');
  }

  void _handleEditProfile() {
    // TODO: Implement navigation to Edit Profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Edit Profile...')),
    );
  }

  void _handleAddresses() {
    // TODO: Implement navigation to Addresses screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Addresses...')),
    );
  }

  void _handleSharedItems() {
    // TODO: Implement navigation to Shared Items screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Shared Items...')),
    );
  }

  void _handleBorrowedItems() {
    // TODO: Implement navigation to Borrowed Items screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Borrowed Items...')),
    );
  }

  void _handleMyAds() {
    // TODO: Implement navigation to My Ads screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to My Ads...')),
    );
  }

  void _handleMyFavorites() {
    // TODO: Implement navigation to My Favorites screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to My Favorites...')),
    );
  }

  void _handleMyContactRequests() {
    // TODO: Implement navigation to My Contact Requests screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to My Contact Requests...')),
    );
  }

  void _handleMyNotifications() {
    // TODO: Implement navigation to My Notifications screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to My Notifications...')),
    );
  }

  void _handleTransactions() {
    // TODO: Implement navigation to Transactions screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Transactions...')),
    );
  }

  void _handleSubscription() {
    // TODO: Implement navigation to Subscription screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Subscription...')),
    );
  }

  Future<void> _handleDeleteAccount() async {
    // TODO: Implement account deletion logic
    // This is a critical action. Ensure a confirmation dialog is used.
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          title: const Text("Confirm Deletion", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deletion process initiated...')),
      );
      // Actual Firebase deletion logic would go here
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
        title: const Text("User Account", style: TextStyle(color: Colors.white)),
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
              // User Info Section
              _buildUserInfoSection(),

              const SizedBox(height: 30),

              // General Options Section
              _buildSectionTitle("General"),
              _buildListTile(Icons.edit, "Edit Profile", _handleEditProfile),
              _buildListTile(Icons.location_on, "Addresses", _handleAddresses),

              const SizedBox(height: 20),

              // My Items Section
              _buildSectionTitle("My Items"),
              _buildListTile(Icons.handyman, "Shared Items", _handleSharedItems),
              _buildListTile(Icons.shopping_bag, "Borrowed Items", _handleBorrowedItems),
              _buildListTile(Icons.campaign, "My Ads", _handleMyAds),
              _buildListTile(Icons.favorite, "My Favorites", _handleMyFavorites),

              const SizedBox(height: 20),

              // Activity & Communication Section
              _buildSectionTitle("Activity & Communication"),
              _buildListTile(Icons.chat, "My Contact Requests", _handleMyContactRequests),
              _buildListTile(Icons.notifications, "My Notifications", _handleMyNotifications),
              _buildListTile(Icons.receipt_long, "Transactions / Invoices", _handleTransactions),

              const SizedBox(height: 20),

              // Subscription & Management
              _buildSectionTitle("Subscription & Management"),
              _buildListTile(Icons.subscriptions, "Subscription Model / Plans", _handleSubscription),
              _buildListTile(Icons.delete_forever, "Delete My Account", _handleDeleteAccount),
              _buildListTile(Icons.logout, "Logout", _handleLogout),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    // If user is not logged in, show a sign-in button
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
              onPressed: _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Sign In / Sign Up", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );
    }

    // If user is logged in, show their details
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
            _user!.email ?? "User",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Member since July 2023", // Placeholder
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
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

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: Colors.white.withOpacity(0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
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
}