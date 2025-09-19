import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ToolDetailScreen extends StatelessWidget {
  final Map<String, dynamic> toolData;
  final String docId;
  final Map<String, String> categoryImages;

  const ToolDetailScreen({
    super.key,
    required this.toolData,
    required this.docId,
    required this.categoryImages,
  });

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
                        Clipboard.setData(ClipboardData(text: value));
                        ScaffoldMessenger.of(context!).showSnackBar(
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
        const SnackBar(content: Text("Please log in to rent a tool.")),
      );
      return;
    }

    final ownerId = toolData['ownerId'] as String?;
    if (ownerId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot rent your own tool.")),
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
          "You are about to rent '${toolData["name"]}'. A request will be sent to the owner for approval.",
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
                  'toolId': docId,
                  'toolName': toolData['name'],
                  'renterId': user.uid,
                  'renterName': renterName,
                  'ownerId': toolData['ownerId'],
                  'pricePerDay': toolData['pricePerDay'],
                  'requestDate': FieldValue.serverTimestamp(),
                  'status': 'pending',
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rental request sent to owner!', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to send request: $e', style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                  ),
                );
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
    final bool isAvailable = toolData["available"] ?? false;
    final String locationLink = toolData["location"] ?? "N/A";
    final String category = toolData["category"] ?? "Miscellaneous";
    final String headerImage = categoryImages[category] ?? "lib/assets/Categories/Miscellaneous.png";

    final String addressName = toolData["addressName"] ?? "N/A";
    final String street = toolData["street"] ?? "N/A";
    final String city = toolData["city"] ?? "N/A";
    final String state = toolData["state"] ?? "N/A";
    final String postalCode = toolData["postalCode"] ?? "N/A";

    final double averageRating = (toolData['averageRating'] as num?)?.toDouble() ?? 0.0;
    final int ratingCount = toolData['ratingCount'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          toolData["name"] ?? "Tool Details",
          style: const TextStyle(color: Colors.white),
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
                            toolData["name"] ?? "Tool",
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
                            "₹${toolData["pricePerDay"]?.toStringAsFixed(2) ?? '0.00'} / day",
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
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildInfoRow(
                        icon: Icons.vpn_key_outlined,
                        label: "Tool ID",
                        value: docId,
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
                      if (locationLink != "N/A" && locationLink.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final Uri uri = Uri.parse(locationLink);
                              try {
                                if (!await launchUrl(uri)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Could not open map.')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('An error occurred.')),
                                );
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
                        toolData["description"] ?? "No description available for this tool.",
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
                      _buildReviewsList(docId),
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
                onPressed: isAvailable
                    ? () => _showRentConfirmationDialog(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAvailable ? Colors.greenAccent : Colors.grey,
                  foregroundColor: isAvailable ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  isAvailable ? "Rent Now" : "Not Available",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(String toolId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('toolReviews')
          .where('toolId', isEqualTo: toolId)
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