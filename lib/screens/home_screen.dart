// home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'dart:async';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // Import the staggered grid package

// New dummy screens for navigation
class PropertyRentalScreen extends StatelessWidget {
  const PropertyRentalScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Rentals'),
        backgroundColor: const Color(0xFF203a43),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Explore various property rentals.",
                style: TextStyle(fontSize: 20, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "🏠 Houses, Apartments, Rooms, Co-living Spaces, Storage Spaces 📦",
                style: TextStyle(fontSize: 16, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFF0f2027),
    );
  }
}

class ExperienceRentalScreen extends StatelessWidget {
  const ExperienceRentalScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experience Rentals'),
        backgroundColor: const Color(0xFF203a43),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Rent a person or service for a unique experience.",
                style: TextStyle(fontSize: 20, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "🎧 DJ, Photographer, Tour Guide, Personal Trainer 🏋️‍♀️",
                style: TextStyle(fontSize: 16, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFF0f2027),
    );
  }
}

class LuxuryLifestyleScreen extends StatelessWidget {
  const LuxuryLifestyleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luxury & Lifestyle'),
        backgroundColor: const Color(0xFF203a43),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Indulge in designer goods and premium items.",
                style: TextStyle(fontSize: 20, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "💎 Designer Clothes, Jewelry, Premium Watches, Handbags 🛍️",
                style: TextStyle(fontSize: 16, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFF0f2027),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  String? _name;
  final PageController _pageController = PageController(viewportFraction: 0.92);

  final List<String> _adImages = [
    'lib/assets/ads/ad1.png',
    'lib/assets/ads/ad2.png',
    'lib/assets/ads/ad3.png',
  ];

  final List<String> _adRoutes = [
    '/rent_tool',
    '/vehicle_rentals',
    '/tool_packages',
  ];

  int _currentAd = 0;
  final Map<int, bool> _isCardPressed = {};

  late final AnimationController _navAnimController;
  late final Animation<double> _scaleAnimation;
  Timer? _adAutoScrollTimer;

  // List of category data for the grid
  final List<Map<String, dynamic>> _categories = [
    {
      'title': "Tools",
      'subtitle': "Rent top tools",
      'image': 'lib/assets/Categories/Tools.png',
      'route': '/rent_tool',
    },
    {
      'title': "Packages",
      'subtitle': "Value bundles",
      'image': 'lib/assets/Categories/Packages.png',
      'route': '/tool_packages',
    },
    {
      'title': "Vehicles",
      'subtitle': "Cars & Bikes",
      'image': 'lib/assets/Categories/Vehicles.png',
      'route': '/vehicle_rentals',
    },
    {
      'title': "Property Rentals",
      'subtitle': "Houses & storage",
      'image': 'lib/assets/Categories/properties.png',
      'route': '/property_rentals',
    },
    {
      'title': "Experience Rentals",
      'subtitle': "Rent a person or service",
      'image': 'lib/assets/Categories/Experiences.png',
      'route': '/experience_rentals',
    },
    {
      'title': "Luxury & Lifestyle",
      'subtitle': "Designer goods & more",
      'image': 'lib/assets/Categories/Luxuries.png',
      'route': '/luxury_lifestyle',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startAutoScroll();
    _navAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _navAnimController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navAnimController.dispose();
    _adAutoScrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _adAutoScrollTimer?.cancel();
    _adAutoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_pageController.hasClients) {
        if (timer.isActive) timer.cancel();
        return;
      }
      _currentAd++;
      _pageController.animateToPage(
        _currentAd,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (mounted) {
        setState(() {
          _name = doc.data()?["name"] ?? "User";
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
    Navigator.pushNamed(context, route);
  }

  void _onAdTap(int index) {
    final route = (index >= 0 && index < _adRoutes.length) ? _adRoutes[index % _adRoutes.length] : null;
    if (route != null) {
      _navigateTo(route);
    }
  }

  void _onCardTapDown(int index) => setState(() => _isCardPressed[index] = true);
  void _onCardTapUp(int index) => setState(() => _isCardPressed[index] = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      backgroundColor: const Color(0xFF0f2027),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'lib/assets/Logo_intro.png',
                          height: 28,
                          width: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "RentEazy",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _navigateTo('/profile'),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white, size: 26),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: null,
                      onPageChanged: (int p) => setState(() => _currentAd = p),
                      itemBuilder: (context, index) {
                        final imageIndex = index % _adImages.length;
                        return GestureDetector(
                          onTap: () => _onAdTap(imageIndex),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                            child: Hero(
                              tag: 'ad_$imageIndex',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  _adImages[imageIndex],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_adImages.length, (i) {
                        final selected = i == (_currentAd % _adImages.length);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: selected ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : Colors.white38,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                // Replace GridView.count with MasonryGridView.count
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryCard(
                      index: index,
                      title: category['title'],
                      subtitle: category['subtitle'],
                      image: category['image'],
                      onTap: () => _navigateTo(category['route']),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF203a43), Color(0xFF2c5364)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 6))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.build, "My Tools", '/my_tools'),
                _buildBottomNavItem(Icons.account_balance_wallet, "Wallet", '/wallet'),
                _buildPlusNavItem(),
                _buildBottomNavItem(Icons.explore, "Rentals", '/my_rentals'),
                _buildBottomNavItem(Icons.history, "History", '/history'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlusNavItem() {
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateTo('/list_choice'),
        onTapDown: (_) => _navAnimController.forward(),
        onTapUp: (_) => _navAnimController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2c5364), Color(0xFF203a43)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required int index,
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    final bool pressed = _isCardPressed[index] ?? false;
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => _onCardTapDown(index),
      onTapUp: (_) => _onCardTapUp(index),
      onTapCancel: () => _onCardTapUp(index),
      child: AnimatedScale(
        scale: pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2c5364), Color(0xFF203a43)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
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
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/Logo_intro.png',
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(height: 8),
                    const Text("RentEazy", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(Icons.home, "Home", () => _navigateTo('/home')),
            _buildDrawerItem(Icons.account_circle, "User Account", () => _navigateTo('/user_account')),
            _buildDrawerItem(Icons.settings, "App Settings", () => _navigateTo('/app_settings')),
            _buildDrawerItem(Icons.policy, "Policies", () => _navigateTo('/policies')),
            _buildDrawerItem(Icons.help, "Help & Info", () => _navigateTo('/help_info')),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _buildDrawerItem(Icons.logout, "Logout", () => _logout(), color: Colors.redAccent),
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