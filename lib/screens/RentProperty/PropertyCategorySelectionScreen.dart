// file: lib/screens/RentProperty/property_category_selection_screen.dart

import 'package:flutter/material.dart';

class PropertyCategorySelectionScreen extends StatelessWidget {
  final List<String> categories;
  final String initialCategory;

  const PropertyCategorySelectionScreen({
    super.key,
    required this.categories,
    required this.initialCategory,
  });

  final Map<String, IconData> _categoryIcons = const {
    "Apartment": Icons.apartment,
    "House": Icons.house,
    "Office": Icons.business,
    "Shop/Retail": Icons.store,
    "Warehouse": Icons.warehouse,
    "Land": Icons.landscape,
    "All": Icons.public,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Category", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
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
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category == initialCategory;
            return InkWell(
              onTap: () {
                Navigator.of(context).pop(category);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? Colors.greenAccent : Colors.white24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _categoryIcons[category],
                      size: 80,
                      color: isSelected ? Colors.greenAccent : Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.greenAccent : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
}