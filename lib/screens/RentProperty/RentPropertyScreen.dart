// file: lib/screens/RentProperty/rent_property_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tool_rental_app/screens/RentProperty/PropertyCategorySelectionScreen.dart';
import 'package:tool_rental_app/screens/RentProperty/PropertyDetailScreen.dart';

class RentPropertyScreen extends StatefulWidget {
  const RentPropertyScreen({super.key});

  @override
  State<RentPropertyScreen> createState() => _RentPropertyScreenState();
}

class _RentPropertyScreenState extends State<RentPropertyScreen> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  String _sortOption = "Rent: Low to High";

  final List<String> categories = [
    "All", "Apartment", "House", "Office", "Shop/Retail", "Warehouse", "Land"
  ];

  final Map<String, IconData> _categoryIcons = const {
    "Apartment": Icons.apartment,
    "House": Icons.house,
    "Office": Icons.business,
    "Shop/Retail": Icons.store,
    "Warehouse": Icons.warehouse,
    "Land": Icons.landscape,
    "All": Icons.public,
  };

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
          title: const Text("Rent a Property", style: TextStyle(color: Colors.white)),
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
                                _searchQuery = value.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search properties...",
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
                      stream: FirebaseFirestore.instance.collection("properties").snapshots(),
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
                              "No properties available.",
                              style: TextStyle(color: Colors.white70, fontSize: 18),
                            ),
                          );
                        }

                        var properties = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final category = (data["category"] ?? "").toString().toLowerCase();
                          final title = (data["title"] ?? "").toString().toLowerCase();
                          final address = (data["address"]?['street'] ?? "").toString().toLowerCase() +
                              (data["address"]?['city'] ?? "").toString().toLowerCase();

                          final categoryMatch = _selectedCategory == "All" || category == _selectedCategory.toLowerCase();
                          final searchMatch = _searchQuery.isEmpty || title.contains(_searchQuery) || category.contains(_searchQuery) || address.contains(_searchQuery);

                          return categoryMatch && searchMatch && (data['isAvailable'] ?? false);
                        }).toList();

                        properties.sort((a, b) {
                          final dataA = a.data() as Map<String, dynamic>;
                          final dataB = b.data() as Map<String, dynamic>;
                          final rentA = dataA["rent"] ?? 0.0;
                          final rentB = dataB["rent"] ?? 0.0;
                          final ratingA = dataA["averageRating"] ?? 0.0;
                          final ratingB = dataB["averageRating"] ?? 0.0;
                          final availA = dataA["isAvailable"] ?? false;
                          final availB = dataB["isAvailable"] ?? false;

                          switch (_sortOption) {
                            case "Rent: Low to High":
                              return (rentA as num).compareTo(rentB as num);
                            case "Rent: High to Low":
                              return (rentB as num).compareTo(rentA as num);
                            case "Top Rated":
                              return (ratingB as num).compareTo(ratingA as num);
                            case "Availability First":
                              return availB.toString().compareTo(availA.toString());
                            default:
                              return 0;
                          }
                        });

                        if (properties.isEmpty) {
                          return const Center(
                            child: Text("No properties match your filters.", style: TextStyle(color: Colors.white70, fontSize: 18)),
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
                          itemCount: properties.length,
                          itemBuilder: (context, index) {
                            final propertyDoc = properties[index];
                            final docId = propertyDoc.id;
                            return _buildPropertyGridItem(context, docId);
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
              builder: (context) => PropertyCategorySelectionScreen(
                categories: categories,
                initialCategory: _selectedCategory,
              ),
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
          value: 'Rent: Low to High',
          child: Text('Rent: Low to High'),
        ),
        const PopupMenuItem<String>(
          value: 'Rent: High to Low',
          child: Text('Rent: High to Low'),
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

  Widget _buildPropertyGridItem(BuildContext context, String docId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("properties").doc(docId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final propertyData = snapshot.data!.data() as Map<String, dynamic>;
        final String title = propertyData["title"] ?? "Property";
        final String category = propertyData["category"] ?? "N/A";
        final double rent = (propertyData["rent"] as num?)?.toDouble() ?? 0.0;
        final bool isAvailable = propertyData["isAvailable"] ?? false;
        final double averageRating = (propertyData["averageRating"] as num?)?.toDouble() ?? 0.0;
        final String imagePath = propertyData["imagePath"] ?? ""; // Assuming an image path exists

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetailScreen(
                  propertyId: docId,
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
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imagePath.isNotEmpty
                      ? Image.asset(
                    imagePath,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    height: 100,
                    color: Colors.grey.withOpacity(0.3),
                    child: Center(
                      child: Icon(_categoryIcons[category], size: 50, color: Colors.white70),
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
                              "₹${rent.toStringAsFixed(2)} / month",
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
                            onPressed: isAvailable
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PropertyDetailScreen(
                                    propertyId: docId,
                                  ),
                                ),
                              );
                            }
                                : null,
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