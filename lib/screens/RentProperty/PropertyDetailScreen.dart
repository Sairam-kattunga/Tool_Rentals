// file: lib/screens/RentProperty/property_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tool_rental_app/widgets/star_rating.dart'; // Add this import

class PropertyDetailScreen extends StatelessWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  // Helper function to build a reusable info row
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
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 16),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                  if (isCopyable && context != null)
                    IconButton(
                      icon: const Icon(
                          Icons.copy, color: Colors.white70, size: 16),
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

  // Helper function to build a detail section
  Widget _buildDetailSection(String label, dynamic value) {
    String formattedValue;
    if (value is List) {
      formattedValue = value.isEmpty ? "N/A" : value.join(', ');
    } else {
      formattedValue = value?.toString() ?? "N/A";
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to get an icon based on category name
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Apartment':
        return Icons.apartment;
      case 'House':
        return Icons.house;
      case 'Office':
        return Icons.business;
      case 'Shop/Retail':
        return Icons.store;
      case 'Warehouse':
        return Icons.warehouse;
      case 'Land':
        return Icons.landscape;
      default:
        return Icons.category;
    }
  }

  // Function to show the rent confirmation dialog
  Future<void> _showRentConfirmationDialog(BuildContext context,
      Map<String, dynamic> propertyData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to rent a property.")),
      );
      return;
    }

    final ownerId = propertyData['ownerId'] as String?;
    if (ownerId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot rent your own property.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            backgroundColor: const Color(0xFF203a43),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Confirm Rental",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Text(
              "You are about to rent '${propertyData["title"]}'. A request will be sent to the owner for approval.",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                    "Cancel", style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sending rental request...',
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  try {
                    final renterDoc = await FirebaseFirestore.instance
                        .collection("users").doc(user.uid).get();
                    final renterName = renterDoc.data()?['name'] ?? 'Anonymous';

                    await FirebaseFirestore.instance.collection(
                        "rentalRequests").add({
                      'propertyId': propertyId,
                      'propertyName': propertyData['title'],
                      'renterId': user.uid,
                      'renterName': renterName,
                      'ownerId': propertyData['ownerId'],
                      'rent': propertyData['rent'],
                      'requestDate': FieldValue.serverTimestamp(),
                      'status': 'pending',
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rental request sent to owner!',
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to send request: $e',
                              style: const TextStyle(color: Colors.white)),
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

  // Widget to build the reviews list
  Widget _buildReviewsList(String propertyId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('propertyReviews')
          .where('propertyId', isEqualTo: propertyId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text("No reviews yet. Be the first!",
                  style: TextStyle(color: Colors.white70)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                            style: const TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      StarRating(rating: (reviewData['rating'] as num?)
                          ?.toDouble() ?? 0.0),
                      const SizedBox(height: 8),
                      Text(
                        reviewData['review'] ?? 'No review text.',
                        style: const TextStyle(color: Colors.white70,
                            fontSize: 14),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Property Details", style: TextStyle(color: Colors.white)),
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
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('properties').doc(
              propertyId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.greenAccent));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Property not found.',
                  style: TextStyle(color: Colors.white54, fontSize: 18)));
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final String category = data['category'] ?? "N/A";
            final IconData categoryIcon = _getIconForCategory(category);
            final bool isAvailable = data['isAvailable'] ?? false;
            final double rent = (data['rent'] as num?)?.toDouble() ?? 0.0;
            final double deposit = (data['deposit'] as num?)?.toDouble() ?? 0.0;
            final double averageRating = (data['averageRating'] as num?)
                ?.toDouble() ?? 0.0;
            final int ratingCount = (data['ratingCount'] as int?) ?? 0;
            final Map<String, dynamic>? addressData = data['address'];
            final String address = addressData != null
                ? '${addressData['street']}, ${addressData['city']}, ${addressData['state']} - ${addressData['postalCode']}'
                : 'N/A';
            final String locationLink = addressData?['location'] ?? '';

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 220,
                              width: double.infinity,
                              color: Colors.grey.withOpacity(0.3),
                              child: Center(
                                child: Icon(categoryIcon, size: 100,
                                    color: Colors.white70),
                              ),
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
                                    data["title"] ?? "Property",
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
                                      color: isAvailable
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
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
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(
                                    "₹${rent.toStringAsFixed(2)} / month",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      StarRating(rating: averageRating),
                                      const SizedBox(width: 8),
                                      Text(
                                        "(${ratingCount} reviews)",
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildInfoRow(
                                icon: Icons.vpn_key_outlined,
                                label: "Property ID",
                                value: propertyId,
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
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 16),
                              ),
                              if (locationLink.isNotEmpty)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final Uri uri = Uri.parse(locationLink);
                                      try {
                                        if (!await launchUrl(uri,
                                            mode: LaunchMode
                                                .externalApplication)) {
                                          if (context.mounted) {
                                            ScaffoldMessenger
                                                .of(context)
                                                .showSnackBar(
                                              const SnackBar(content: Text(
                                                  'Could not open map.')),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger
                                              .of(context)
                                              .showSnackBar(
                                            const SnackBar(content: Text(
                                                'An error occurred.')),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(
                                        Icons.location_on, color: Colors.white),
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
                              const Divider(color: Colors.white24),
                              const SizedBox(height: 20),
                              _buildInfoRow(
                                icon: Icons.category,
                                label: "Category",
                                value: category,
                              ),
                              _buildInfoRow(
                                icon: Icons.payments,
                                label: "Security Deposit",
                                value: '₹${deposit.toStringAsFixed(2)}',
                              ),
                              if (data['bedrooms'] != null)
                                _buildInfoRow(
                                  icon: Icons.king_bed,
                                  label: "Bedrooms",
                                  value: data['bedrooms'].toString(),
                                ),
                              if (data['bathrooms'] != null)
                                _buildInfoRow(
                                  icon: Icons.shower,
                                  label: "Bathrooms",
                                  value: data['bathrooms'].toString(),
                                ),
                              if (data['area'] != null)
                                _buildInfoRow(
                                  icon: Icons.square_foot,
                                  label: "Area",
                                  value: '${data['area']} sq. ft.',
                                ),
                              _buildDetailSection(
                                  "Amenities", data['amenities']),
                              _buildDetailSection(
                                  "Description", data['description']),
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
                              _buildReviewsList(propertyId),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white.withOpacity(0.1),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isAvailable ? () =>
                              _showRentConfirmationDialog(context, data) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable
                                ? Colors.greenAccent
                                : Colors.grey,
                            foregroundColor: isAvailable ? Colors.black : Colors
                                .white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            isAvailable ? "Request to Rent" : "Not Available",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}