import 'package:flutter/material.dart';
import 'package:tool_rental_app/screens/Listing/list_tool_screen.dart'; // Assuming this import is correct
import 'package:tool_rental_app/screens/ListPackage/list_package_category_screen.dart'; // Assuming this import is correct

// Import the next screen in the flow
import 'package:tool_rental_app/screens/ListVehicles/vehicle_details_screen.dart';

class ListVehicleCategoryScreen extends StatelessWidget {
  const ListVehicleCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Vehicle Category",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildCategoryCard(
                context,
                'Car',
                Icons.directions_car,
                Colors.deepOrange,
              ),
              const SizedBox(height: 20),
              _buildCategoryCard(
                context,
                'Motorcycle',
                Icons.motorcycle,
                Colors.blueAccent,
              ),
              const SizedBox(height: 20),
              _buildCategoryCard(
                context,
                'Truck',
                Icons.local_shipping,
                Colors.green,
              ),
              const SizedBox(height: 20),
              _buildCategoryCard(
                context,
                'Van',
                Icons.airport_shuttle,
                Colors.amber,
              ),
              const SizedBox(height: 20),
              _buildCategoryCard(
                context,
                'Bicycle',
                Icons.pedal_bike,
                Colors.purple,
              ),
              const SizedBox(height: 20),
              _buildCategoryCard(
                context,
                'Scooter',
                Icons.electric_scooter,
                Colors.cyan,
              ),
              const SizedBox(height: 20),
              _buildCategoryCard(
                context,
                'RV / Camper',
                Icons.rv_hookup,
                Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category, IconData icon, Color color) {
    return Card(
      color: Colors.white10,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Navigate to the details screen for the selected category
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailsScreen(category: category),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 20),
              Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}