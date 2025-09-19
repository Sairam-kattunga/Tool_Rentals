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
  bool _sortAscending = true;

  void _sortVehicles(List<Vehicle> vehicles) {
    vehicles.sort((a, b) {
      if (_sortAscending) {
        return a.rentPerDay.compareTo(b.rentPerDay);
      } else {
        return b.rentPerDay.compareTo(a.rentPerDay);
      }
    });
  }

  void _navigateToCategorySelection() async {
    final String? selectedCategory = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VehicleCategorySelectionScreen(),
      ),
    );
    if (selectedCategory != null) {
      setState(() {
        _selectedCategory = selectedCategory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Vehicles for Rent",
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(width: 8),
                  _buildSortIcon(),
                ],
              ),
            ),
            _buildCategoryButton(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('vehicles')
                    .where('isAvailable', isEqualTo: true)
                    .snapshots(),
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

                  return ListView.builder(
                    itemCount: filteredVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = filteredVehicles[index];
                      return _buildVehicleCard(context, vehicle);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search vehicles...',
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: _searchText.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: Colors.white70),
          onPressed: () {
            setState(() {
              _searchText = '';
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSortIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            _sortAscending = !_sortAscending;
          });
        },
        icon: Icon(
          _sortAscending ? Icons.sort : Icons.sort,
          color: Colors.white,
        ),
        tooltip: _sortAscending ? 'Sort Descending' : 'Sort Ascending',
      ),
    );
  }

  Widget _buildCategoryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: OutlinedButton.icon(
        onPressed: _navigateToCategorySelection,
        icon: const Icon(Icons.category, color: Colors.white),
        label: Text(
          'Category: $_selectedCategory',
          style: const TextStyle(color: Colors.white),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailScreen(vehicle: vehicle),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${vehicle.make} ${vehicle.model} (${vehicle.year})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                vehicle.description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailChip(Icons.currency_rupee, '${vehicle.rentPerDay.toStringAsFixed(0)} / Day'),
                  _buildDetailChip(Icons.location_on, vehicle.address),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}