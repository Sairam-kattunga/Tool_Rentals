import 'package:flutter/material.dart';
import 'package:tool_rental_app/constants/app_data.dart'; // Ensure you have this file

class CategorySelectionScreen extends StatefulWidget {
  final String initialCategory;

  const CategorySelectionScreen({
    super.key,
    required this.initialCategory,
  });

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Category", style: TextStyle(color: Colors.white)),
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
          SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: AppData.categories.length + 1, // +1 for "All"
              itemBuilder: (context, index) {
                final categoriesWithAll = ["All", ...AppData.categories];
                final category = categoriesWithAll[index];
                final isSelected = category == _selectedCategory;
                return _buildCategoryGridItem(category, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGridItem(String category, bool isSelected) {
    final imagePath = AppData.categoryImages[category] ?? "lib/assets/Categories/Miscellaneous.png";

    return InkWell(
      onTap: () {
        Navigator.pop(context, category);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.white24,
            width: isSelected ? 3.0 : 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white.withOpacity(0.1),
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    category,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.greenAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: const [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black,
                          offset: Offset(0, 2),
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