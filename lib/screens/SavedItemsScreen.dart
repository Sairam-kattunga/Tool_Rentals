// lib/screens/SavedItems/saved_items_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_rental_app/screens/RentTool/tool_detail_screen.dart';
import 'package:tool_rental_app/screens/ToolPackages/package_details_screen.dart';
import 'package:tool_rental_app/screens/MyTools/edit_lifestyle_screen.dart';


class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your saved items.", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Saved Items", style: TextStyle(color: Colors.white)),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('savedItems')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "You have no saved items.",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              );
            }

            final savedItems = snapshot.data!.docs;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0, // Adjusted aspect ratio for the new design
              ),
              itemCount: savedItems.length,
              itemBuilder: (context, index) {
                final itemData = savedItems[index].data() as Map<String, dynamic>;
                return _buildSavedItemCard(context, itemData);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSavedItemCard(BuildContext context, Map<String, dynamic> item) {
    final String itemName = item['title'] ?? 'Saved Item';
    final String itemId = item['itemId'] ?? '';
    final String itemType = item['type'] ?? 'unknown';
    final double itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;

    // Determine icon based on item type
    IconData itemIcon;
    if (itemType == 'tool') {
      itemIcon = Icons.build;
    } else if (itemType == 'package') {
      itemIcon = Icons.inventory_2_outlined;
    } else {
      itemIcon = Icons.bookmark_border; // Fallback icon
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon to represent item type
            Icon(itemIcon, size: 40, color: Colors.white),
            const SizedBox(height: 8),

            // Item details
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  itemName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${itemPrice.toStringAsFixed(2)} / day',
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
                onPressed: () {
                  // Dynamic navigation based on item type
                  if (itemType == 'tool') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ToolDetailScreen(docId: itemId),
                      ),
                    );
                  } else if (itemType == 'package') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PackageDetailsScreen(packageId: itemId),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cannot view details for this item type: $itemType')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("View"),
              ),
            ),
          ],
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