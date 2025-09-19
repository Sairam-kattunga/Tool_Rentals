import 'package:flutter/material.dart';

class VehicleCategorySelectionScreen extends StatelessWidget {
  const VehicleCategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {'name': 'All Vehicles', 'imagePath': 'lib/assets/Vehicles/All.png'},
      {'name': 'Car', 'imagePath': 'lib/assets/Vehicles/Cars.png'},
      {'name': 'Motorcycle', 'imagePath': 'lib/assets/Vehicles/Bikes.png'},
      {'name': 'Truck', 'imagePath': 'lib/assets/Vehicles/Trucks.png'},
      {'name': 'Van', 'imagePath': 'lib/assets/Vehicles/Vans.png'},
      {'name': 'Bicycle', 'imagePath': 'lib/assets/Vehicles/Bicycles.png'},
      {'name': 'Scooter', 'imagePath': 'lib/assets/Vehicles/Scooters.png'},
      {'name': 'RV / Camper', 'imagePath': 'lib/assets/Vehicles/RVs.png'},
      {'name': 'Other', 'imagePath': 'lib/assets/Vehicles/Others.png'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select a Category",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0f2027),
        elevation: 0,
        centerTitle: false,
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
          padding: const EdgeInsets.all(24.0), // Increased padding for smaller, centered tiles
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Changed to 3 for smaller tiles
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0, // Set to 1.0 for a perfect square
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(
                context,
                category['name']!,
                category['imagePath']!,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context,
      String categoryName,
      String imagePath,
      ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, categoryName);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
// Image that fills the entire card
            ClipRRect(
              borderRadius: BorderRadius.circular(24), // Updated to match container border radius
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
// Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
// Text positioned at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0), // Adjusted padding
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Adjusted font size for smaller tiles
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}