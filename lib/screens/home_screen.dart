import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_rental_app/screens/ToolPackage/tool_packages_screen.dart';
import 'package:tool_rental_app/screens/Listing/listing_choice_screen.dart';
import '../services/auth_service.dart';
import 'dart:async';
import 'package:tool_rental_app/screens/Vehicles/vehicle_rental_screen.dart'; // NEW IMPORT

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
  final PageController _pageController = PageController();

  final List<String> _adImages = [
    'lib/assets/ads/ad1.png',
    'lib/assets/ads/ad2.png',
    'lib/assets/ads/ad3.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_pageController.hasClients) {
        timer.cancel();
        return;
      }
      final int currentPage = _pageController.page!.round();
      final int nextPage = currentPage + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('email');
    await prefs.remove('password');
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _navigateTo(String route) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
    // Handle specific routes
    switch (route) {
      case '/rent_tool':
        Navigator.of(context).pushNamed('/rent_tool');
        break;
      case '/list_choice':
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ListingChoiceScreen()));
        break;
      case '/my_tools':
        Navigator.of(context).pushNamed('/my_tools');
        break;
      case '/my_rentals':
        Navigator.of(context).pushNamed('/my_rentals');
        break;
      case '/tool_packages':
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ToolPackagesScreen()));
        break;
      case '/vehicle_rentals':
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const VehicleRentalScreen()));
        break;
      default:
        Navigator.of(context).pushNamed(route);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      InkWell(
                        onTap: () => _navigateTo('/profile'),
                        child: ClipOval(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.white.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 10000,
                    itemBuilder: (context, index) {
                      final imageIndex = index % _adImages.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            _adImages[imageIndex],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Dashboard",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildActionCard(
                                icon: Icons.handyman,
                                label: "Rent a Tool",
                                onTap: () => _navigateTo('/rent_tool'),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                                ),
                              ),
                              _buildActionCard(
                                icon: Icons.add_box,
                                label: "List a Tool",
                                onTap: () => _navigateTo('/list_choice'),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFDC830), Color(0xFFF37335)],
                                ),
                              ),
                              _buildActionCard(
                                icon: Icons.construction,
                                label: "My Tools",
                                onTap: () => _navigateTo('/my_tools'),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                                ),
                              ),
                              _buildActionCard(
                                icon: Icons.history,
                                label: "My Rentals",
                                onTap: () => _navigateTo('/my_rentals'),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF38ef7d), Color(0xFF11998e)],
                                ),
                              ),
                              _buildActionCard(
                                icon: Icons.local_mall,
                                label: "Tool Packages",
                                onTap: () => _navigateTo('/tool_packages'),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD66D75), Color(0xFFE29587)],
                                ),
                              ),
                              // NEW VEHICLE RENTALS CARD
                              _buildActionCard(
                                icon: Icons.directions_car,
                                label: "Vehicle Rentals",
                                onTap: () => _navigateTo('/vehicle_rentals'),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFC04848), Color(0xFF480048)],
                                ),
                              ),
                            ],
                          ),
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
            _buildDrawerItem(Icons.account_circle, "User Account", () => _navigateTo('/profile')),
            _buildDrawerItem(Icons.settings, "App Settings", () => _navigateTo('/app_settings')),
            _buildDrawerItem(Icons.policy, "Policies", () => _navigateTo('/policies')),
            _buildDrawerItem(Icons.help, "Help & Info", () => _navigateTo('/help_info')),
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

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required LinearGradient gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return gradient.createShader(bounds);
              },
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontSize: 16)),
      onTap: onTap,
    );
  }
}