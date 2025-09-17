// lib/screens/ToolPackage/list_package_category_screen.dart

import 'package:flutter/material.dart';
import 'package:tool_rental_app/screens/ListPackage/list_package_screen.dart';
import 'package:tool_rental_app/constants/app_data.dart'; // Import the new data file

class ListPackageCategoryScreen extends StatefulWidget {
  const ListPackageCategoryScreen({super.key});

  @override
  State<ListPackageCategoryScreen> createState() => _ListPackageCategoryScreenState();
}

class _ListPackageCategoryScreenState extends State<ListPackageCategoryScreen> {
  // Use data from the centralized file instead of hardcoded lists
  final List<String> categories = AppData.categories;
  final Map<String, String> _categoryImages = AppData.categoryImages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List a Package", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Center(
                child: Text(
                  "Select package category",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 6.0,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(categories[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    final imageName = _categoryImages[category];

    return Semantics(
      label: "Category: $category. Tap to select.",
      child: InkWell(
        onTap: () {
          // Navigate to the ListPackageScreen, passing the selected category
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ListPackageScreen(selectedCategory: category),
            ),
          );
        },
        child: Card(
          color: Colors.white.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageName != null)
                Image.asset(
                  imageName,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (context, error, stackTrace) {
                    // Added basic error handling for image loading
                    debugPrint('Error loading image for category $category: $error');
                    return Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
                    );
                  },
                )
              else
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(child: Icon(Icons.category, color: Colors.white, size: 50)),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    category,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
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