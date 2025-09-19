// file: lib/screens/VehicleRental/vehicle_category_selection_screen.dart

import 'package:flutter/material.dart';

class VehicleCategorySelectionScreen extends StatelessWidget {
  const VehicleCategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      'All',
      'Car',
      'Motorcycle',
      'Truck',
      'Van',
      'Bicycle',
      'Scooter',
      'RV / Camper'
    ];

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
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              color: Colors.white.withOpacity(0.05),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  category,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                onTap: () {
                  Navigator.pop(context, category);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}