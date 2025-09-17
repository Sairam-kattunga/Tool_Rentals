import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tool_rental_app/screens/ToolPackages/package_details_screen.dart';
import 'package:tool_rental_app/constants/app_data.dart';
import 'package:tool_rental_app/screens/ToolPackages/category_selection_screen.dart';

class ToolPackagesScreen extends StatefulWidget {
  const ToolPackagesScreen({super.key});

  @override
  State<ToolPackagesScreen> createState() => _ToolPackagesScreenState();
}

class _ToolPackagesScreenState extends State<ToolPackagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All";
  String _searchQuery = "";
  String _sortOption = "Price: Low to High";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tool Packages", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(width: 10),
                  _buildSortButton(),
                ],
              ),
            ),
            _buildCategoryFilter(),
            const SizedBox(height: 10),
            Expanded(
              child: _buildPackageList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search by title, category, or ID...",
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
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

  Widget _buildCategoryFilter() {
    final List<String> categories = ["All", ...AppData.categories];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: () async {
          final selected = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategorySelectionScreen(
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

  Widget _buildPackageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('packages').snapshots(),
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
              "No packages available.",
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
          );
        }

        final allDocs = snapshot.data!.docs;

        final filteredAndSortedDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          final category = data['category']?.toString().toLowerCase() ?? '';
          final docId = doc.id.toLowerCase();

          final categoryMatch = _selectedCategory == "All" || category == _selectedCategory.toLowerCase();
          final searchMatch = _searchQuery.isEmpty ||
              title.contains(_searchQuery.toLowerCase()) ||
              category.contains(_searchQuery.toLowerCase()) ||
              docId.contains(_searchQuery.toLowerCase());

          return categoryMatch && searchMatch;
        }).toList();

        filteredAndSortedDocs.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final priceA = dataA["dailyRate"] ?? 0.0;
          final priceB = dataB["dailyRate"] ?? 0.0;

          if (_sortOption == "Price: Low to High") {
            return priceA.compareTo(priceB);
          } else {
            return priceB.compareTo(priceA);
          }
        });

        if (filteredAndSortedDocs.isEmpty) {
          return const Center(
            child: Text(
              "No packages match your filters.",
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
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
          itemCount: filteredAndSortedDocs.length,
          itemBuilder: (context, index) {
            final packageDoc = filteredAndSortedDocs[index];
            final packageData = packageDoc.data() as Map<String, dynamic>;
            final packageId = packageDoc.id;

            // Use the actual isAvailable field from Firestore
            final bool isAvailable = packageData['isAvailable'] ?? false;

            return _buildPackageGridItem(context, packageData, packageId, isAvailable);
          },
        );
      },
    );
  }

  Widget _buildPackageGridItem(BuildContext context, Map<String, dynamic> packageData, String packageId, bool isAvailable) {
    final String category = packageData["category"] ?? "Miscellaneous";
    final String imagePath = AppData.categoryImages[category] ?? "lib/assets/Categories/Miscellaneous.png";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageDetailsScreen(packageId: packageId),
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
              child: Image.asset(
                imagePath,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white),
                    ),
                  );
                },
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
                          packageData["title"] ?? "No Title",
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
                          "₹${packageData["dailyRate"]?.toStringAsFixed(2) ?? '0.00'} / day",
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
                              builder: (context) => PackageDetailsScreen(packageId: packageId),
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
  }
}