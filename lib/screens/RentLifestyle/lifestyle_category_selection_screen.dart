// lib/screens/LifestyleItems/lifestyle_category_selection_screen.dart

import 'package:flutter/material.dart';

// AppData class moved here for consolidation
class AppData {
  static const List<String> lifestyleCategories = [
    'Designer Clothes',
    'Jewelry',
    'Premium Watches',
    'Handbags',
    'Art & Antiques',
    'Exotic Cars',
    'Yachts & Boats',
    'Private Jets',
    'Vacation Homes',
    'Fine Wines',
  ];
}

class LifestyleCategorySelectionScreen extends StatelessWidget {
  final String initialCategory;

  const LifestyleCategorySelectionScreen({super.key, required this.initialCategory});

  @override
  Widget build(BuildContext context) {
    // Add "All" to the beginning of the list for unfiltered viewing
    final List<String> categories = ["All", ...AppData.lifestyleCategories];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Category", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: ListView.separated(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category == initialCategory;
            return ListTile(
              onTap: () {
                Navigator.of(context).pop(category);
              },
              title: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.greenAccent : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              leading: Icon(
                Icons.label,
                color: isSelected ? Colors.greenAccent : Colors.white70,
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                  : null,
            );
          },
          separatorBuilder: (context, index) => const Divider(
            color: Colors.white10,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
        ),
      ),
    );
  }
}