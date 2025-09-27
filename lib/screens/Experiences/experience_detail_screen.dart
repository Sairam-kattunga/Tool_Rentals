import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ExperienceDetailScreen extends StatelessWidget {
  final String experienceId;

  const ExperienceDetailScreen({super.key, required this.experienceId});

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
      case 'Adventure':
        return Icons.kayaking;
      case 'Arts & Culture':
        return Icons.palette;
      case 'Wellness':
        return Icons.spa;
      case 'Culinary':
        return Icons.restaurant_menu;
      case 'Learning':
        return Icons.school;
      case 'Outdoor':
        return Icons.eco;
      case 'Nightlife':
        return Icons.local_bar;
      case 'Fitness':
        return Icons.fitness_center;
      default:
        return Icons.category;
    }
  }

  // Function to show the rent confirmation dialog
  Future<void> _showRentConfirmationDialog(BuildContext context, Map<String, dynamic> experienceData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to rent an experience.")),
      );
      return;
    }

    final ownerId = experienceData['createdBy'] as String?;
    if (ownerId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot rent your own experience.")),
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
          "You are about to book '${experienceData["title"]}'. A request will be sent to the service provider for approval.",
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
                  content: Text('Sending booking request...', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.blue,
                ),
              );

              try {
                final renterDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
                final renterName = renterDoc.data()?['name'] ?? 'Anonymous';

                await FirebaseFirestore.instance.collection("rentalRequests").add({
                  'experienceId': experienceId,
                  'experienceName': experienceData['title'],
                  'renterId': user.uid,
                  'renterName': renterName,
                  'ownerId': experienceData['createdBy'],
                  'price': experienceData['price'],
                  'requestDate': FieldValue.serverTimestamp(),
                  'status': 'pending',
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking request sent to service provider!', style: TextStyle(color: Colors.white)),
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

  // Widget to build the reviews list
  Widget _buildReviewsList(String experienceId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('experienceReviews')
          .where('experienceId', isEqualTo: experienceId)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Experience Details", style: TextStyle(color: Colors.white)),
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
          future: FirebaseFirestore.instance.collection('experienceServices').doc(experienceId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Experience not found.', style: TextStyle(color: Colors.white54, fontSize: 18)));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final String category = data['category'] ?? "Miscellaneous";
            final IconData categoryIcon = _getIconForCategory(category);
            final bool isAvailable = data['availability']?['available'] ?? false;
            final double price = (data['price'] as num?)?.toDouble() ?? 0.0;
            final Map<String, dynamic>? addressData = data['address'];
            final String addressName = addressData?['addressName'] ?? 'N/A';
            final String street = addressData?['street'] ?? 'N/A';
            final String city = addressData?['city'] ?? 'N/A';
            final String state = addressData?['state'] ?? 'N/A';
            final String postalCode = addressData?['postalCode'] ?? 'N/A';
            final String locationLink = addressData?['location'] ?? '';

            // Calculate average rating
            final List<dynamic> ratings = data['ratings'] ?? [];
            double averageRating = 0.0;
            if (ratings.isNotEmpty) {
              double totalRating = ratings.map((r) => (r['rating'] as num).toDouble()).reduce((a, b) => a + b);
              averageRating = totalRating / ratings.length;
            }

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
                                child: Icon(categoryIcon, size: 100, color: Colors.white70),
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
                                    data["title"] ?? "Experience",
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
                                    "₹${price.toStringAsFixed(2)}",
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
                                        "(${ratings.length} reviews)",
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              _buildInfoRow(
                                icon: Icons.vpn_key_outlined,
                                label: "Experience ID",
                                value: experienceId,
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
                                '$addressName, $street, $city, $state - $postalCode',
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                              if (locationLink.isNotEmpty)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final Uri uri = Uri.parse(locationLink);
                                      try {
                                        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
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
                                value: category,
                              ),

                              _buildDetailSection("Description", data['description']),
                              _buildDetailSection("Experience / Skills", data['skills']),
                              _buildDetailSection("Service Type", data['serviceType']),
                              _buildDetailSection("Experience Level", data['experienceLevel']),
                              _buildDetailSection("Languages Spoken", data['languagesSpoken']),
                              _buildDetailSection("Add-ons / Extras", data['addons']),
                              _buildDetailSection("Service Provider's Responsibility", data['isResponsible'] ? "Yes, the provider is responsible for service delivery." : "No, responsibility is not stated."),

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
                              _buildReviewsList(experienceId),
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
                          onPressed: isAvailable
                              ? () => _showRentConfirmationDialog(context, data)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable ? Colors.greenAccent : Colors.grey,
                            foregroundColor: isAvailable ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            isAvailable ? "Book Now" : "Not Available",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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