// file: lib/screens/VehicleRental/vehicle_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tool_rental_app/constants/vehicle.dart';
import 'package:intl/intl.dart';

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  /// A map to hold the image paths for each vehicle category.
  final Map<String, String> categoryImages = const {
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

  /// Builds a row with an icon, label, and value, with an optional copy button.
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isCopyable = false,
    BuildContext? context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                  if (isCopyable && context != null)
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white70, size: 16),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Copied to clipboard")),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showRentConfirmationDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to rent a vehicle.")),
      );
      return;
    }

    if (vehicle.ownerId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot rent your own vehicle.")),
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

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = vehicle.isAvailable;
    final String headerImage = categoryImages[vehicle.category] ?? "lib/assets/Vehicles/Others.png";
    final String address = vehicle.address;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${vehicle.make} ${vehicle.model}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      headerImage,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehicle.make} ${vehicle.model}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            isAvailable ? "Available" : "Not Available",
                            style: TextStyle(
                              color: isAvailable ? Colors.greenAccent : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              shadows: const [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹${vehicle.rentPerDay.toStringAsFixed(2)} / day",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (vehicle.averageRating != null)
                            Row(
                              children: [
                                StarRating(rating: vehicle.averageRating!),
                                const SizedBox(width: 8),
                                Text(
                                  "(${vehicle.ratingCount ?? 0} reviews)",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(
                        icon: Icons.vpn_key_outlined,
                        label: "Vehicle ID",
                        value: vehicle.id,
                        isCopyable: true,
                        context: context,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        address,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      if (vehicle.locationLink != null && vehicle.locationLink!.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final Uri uri = Uri.parse(vehicle.locationLink!);
                              try {
                                if (!await launchUrl(uri)) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Could not open map.')),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('An error occurred.')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.location_on, color: Colors.white),
                            label: const Text(
                              "View on Maps",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      _buildInfoRow(
                        icon: Icons.category,
                        label: "Category",
                        value: vehicle.category,
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(
                        icon: Icons.payments,
                        label: "Advance Amount",
                        value: '₹${vehicle.advanceAmount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(
                        icon: Icons.local_police,
                        label: "License Plate",
                        value: vehicle.licensePlate,
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(
                        icon: Icons.speed,
                        label: "Mileage",
                        value: '${vehicle.mileage.toString()} km',
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Description",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vehicle.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 20),
                      const Text(
                        "Reviews",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildReviewsList(vehicle.id),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white.withOpacity(0.1),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: vehicle.isAvailable ? () => _showRentConfirmationDialog(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: vehicle.isAvailable ? Colors.greenAccent : Colors.grey,
                  foregroundColor: vehicle.isAvailable ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  vehicle.isAvailable ? "Rent Now" : "Not Available",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(String vehicleId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicleReviews')
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text("No reviews yet. Be the first!", style: TextStyle(color: Colors.white70)),
            ),
          );
        }

        final reviews = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final reviewData = reviews[index].data() as Map<String, dynamic>;
            final Timestamp? timestamp = reviewData['createdAt'] as Timestamp?;
            final String formattedDate = timestamp != null
                ? DateFormat('MMM dd, yyyy').format(timestamp.toDate())
                : 'N/A';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                color: Colors.white.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            reviewData['reviewerName'] ?? 'Anonymous',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      StarRating(rating: (reviewData['rating'] as num?)?.toDouble() ?? 0.0),
                      const SizedBox(height: 8),
                      Text(
                        reviewData['review'] ?? 'No review text.',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// A simple StarRating widget for displaying star ratings
class StarRating extends StatelessWidget {
  final double rating;
  const StarRating({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) {
          int fullStars = rating.floor();
          double remainder = rating - fullStars;
          if (index < fullStars) {
            return const Icon(Icons.star, color: Colors.amber, size: 18);
          } else if (index == fullStars && remainder >= 0.5) {
            return const Icon(Icons.star_half, color: Colors.amber, size: 18);
          } else {
            return const Icon(Icons.star_border, color: Colors.amber, size: 18);
          }
        },
      ),
    );
  }
}