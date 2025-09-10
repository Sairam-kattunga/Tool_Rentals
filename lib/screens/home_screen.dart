import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
// Note: You do not need to import specific screens here if you are using named routes.
// import '../screens/list_tool_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  String? _name;
  String? _email;
  String? _contact;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to load user data from Firebase
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

      if (mounted) {
        setState(() {
          _name = doc.data()?["name"] ?? "User";
          _email = doc.data()?["email"] ?? user.email;
          _contact = doc.data()?["contact"] ?? "N/A";
        });
      }
    }
  }

  // Function to handle user logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('email');
    await prefs.remove('password');
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Updated navigation to use named routes
  void _navigateTo(String route) {
    Navigator.pop(context); // Close the drawer first
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Background Gradient
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar with Hamburger
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      const Text(
                        "ToolRental",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.notifications, color: Colors.white, size: 28),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Main Action Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildActionCard(
                          icon: Icons.handyman,
                          label: "Rent a Tool",
                          // ✅ FIXED: Using a named route string
                          onTap: () => _navigateTo('/rent_tool'),
                        ),
                        _buildActionCard(
                          icon: Icons.add_box,
                          label: "List a Tool",
                          onTap: () => _navigateTo('/list_tool'),
                        ),
                        _buildActionCard(
                          icon: Icons.account_balance_wallet,
                          label: "Wallet",
                          onTap: () => _navigateTo('/wallet'),
                        ),
                        _buildActionCard(
                          icon: Icons.history,
                          label: "History",
                          onTap: () => _navigateTo('/history'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated Drawer without user details and logo
  // Updated Drawer with a new "My Tools" tile
  Drawer _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Center(
                child: Text(
                  "Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildDrawerItem(Icons.home, "Home", () => _navigateTo('/home')),
            _buildDrawerItem(Icons.person, "Profile", () => _navigateTo('/profile')),
            _buildDrawerItem(Icons.handyman, "My Tools", () => _navigateTo('/my_tools')), // New tile
            _buildDrawerItem(Icons.settings, "Settings", () => _navigateTo('/settings')),
            _buildDrawerItem(Icons.help, "Help / Support", () => _navigateTo('/support')),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _buildDrawerItem(
              Icons.logout,
              "Logout",
                  () => _logout(),
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget for action cards
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget for drawer items
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontSize: 16)),
      onTap: onTap,
    );
  }
}