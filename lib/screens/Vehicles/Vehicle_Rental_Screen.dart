// file: lib/screens/VehicleRental/vehicle_rental_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tool_rental_app/constants/vehicle.dart';
import 'package:tool_rental_app/screens/Vehicles/vehicle_detail_screen.dart';
import 'package:tool_rental_app/screens/Vehicles/vehicle_category_selection_screen.dart';

class VehicleRentalScreen extends StatefulWidget {
  const VehicleRentalScreen({super.key});

  @override
  State<VehicleRentalScreen> createState() => _VehicleRentalScreenState();
}

class _VehicleRentalScreenState extends State<VehicleRentalScreen> {
  String _searchText = '';
  String _selectedCategory = 'All';
  String _sortOption = "Price: Low to High";

  /// Map each category to its corresponding local image
  final Map<String, String> _categoryImages = {
    "All": "lib/assets/Vehicles/All.png",
    "Car": "lib/assets/Vehicles/Cars.png",
    "Motorcycle": "lib/assets/Vehicles/Bikes.png",
    "Truck": "lib/assets/Vehicles/Trucks.png",
    "Van": "lib/assets/Vehicles/Vans.png",
    "Bicycle": "lib/assets/Vehicles/Bicycles.png",
    "Scooter": "lib/assets/Vehicles/Scooters.png",
    "RV / Camper": "lib/assets/Vehicles/RVs.png",
    "Other": "lib/assets/Vehicles/Others.png",
  };

  final List<String> _sortOptions = [
    "Price: Low to High",
    "Price: High to Low",
    "Availability First",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Vehicles for Rent",
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
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSearchBar(),
                      ),
                      const SizedBox(width: 10),
                      _buildSortButton(),
                    ],
                  ),
                ),
                _buildCategoryButton(),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('vehicles').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No vehicles currently available.', style: TextStyle(color: Colors.white70)));
                      }

                      List<Vehicle> allVehicles = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Vehicle.fromMap(data, id: doc.id);
                      }).toList();

                      List<Vehicle> filteredVehicles = allVehicles.where((vehicle) {
                        final matchesSearch = vehicle.make.toLowerCase().contains(_searchText.toLowerCase()) ||
                            vehicle.model.toLowerCase().contains(_searchText.toLowerCase()) ||
                            vehicle.description.toLowerCase().contains(_searchText.toLowerCase());

                        final matchesCategory = _selectedCategory == 'All' || vehicle.category == _selectedCategory;

                        return matchesSearch && matchesCategory;
                      }).toList();

                      _sortVehicles(filteredVehicles);

                      if (filteredVehicles.isEmpty) {
                        return const Center(
                            child: Text('No vehicles match your search criteria.', style: TextStyle(color: Colors.white70)));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredVehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = filteredVehicles[index];
                          return _buildVehicleGridItem(context, vehicle);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sortVehicles(List<Vehicle> vehicles) {
    vehicles.sort((a, b) {
      final availA = a.isAvailable;
      final availB = b.isAvailable;

      switch (_sortOption) {
        case "Price: Low to High":
          return a.rentPerDay.compareTo(b.rentPerDay);
        case "Price: High to Low":
          return b.rentPerDay.compareTo(a.rentPerDay);
        case "Availability First":
          if (availA && !availB) return -1;
          if (!availA && availB) return 1;
          return 0;
        default:
          return 0;
      }
    });
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
      decoration: InputDecoration(
        hintText: "Search by name, model, or description...",
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        setState(() {
          _sortOption = result;
        });
      },
      itemBuilder: (BuildContext context) => _sortOptions.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.sort, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: () async {
          final selected = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleCategorySelectionScreen(),
            ),
          );
          if (selected != null && selected is String) {
            setState(() {
              _selectedCategory = selected;
            });
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.category, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedCategory,
                  style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleGridItem(BuildContext context, Vehicle vehicle) {
    final bool isAvailable = vehicle.isAvailable;
    final String imagePath = _categoryImages[vehicle.category] ?? "lib/assets/Vehicles/Others.png";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailScreen(vehicle: vehicle),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                imagePath,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.make} ${vehicle.model}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${vehicle.rentPerDay.toStringAsFixed(2)} / day",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isAvailable
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleDetailScreen(vehicle: vehicle),
                            ),
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? Colors.greenAccent : Colors.grey,
                          foregroundColor: isAvailable ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(isAvailable ? "Rent" : "Unavailable"),
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
}