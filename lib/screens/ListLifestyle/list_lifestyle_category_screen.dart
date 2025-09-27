// lib/screens/ListLifestyle/list_lifestyle_category_screen.dart

import 'package:flutter/material.dart';
import 'list_lifestyle_details_screen.dart'; // Import the new details screen

class ListLifestyleCategoryScreen extends StatelessWidget {
  const ListLifestyleCategoryScreen({super.key});

  final List<Map<String, dynamic>> _lifestyleCategories = const [
  {'title': 'Designer Clothes', 'icon': Icons.checkroom},
  {'title': 'Jewelry', 'icon': Icons.diamond},
  {'title': 'Premium Watches', 'icon': Icons.watch},
  {'title': 'Handbags', 'icon': Icons.shopping_bag},
  {'title': 'Art & Antiques', 'icon': Icons.art_track},
  {'title': 'Exotic Cars', 'icon': Icons.car_rental},
  {'title': 'Yachts & Boats', 'icon': Icons.directions_boat},
  {'title': 'Private Jets', 'icon': Icons.airplanemode_active},
  {'title': 'Vacation Homes', 'icon': Icons.holiday_village},
  {'title': 'Fine Wines', 'icon': Icons.wine_bar},
  {'title': 'Luxury Electronics', 'icon': Icons.devices},
  {'title': 'Collectibles', 'icon': Icons.museum},
  {'title': 'Gourmet Experiences', 'icon': Icons.restaurant},
  {'title': 'Spa & Wellness', 'icon': Icons.spa},
  {'title': 'Adventure Experiences', 'icon': Icons.airlines},
  {'title': 'Designer Furniture', 'icon': Icons.chair_alt},
  {'title': 'High-End Fitness Gear', 'icon': Icons.fitness_center},
  {'title': 'Event Tickets', 'icon': Icons.confirmation_num},
  {'title': 'Luxury Pets & Accessories', 'icon': Icons.pets},
  {'title': 'Exclusive Memberships', 'icon': Icons.workspace_premium},
  ];


  final List<Color> _categoryColors = const [
    Color(0xFF8e44ad), // Purple
    Color(0xFF3498db), // Blue
    Color(0xFFe74c3c), // Red
    Color(0xFF2ecc71), // Green
    Color(0xFFf39c12), // Orange
    Color(0xFF9b59b6), // Amethyst
    Color(0xFF1abc9c), // Turquoise
    Color(0xFFd35400), // Pumpkin
    Color(0xFF2980b9), // Belize Hole
    Color(0xFFc0392b), // Pomegranate
    Color(0xFF16a085), // Greenish
    Color(0xFFe67e22), // Carrot
    Color(0xFF34495e), // Dark Blue
    Color(0xFF7f8c8d), // Gray
    Color(0xFF27ae60), // Emerald
    Color(0xFFd35400), // Orange Dark
    Color(0xFFc0392b), // Red Dark
    Color(0xFF8e44ad), // Purple Dark
    Color(0xFF2c3e50), // Midnight
    Color(0xFFf1c40f), // Yellow Gold
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose a Lifestyle Category",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF203a43),
        elevation: 0,
        centerTitle: true,
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
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: List.generate(_lifestyleCategories.length, (index) {
              final category = _lifestyleCategories[index];
              return _buildCategoryCard(
                context,
                title: category['title'],
                icon: category['icon'],
                color: _categoryColors[index % _categoryColors.length],
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ListLifestyleDetailsScreen(
                      categoryName: category['title'],
                    ),
                  ));
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      color: color.withOpacity(0.8),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}