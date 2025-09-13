import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleRentalScreen extends StatelessWidget {
  const VehicleRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle Rentals", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
        elevation: 0,
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("vehicles").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No vehicles available for rent.",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  );
                }

                final vehicles = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicleData = vehicles[index].data() as Map<String, dynamic>;
                    // You would build a list tile or card here
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      child: ListTile(
                        title: Text(
                          vehicleData['name'] ?? 'Vehicle',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Type: ${vehicleData['type'] ?? 'N/A'}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          "₹${(vehicleData['pricePerDay'] as num?)?.toStringAsFixed(2) ?? '0.00'}/day",
                          style: const TextStyle(color: Colors.greenAccent),
                        ),
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