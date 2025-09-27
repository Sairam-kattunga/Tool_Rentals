// file: lib/screens/RentExperience/rent_experience_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tool_rental_app/screens/Experiences/experience_detail_screen.dart'; // Corrected import path
import 'package:tool_rental_app/screens/Experiences/list_experience_category_screen.dart'; // Corrected import path

class RentExperienceScreen extends StatefulWidget {
  const RentExperienceScreen({super.key});

  @override
  State<RentExperienceScreen> createState() => _RentExperienceScreenState();
}

class _RentExperienceScreenState extends State<RentExperienceScreen> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  String _sortOption = "Price: Low to High";

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Rent an Experience", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF203a43),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
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
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search experiences...",
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
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildSortButton(),
                      ],
                    ),
                  ),
                  _buildCategoryFilter(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("experienceServices").snapshots(),
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
                              "No experiences available.",
                              style: TextStyle(color: Colors.white70, fontSize: 18),
                            ),
                          );
                        }

                        var experiences = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final category = (data["category"] ?? "").toString().toLowerCase();
                          final title = (data["title"] ?? "").toString().toLowerCase();

                          final categoryMatch = _selectedCategory == "All" || category == _selectedCategory.toLowerCase();
                          final searchMatch = _searchQuery.isEmpty || title.contains(_searchQuery.toLowerCase()) || category.contains(_searchQuery.toLowerCase());

                          return categoryMatch && searchMatch && (data['availability']?['available'] ?? false);
                        }).toList();

                        experiences.sort((a, b) {
                          final dataA = a.data() as Map<String, dynamic>;
                          final dataB = b.data() as Map<String, dynamic>;
                          final priceA = dataA["price"] ?? 0.0;
                          final priceB = dataB["price"] ?? 0.0;
                          final ratingA = dataA["ratings"] is List && (dataA["ratings"] as List).isNotEmpty ? (dataA["ratings"] as List<dynamic>).map<double>((e) => (e['rating'] as num).toDouble()).reduce((a, b) => a + b) / (dataA["ratings"] as List).length : 0.0;
                          final ratingB = dataB["ratings"] is List && (dataB["ratings"] as List).isNotEmpty ? (dataB["ratings"] as List<dynamic>).map<double>((e) => (e['rating'] as num).toDouble()).reduce((a, b) => a + b) / (dataB["ratings"] as List).length : 0.0;

                          switch (_sortOption) {
                            case "Price: Low to High":
                              return (priceA as num).compareTo(priceB as num);
                            case "Price: High to Low":
                              return (priceB as num).compareTo(priceA as num);
                            case "Top Rated":
                              return ratingB.compareTo(ratingA);
                            default:
                              return 0;
                          }
                        });

                        if (experiences.isEmpty) {
                          return const Center(
                            child: Text("No experiences match your filters.", style: TextStyle(color: Colors.white70, fontSize: 18)),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: experiences.length,
                          itemBuilder: (context, index) {
                            final expDoc = experiences[index];
                            final docId = expDoc.id;
                            return _buildExperienceGridItem(context, docId);
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
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: () async {
          final selected = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ListExperienceCategoryScreen(),
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

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        setState(() {
          _sortOption = result;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Price: Low to High',
          child: Text('Price: Low to High'),
        ),
        const PopupMenuItem<String>(
          value: 'Price: High to Low',
          child: Text('Price: High to Low'),
        ),
        const PopupMenuItem<String>(
          value: 'Top Rated',
          child: Text('Top Rated'),
        ),
      ],
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

  Widget _buildExperienceGridItem(BuildContext context, String docId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("experienceServices").doc(docId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final expData = snapshot.data!.data() as Map<String, dynamic>;
        final String title = expData["title"] ?? "Experience";
        final String category = expData["category"] ?? "N/A";
        final double price = (expData["price"] ?? 0.0).toDouble();
        final bool isAvailable = expData["availability"]?['available'] ?? false;
        final List<dynamic> ratings = expData['ratings'] ?? [];

        double averageRating = 0.0;
        if (ratings.isNotEmpty) {
          double totalRating = ratings.map((r) => (r['rating'] as num).toDouble()).reduce((a, b) => a + b);
          averageRating = totalRating / ratings.length;
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExperienceDetailScreen(
                  experienceId: docId,
                ),
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
                // Placeholder for an image, as experiences don't have local images
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 100,
                    color: Colors.grey.withOpacity(0.3),
                    child: Center(
                      child: Icon(_getIconForCategory(category), size: 50, color: Colors.white70),
                    ),
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
                              title,
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
                              category,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            StarRating(rating: averageRating),
                            const SizedBox(height: 4),
                            Text(
                              "₹${price.toStringAsFixed(2)}",
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
                            onPressed: isAvailable ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExperienceDetailScreen(
                                    experienceId: docId,
                                  ),
                                ),
                              );
                            } : null,
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
      },
    );
  }

  // Helper function to map category names to icons
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