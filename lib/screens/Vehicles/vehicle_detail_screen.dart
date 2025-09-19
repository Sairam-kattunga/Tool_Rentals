// file: lib/screens/VehicleRental/vehicle_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tool_rental_app/constants/vehicle.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  Future<void> _launchMapUrl(String address) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': address});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  Future<void> _rentVehicle(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to rent a vehicle.')),
      );
      return;
    }

    if (vehicle.ownerId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot rent your own vehicle.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF203a43),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Confirm Rental",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "You are about to rent '${vehicle.make} ${vehicle.model}'. A request will be sent to the owner for approval.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sending rental request...', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.blue,
                ),
              );

              try {
                final renterDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
                final renterName = renterDoc.data()?['name'] ?? 'Anonymous';

                await FirebaseFirestore.instance.collection("rentalRequests").add({
                  'vehicleId': vehicle.id,
                  'vehicleMake': vehicle.make,
                  'vehicleModel': vehicle.model,
                  'renterId': user.uid,
                  'renterName': renterName,
                  'ownerId': vehicle.ownerId,
                  'rentPerDay': vehicle.rentPerDay,
                  'requestDate': FieldValue.serverTimestamp(),
                  'status': 'pending',
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rental request sent to owner!', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send request: $e', style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.address,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _launchMapUrl(vehicle.address),
            icon: const Icon(Icons.map, color: Colors.white),
            label: const Text('View on Map', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2c5364),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${vehicle.make} ${vehicle.model}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(
                Icons.directions_car,
                '${vehicle.make} ${vehicle.model}',
                '${vehicle.year} • ${vehicle.category}',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Rental Details'),
              _buildDetailRow(
                Icons.currency_rupee,
                'Rent per Day',
                '₹${vehicle.rentPerDay.toStringAsFixed(0)}',
              ),
              _buildDetailRow(
                Icons.attach_money,
                'Advance Amount',
                '₹${vehicle.advanceAmount.toStringAsFixed(0)}',
              ),
              _buildDetailRow(
                Icons.check_circle_outline,
                'Availability',
                vehicle.isAvailable ? 'Available' : 'Not Available',
              ),
              _buildDetailRow(
                Icons.drive_eta,
                'License Required',
                vehicle.requiresLicense ? 'Yes' : 'No',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Vehicle Information'),
              _buildLocationRow(context),
              _buildDetailRow(Icons.speed, 'Mileage', '${vehicle.mileage} km'),
              _buildDetailRow(
                Icons.local_police,
                'License Plate',
                vehicle.licensePlate,
              ),
              _buildDetailRow(Icons.fingerprint, 'Vehicle ID', vehicle.id),
              const SizedBox(height: 16),
              _buildSectionTitle('Description'),
              _buildDescriptionCard(vehicle.description),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: vehicle.isAvailable ? () => _rentVehicle(context) : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: vehicle.isAvailable ? const Color(0xFF38ef7d) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  vehicle.isAvailable ? 'Rent this Vehicle' : 'Not Available',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}