// home_screen.dart
import 'package:flutter/material.dart';
import 'package:tool_rental_app/screens/Listing/list_tool_screen.dart';
import 'package:tool_rental_app/screens/ListPackage/list_package_category_screen.dart';
import 'package:tool_rental_app/screens/ListVehicles/list_vehicle_screen.dart';
// New imports for additional paths
import 'package:tool_rental_app/screens/ListExperience/ListExperienceCategory.dart';
import 'package:tool_rental_app/screens/ListProperty/ListPropertyCategoryScreen.dart';
import 'package:tool_rental_app/screens/ListLifestyle/list_lifestyle_category_screen.dart';


// New dummy screens for navigation
class ListLifestyleScreen extends StatelessWidget {
  const ListLifestyleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List a Luxury & Lifestyle Item'),
        backgroundColor: const Color(0xFF203a43),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "This screen will allow you to list luxury and lifestyle items.",
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildChoiceCard(
                    context,
                    icon: Icons.handyman,
                    label: "Tools",
                    description: "Post individual tools for rent",
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
                  _buildChoiceCard(
                    context,
                    icon: Icons.local_mall,
                    label: "Packages",
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
                  _buildChoiceCard(
                    context,
                    icon: Icons.directions_car_filled,
                    label: "Vehicles",
                    description: "Offer cars, bikes, or other vehicles",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ListVehicleCategoryScreen(),
                        ),
                      );
                    },
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD31027), Color(0xFFEA384D)],
                    ),
                  ),
                  _buildChoiceCard(
                    context,
                    icon: Icons.kayaking,
                    label: "Experiences",
                    description: "Rent out unique experiences",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ListExperienceCategoryScreen(),
                        ),
                      );
                    },
                    gradient: const LinearGradient(
                      colors: [Color(0xff75564f), Color(0xfff47e20)],
                    ),
                  ),
                  _buildChoiceCard(
                    context,
                    icon: Icons.house_outlined,
                    label: "Property",
                    description: "Rent out Properties",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ListPropertyCategoryScreen(),
                        ),
                      );
                    },
                    gradient: const LinearGradient(
                      colors: [Color(0xffd78cd7), Color(0xffcd22da)],
                    ),
                  ),
                  _buildChoiceCard(
                    context,
                    icon: Icons.style,
                    label: "Lifestyle",
                    description: "Offer fashion, accessories, or other items",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ListLifestyleCategoryScreen(),
                        ),
                      );
                    },
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43cea2), Color(0xFF185a9d)],
                    ),
                  ),
                ],
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
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      offset: Offset(0.8, 0.8),
                      blurRadius: 2,
                      color: Colors.black45,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      offset: Offset(0.5, 0.5),
                      blurRadius: 1,
                      color: Colors.black26,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}