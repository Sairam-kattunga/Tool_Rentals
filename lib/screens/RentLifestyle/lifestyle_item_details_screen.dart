// lib/screens/LifestyleItems/lifestyle_item_details_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:tool_rental_app/screens/MyTools/edit_lifestyle_screen.dart'; // Import for edit functionality

class LifestyleItemDetailsScreen extends StatelessWidget {
  final String itemId;

  const LifestyleItemDetailsScreen({super.key, required this.itemId});

  // Reusable widget to build a row of information
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isCopyable = false,
    BuildContext? context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCopyable)
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white70, size: 16),
                        onPressed: () {
                          if (context != null) {
                            Clipboard.setData(ClipboardData(text: value));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Copied to clipboard")),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // A helper function to show a confirmation dialog for rental
  Future<void> _showRentConfirmationDialog(BuildContext context, Map<String, dynamic> itemData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to rent this item.")),
        );
      }
      return;
    }

    final ownerId = itemData['ownerId'] as String?;
    if (ownerId == user.uid) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You cannot rent your own item.")),
        );
      }
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
          "You are about to rent '${itemData["title"]}'. A request will be sent to the owner for approval.",
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
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sending rental request...', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue,
                  ),
                );
              }

              try {
                // Fetch renter's name
                final renterDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
                final renterName = renterDoc.data()?['name'] ?? 'Anonymous';

                // Send rental request to Firestore
                await FirebaseFirestore.instance.collection("rentalRequests").add({
                  'itemId': itemId,
                  'itemName': itemData['title'],
                  'renterId': user.uid,
                  'renterName': renterName,
                  'ownerId': ownerId,
                  'price': itemData['price'],
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

  // Widget to display reviews for the item
  Widget _buildReviewsList(String itemId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('itemId', isEqualTo: itemId)
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
                            reviewData['userName'] ?? 'Anonymous',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildStarRating((reviewData['rating'] as num?)?.toDouble() ?? 0.0),
                      const SizedBox(height: 8),
                      Text(
                        reviewData['comment'] ?? 'No review text.',
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

  // A helper widget to build star ratings
  Widget _buildStarRating(double rating) {
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details", style: TextStyle(color: Colors.white)),
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('lifestyleItems').doc(itemId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text("Item not found.", style: TextStyle(color: Colors.white54, fontSize: 18)),
              );
            }

            final itemData = snapshot.data!.data() as Map<String, dynamic>;
            final bool isAvailable = itemData['isAvailable'] ?? false;
            final String ownerId = itemData['ownerId'] ?? '';
            final bool isMyItem = user?.uid == ownerId;

            final String imagePath = "lib/assets/Homescreen/Luxury.png";

            // Fetch address data from the nested 'address' map
            final Map<String, dynamic>? addressData = itemData['address'];
            final String addressName = addressData?['addressName'] ?? 'N/A';
            final String street = addressData?['street'] ?? 'N/A';
            final String city = addressData?['city'] ?? 'N/A';
            final String state = addressData?['state'] ?? 'N/A';
            final String postalCode = addressData?['postalCode'] ?? 'N/A';
            final String locationLink = addressData?['location'] ?? '';

            // Read the actual average rating and review count from Firestore
            final double averageRating = (itemData['averageRating'] as num?)?.toDouble() ?? 0.0;
            final int ratingCount = (itemData['ratingCount'] as int?) ?? 0;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Item Image Section
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: Image.asset(
                            imagePath,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 250,
                                color: Colors.grey,
                                child: const Center(
                                  child: Icon(Icons.style, color: Colors.white, size: 80),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Item Title and Price
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      itemData['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _buildStarRating(averageRating),
                                      const SizedBox(width: 8),
                                      Text(
                                        "(${ratingCount} reviews)",
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "₹${itemData['price']?.toStringAsFixed(2) ?? '0.00'} / day",
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Details Section
                              const Text(
                                "Details",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(color: Colors.white24, height: 24),
                              _buildInfoRow(
                                icon: Icons.category,
                                label: 'Category',
                                value: itemData['category'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                icon: Icons.business,
                                label: 'Brand',
                                value: itemData['brand'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                icon: Icons.info_outline,
                                label: 'Condition',
                                value: itemData['condition'] ?? 'N/A',
                              ),
                              const SizedBox(height: 16),

                              // Description
                              const Text(
                                "Description",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(color: Colors.white24, height: 24),
                              Text(
                                itemData['description'] ?? 'No description provided.',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Location Section
                              const Text(
                                "Location",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(color: Colors.white24, height: 24),
                              _buildInfoRow(
                                icon: Icons.location_on,
                                label: "Address",
                                value: '$addressName, $street, $city, $state - $postalCode',
                                context: context,
                              ),
                              if (locationLink.isNotEmpty)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final Uri uri = Uri.parse(locationLink);
                                      try {
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        } else {
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 24),

                              // Reviews Section
                              _buildReviewSection(context, itemId),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Rent button in a fixed position at the bottom
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF203a43),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isAvailable
                          ? () {
                        if (isMyItem) {
                          // Display a snackbar for the owner
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('You cannot rent your own item.')),
                          );
                        } else {
                          // Show rent confirmation dialog for other users
                          _showRentConfirmationDialog(context, itemData);
                        }
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable ? Colors.greenAccent : Colors.grey,
                        foregroundColor: isAvailable ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        isAvailable ? "Rent Now" : "Not Available",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context, String itemId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customer Reviews",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(color: Colors.white24),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reviews')
              .where('itemId', isEqualTo: itemId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "No reviews yet. Be the first!",
                  style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
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
                return _buildReviewCard(reviewData);
              },
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> reviewData) {
    final Timestamp? timestamp = reviewData['createdAt'] as Timestamp?;
    final String formattedDate = timestamp != null
        ? DateFormat('MMM dd, yyyy').format(timestamp.toDate())
        : 'N/A';

    return Card(
      color: Colors.white.withOpacity(0.05),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                  reviewData['userName'] ?? 'Anonymous',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildStarRating((reviewData['rating'] as num?)?.toDouble() ?? 0.0),
            const SizedBox(height: 8),
            Text(
              reviewData['comment'] ?? 'No review text.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}