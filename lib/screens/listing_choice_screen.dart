// listing_choice_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tool_rental_app/screens/Listing/list_tool_screen.dart';
import 'package:tool_rental_app/screens/ListPackage/list_package_category_screen.dart';

class ListingChoiceScreen extends StatelessWidget {
  const ListingChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "List an Item",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF203a43),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
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
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChoiceCard(
                      context,
                      icon: Icons.handyman,
                      label: "List a Single Tool",
                      description: "Post individual tools for rent quickly",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ListToolScreen(),
                          ),
                        );
                      },
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildChoiceCard(
                      context,
                      icon: Icons.local_mall,
                      label: "List a Package",
                      description: "Bundle tools into attractive packages",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ListPackageCategoryScreen(),
                          ),
                        );
                      },
                      gradient: const LinearGradient(
                        colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildChoiceCard(
                      context,
                      icon: Icons.directions_car_filled,
                      label: "List a Vehicle",
                      description: "Offer cars, bikes, or other vehicles for rent",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ListVehicleScreen(),
                          ),
                        );
                      },
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD31027), Color(0xFFEA384D)], // Red → Dark Red
                      ),
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

  Widget _buildChoiceCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String description,
        required VoidCallback onTap,
        required LinearGradient gradient,
      }) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            offset: Offset(0.8, 0.8),
                            blurRadius: 2,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            offset: Offset(0.5, 0.5),
                            blurRadius: 1,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder for the new ListVehicleScreen
class ListVehicleScreen extends StatelessWidget {
  const ListVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List a Vehicle")),
      body: const Center(child: Text("This is the vehicle listing screen.")),
    );
  }
}