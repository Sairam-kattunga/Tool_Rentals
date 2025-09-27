import 'package:flutter/material.dart';
import 'package:tool_rental_app/screens/ListExperience/ListExperienceFormScreen.dart';

class ListExperienceCategoryScreen extends StatelessWidget {
  const ListExperienceCategoryScreen({super.key});

  // A hardcoded list of experience categories
  final List<Map<String, dynamic>> experienceCategories = const [
    {
      'name': 'Adventure',
      'icon': Icons.kayaking,
      'gradient': LinearGradient(
        colors: [Color(0xFFff7e5f), Color(0xFFfeb47b)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': 'Arts & Culture',
      'icon': Icons.palette,
      'gradient': LinearGradient(
        colors: [Color(0xFF5f2c7f), Color(0xFF535c68)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': 'Wellness',
      'icon': Icons.spa,
      'gradient': LinearGradient(
        colors: [Color(0xFF43cea2), Color(0xFF185a9d)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': 'Culinary',
      'icon': Icons.restaurant_menu,
      'gradient': LinearGradient(
        colors: [Color(0xFFF37335), Color(0xFFFDCD38)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': 'Learning',
      'icon': Icons.school,
      'gradient': LinearGradient(
        colors: [Color(0xFFDA4453), Color(0xFF89216B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': 'Outdoor',
      'icon': Icons.eco,
      'gradient': LinearGradient(
        colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': 'Nightlife',
      'icon': Icons.local_bar,
      'gradient': LinearGradient(
        colors: [Color(0xFF232526), Color(0xFF414345)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': 'Fitness',
      'icon': Icons.fitness_center,
      'gradient': LinearGradient(
        colors: [Color(0xFFcc2b5e), Color(0xFF753a88)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose an Experience Category",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF203a43),
        elevation: 0,
        centerTitle: true,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: experienceCategories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final category = experienceCategories[index];
                return _buildCategoryCard(
                  context,
                  name: category['name'],
                  icon: category['icon'],
                  gradient: category['gradient'],
                  onTap: () {
                    // Navigate to the form screen, passing the selected category name
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ListExperienceFormScreen(category: category['name']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, {
        required String name,
        required IconData icon,
        required LinearGradient gradient,
        required VoidCallback onTap,
      }) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      offset: Offset(0.8, 0.8),
                      blurRadius: 2,
                      color: Colors.black45,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}