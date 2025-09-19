import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_rental_app/screens/ToolPackages/tool_packages_screen.dart';
import 'package:tool_rental_app/screens/listing_choice_screen.dart';
import '../services/auth_service.dart';
import 'dart:async';
import 'package:tool_rental_app/screens/Vehicles/Vehicle_Rental_Screen.dart';

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
  int _currentIndex = 0;

  final Map<int, bool> _isCardPressed = {};

  late final AnimationController _navAnimController;
  late final Animation<double> _scaleAnimation;
  Timer? _adAutoScrollTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startAutoScroll();
    _navAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _navAnimController, curve: Curves.easeOut));
  }

  void _startAutoScroll() {
    _adAutoScrollTimer?.cancel();
    _adAutoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) { // Changed duration to 5 seconds
      if (!_pageController.hasClients) {
        if (timer.isActive) timer.cancel();
        return;
      }
      _currentAd++; // Increment for continuous forward scrolling
      _pageController.animateToPage(
        _currentAd,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navAnimController.dispose();
    _adAutoScrollTimer?.cancel();
    super.dispose();
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
      case '/history':
        Navigator.of(context).pushNamed('/history');
        break;
      default:
        Navigator.of(context).pushNamed(route);
        break;
    }
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
                      Image.asset(
                        'lib/assets/Logo_intro.png',
                        height: 28,
                        width: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "RentEazy",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
                      itemCount: null, // Allow for infinite scrolling
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
                child: ListView(
                  children: [
                    _buildCategoryCard(
                      index: 0,
                      title: "Tools",
                      subtitle: "Rent top tools",
                      image: 'lib/assets/Categories/All.png',
                      gradient: const LinearGradient(colors: [Color(0xFFCED517), Color(0xFF8CD112)]),
                      onTap: () => _navigateTo('/rent_tool'),
                    ),
                    const SizedBox(height: 10),
                    _buildCategoryCard(
                      index: 1,
                      title: "Packages",
                      subtitle: "Value bundles",
                      image: 'lib/assets/Categories/Packages.png',
                      gradient: const LinearGradient(colors: [Color(0xFFD66D75), Color(0xFFE29587)]),
                      onTap: () => _navigateTo('/tool_packages'),
                    ),
                    const SizedBox(height: 10),
                    _buildCategoryCard(
                      index: 2,
                      title: "Vehicles",
                      subtitle: "Cars & Bikes",
                      image: 'lib/assets/Categories/Vehicles.png',
                      gradient: const LinearGradient(colors: [Color(0xFFEF1A1A), Color(0xFFD78CD7)]),
                      onTap: () => _navigateTo('/vehicle_rentals'),
                    ),
                  ],
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
                _buildBottomNavItem(Icons.home, "Home", 0, 0),
                _buildBottomNavItem(Icons.build, "My Tools", 1, 1),
                _buildPlusNavItem(),
                _buildBottomNavItem(Icons.explore, "Rentals", 2, 2),
                _buildBottomNavItem(Icons.history, "History", 3, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int itemIndex, int navIndex) {
    final active = _currentIndex == navIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = navIndex);
          switch (label) {
            case "Home":
              break;
            case "My Tools":
              _navigateTo('/my_tools');
              break;
            case "Rentals":
              _navigateTo('/my_rentals');
              break;
            case "Rentals":
              _navigateTo('/my_rentals');
              break;
            case "History":
              _navigateTo('/profile');
              break;
          }
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? Colors.white.withOpacity(0.06) : Colors.transparent,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: active ? Colors.white : Colors.white70, size: active ? 26 : 22),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: active ? Colors.white : Colors.white70,
                        fontSize: active ? 12 : 11,
                        fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                      ),
                      child: Text(label),
                    ),
                  ],
                ),
              ),
            );
          },
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
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    final bool pressed = _isCardPressed[index] ?? false;
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => _onCardTapDown(index),
      onTapUp: (_) => _onCardTapUp(index),
      onTapCancel: () => _onCardTapUp(index),
      child: AnimatedScale(
        scale: pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(colors: [Color(0xFF203a43), Color(0xFF2c5364)]),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(image),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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