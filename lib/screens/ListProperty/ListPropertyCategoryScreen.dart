// file: lib/screens/ListProperty/list_property_category_screen.dart

import 'package:flutter/material.dart';
import 'package:tool_rental_app/screens/ListProperty/ListPropertyFormScreen.dart';

class ListPropertyCategoryScreen extends StatelessWidget {
  const ListPropertyCategoryScreen({super.key});

  final List<Map<String, dynamic>> propertyCategories = const [
    {
      'name': 'Apartment',
      'icon': Icons.apartment,
      'gradient': LinearGradient(
        colors: [Color(0xFFff7e5f), Color(0xFFfeb47b)],
      ),
    },
    {
      'name': 'House',
      'icon': Icons.house,
      'gradient': LinearGradient(
        colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
      ),
    },
    {
      'name': 'Office',
      'icon': Icons.business,
      'gradient': LinearGradient(
        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
      ),
    },
    {
      'name': 'Shop/Retail',
      'icon': Icons.store,
      'gradient': LinearGradient(
        colors: [Color(0xFFD31027), Color(0xFFEA384D)],
      ),
    },
    {
      'name': 'Warehouse',
      'icon': Icons.warehouse,
      'gradient': LinearGradient(
        colors: [Color(0xFF43cea2), Color(0xFF185a9d)],
      ),
    },
    {
      'name': 'Land',
      'icon': Icons.landscape,
      'gradient': LinearGradient(
        colors: [Color(0xFF8e9eab), Color(0xFFeef2f3)],
      ),
    },
  ];

  Widget _buildCategoryCard(
      BuildContext context, {
        required String name,
        required IconData icon,
        required LinearGradient gradient,
        required VoidCallback onTap,
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
                name,
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose a Property Category",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF203a43),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
            child: GridView.builder(
              itemCount: propertyCategories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final category = propertyCategories[index];
                return _buildCategoryCard(
                  context,
                  name: category['name'],
                  icon: category['icon'],
                  gradient: category['gradient'],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ListPropertyFormScreen(category: category['name']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}