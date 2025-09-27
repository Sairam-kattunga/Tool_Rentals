// file: lib/screens/MyListings/my_listings_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tool_rental_app/screens/MyTools/edit_tool_screen.dart';
import 'package:tool_rental_app/screens/MyTools/edit_package_screen.dart';
import 'package:tool_rental_app/screens/MyTools/edit_vehicle_screen.dart';
import 'package:tool_rental_app/screens/MyTools/edit_experience_screen.dart';
import 'package:tool_rental_app/screens/MyTools/EditPropertyScreen.dart';
import 'package:tool_rental_app/screens/MyTools/edit_lifestyle_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = "";
  String _sortOption = "Name: A-Z";

  String _selectedCategory = 'tools';

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Tools', 'collection': 'tools', 'icon': Icons.construction},
    {'name': 'Packages', 'collection': 'packages', 'icon': Icons.inventory_2_outlined},
    {'name': 'Vehicles', 'collection': 'vehicles', 'icon': Icons.directions_car_filled},
    {'name': 'Experiences', 'collection': 'experienceServices', 'icon': Icons.diversity_3},
    {'name': 'Properties', 'collection': 'properties', 'icon': Icons.home},
    {'name': 'Lifestyles', 'collection': 'lifestyleItems', 'icon': Icons.style}, // NEW: Lifestyles category
  ];

  void _showListingOptionsDialog(BuildContext context, String docId, Map<String, dynamic> data, String type) {
    String name = "";
    switch (type) {
      case 'tool':
        name = data["name"] ?? "Tool";
        break;
      case 'package':
        name = data["title"] ?? "Package";
        break;
      case 'vehicle':
        name = data["make"] ?? "Vehicle";
        break;
      case 'experience':
        name = data["title"] ?? "Experience";
        break;
      case 'property':
        name = data["title"] ?? "Property";
        break;
      case 'lifestyle': // NEW: Case for lifestyle
        name = data["title"] ?? "Lifestyle Item";
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("$name Options", style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blueAccent),
                title: const Text("Edit Details", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  if (type == 'tool') {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditToolScreen(docId: docId, initialData: data)));
                  } else if (type == 'package') {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditPackageScreen(docId: docId, initialData: data)));
                  } else if (type == 'vehicle') {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditVehicleScreen(docId: docId, initialData: data)));
                  } else if (type == 'experience') {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditExperienceScreen(docId: docId, initialData: data)));
                  } else if (type == 'property') {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditPropertyScreen(docId: docId, initialData: data)));
                  } else if (type == 'lifestyle') { // NEW: Navigation for lifestyle
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditLifestyleScreen(docId: docId, initialData: data)));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text("Delete Listing", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _confirmAndDelete(context, docId, name, type);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  void _confirmAndDelete(BuildContext context, String docId, String name, String type) {
    String collectionName;
    switch (type) {
      case 'tool':
        collectionName = "tools";
        break;
      case 'package':
        collectionName = "packages";
        break;
      case 'vehicle':
        collectionName = "vehicles";
        break;
      case 'experience':
        collectionName = "experienceServices";
        break;
      case 'property':
        collectionName = "properties";
        break;
      case 'lifestyle': // NEW: Case for lifestyle
        collectionName = "lifestyleItems";
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Confirm Deletion", style: TextStyle(color: Colors.white)),
          content: Text("Are you sure you want to delete '$name'?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection(collectionName).doc(docId).delete();
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("'$name' deleted successfully.")),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error deleting '$name': $e")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _handleBackNavigation() async {
    Navigator.pushReplacementNamed(context, '/home');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your listings.", style: TextStyle(color: Colors.white))),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Listings", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF203a43),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _handleBackNavigation(),
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
                  _buildSearchAndSortBar(),
                  _buildCategorySelector(),
                  Expanded(
                    child: _buildListingsList(user, _selectedCategory),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['collection'];
          return _buildCategoryChip(
            label: category['name']!,
            icon: category['icon'] as IconData,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedCategory = category['collection']!;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: isSelected
              ? const LinearGradient(
            colors: [Colors.lightGreenAccent, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [Color(0xFF2c5364), Color(0xFF203a43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF0f2027) : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0f2027) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsList(User user, String collectionName) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(collectionName)
                .where(
              collectionName == 'packages' ? "userId" : "ownerId",
              isEqualTo: user.uid,
            )
                .snapshots(),
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
                return Center(
                  child: Text(
                    "You have no $collectionName listed.",
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                );
              }

              var listings = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                String name = "";
                String category = "";
                if (collectionName == 'tools') {
                  name = (data["name"] ?? "").toString();
                  category = (data["category"] ?? "").toString();
                } else if (collectionName == 'packages') {
                  name = (data["title"] ?? "").toString();
                  category = (data["category"] ?? "").toString();
                } else if (collectionName == 'vehicles') {
                  name = (data["make"] ?? "").toString();
                  category = (data["category"] ?? "").toString();
                } else if (collectionName == 'experienceServices') {
                  name = (data["title"] ?? "").toString();
                  category = (data["category"] ?? "").toString();
                } else if (collectionName == 'properties') {
                  name = (data["title"] ?? "").toString();
                  category = (data["category"] ?? "").toString();
                } else if (collectionName == 'lifestyleItems') { // NEW: Lifestyle filtering
                  name = (data["title"] ?? "").toString();
                  category = (data["category"] ?? "").toString();
                }
                final searchMatch = name.toLowerCase().contains(_searchQuery) || category.toLowerCase().contains(_searchQuery);
                return searchMatch;
              }).toList();

              listings.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                String nameA = "", nameB = "";
                double priceA = 0.0, priceB = 0.0;
                bool availA = false, availB = false;

                if (collectionName == 'tools') {
                  nameA = dataA["name"] ?? "";
                  nameB = dataB["name"] ?? "";
                  priceA = (dataA["pricePerDay"] ?? 0.0).toDouble();
                  priceB = (dataB["pricePerDay"] ?? 0.0).toDouble();
                  availA = dataA["available"] ?? false;
                  availB = dataB["available"] ?? false;
                } else if (collectionName == 'packages') {
                  nameA = dataA["title"] ?? "";
                  nameB = dataB["title"] ?? "";
                  priceA = (dataA["dailyRate"] ?? 0.0).toDouble();
                  priceB = (dataB["dailyRate"] ?? 0.0).toDouble();
                  availA = dataA["isAvailable"] ?? false;
                  availB = dataB["isAvailable"] ?? false;
                } else if (collectionName == 'vehicles') {
                  nameA = dataA["make"] ?? "";
                  nameB = dataB["make"] ?? "";
                  priceA = (dataA["rentPerDay"] ?? 0.0).toDouble();
                  priceB = (dataB["rentPerDay"] ?? 0.0).toDouble();
                  availA = dataA["isAvailable"] ?? false;
                  availB = dataB["isAvailable"] ?? false;
                } else if (collectionName == 'experienceServices') {
                  nameA = dataA["title"] ?? "";
                  nameB = dataB["title"] ?? "";
                  priceA = (dataA["price"] ?? 0.0).toDouble();
                  priceB = (dataB["price"] ?? 0.0).toDouble();
                  availA = dataA["availability"]?['available'] ?? false;
                  availB = dataB["availability"]?['available'] ?? false;
                } else if (collectionName == 'properties') {
                  nameA = dataA["title"] ?? "";
                  nameB = dataB["title"] ?? "";
                  priceA = (dataA["rent"] ?? 0.0).toDouble();
                  priceB = (dataB["rent"] ?? 0.0).toDouble();
                  availA = dataA["isAvailable"] ?? false;
                  availB = dataB["isAvailable"] ?? false;
                } else if (collectionName == 'lifestyleItems') { // NEW: Lifestyle sorting
                  nameA = dataA["title"] ?? "";
                  nameB = dataB["title"] ?? "";
                  priceA = (dataA["price"] ?? 0.0).toDouble();
                  priceB = (dataB["price"] ?? 0.0).toDouble();
                  availA = dataA["isAvailable"] ?? false;
                  availB = dataB["isAvailable"] ?? false;
                }

                switch (_sortOption) {
                  case "Name: A-Z":
                    return nameA.compareTo(nameB);
                  case "Name: Z-A":
                    return nameB.compareTo(nameA);
                  case "Price: Low to High":
                    return priceA.compareTo(priceB);
                  case "Price: High to Low":
                    return priceB.compareTo(priceA);
                  case "Availability First":
                    return availB.toString().compareTo(availA.toString());
                  default:
                    return 0;
                }
              });

              if (listings.isEmpty) {
                return Center(
                  child: Text("No $collectionName match your filters.", style: const TextStyle(color: Colors.white70, fontSize: 18)),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final doc = listings[index];
                    final data = doc.data() as Map<String, dynamic>;
                    if (collectionName == 'tools') {
                      return _buildToolCard(context, data, doc.id);
                    } else if (collectionName == 'packages') {
                      return _buildPackageCard(context, data, doc.id);
                    } else if (collectionName == 'vehicles') {
                      return _buildVehicleCard(context, data, doc.id);
                    } else if (collectionName == 'experienceServices') {
                      return _buildExperienceCard(context, data, doc.id);
                    } else if (collectionName == 'properties') {
                      return _buildPropertyCard(context, data, doc.id);
                    } else { // NEW: Build lifestyle card
                      return _buildLifestyleCard(context, data, doc.id);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndSortBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search your listings...",
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
        const PopupMenuItem<String>(value: 'Name: A-Z', child: Text('Name: A-Z')),
        const PopupMenuItem<String>(value: 'Name: Z-A', child: Text('Name: Z-A')),
        const PopupMenuItem<String>(value: 'Price: Low to High', child: Text('Price: Low to High')),
        const PopupMenuItem<String>(value: 'Price: High to Low', child: Text('Price: High to Low')),
        const PopupMenuItem<String>(value: 'Availability First', child: Text('Availability First')),
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

  Widget _buildToolCard(BuildContext context, Map<String, dynamic> data, String docId) {
    final bool isAvailable = data["available"] ?? false;

    return InkWell(
      onTap: () => _showListingOptionsDialog(context, docId, data, 'tool'),
      child: Card(
        color: Colors.white.withOpacity(0.1),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["name"] ?? "Tool",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Category: ${data["category"] ?? "N/A"}", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(data["description"] ?? "", style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${data["pricePerDay"]?.toStringAsFixed(2) ?? '0.00'} / day",
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (bool newValue) {
                      FirebaseFirestore.instance.collection("tools").doc(docId).update({"available": newValue});
                    },
                    activeColor: Colors.lightGreenAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, Map<String, dynamic> data, String docId) {
    final bool isAvailable = data["isAvailable"] ?? false;

    return InkWell(
      onTap: () => _showListingOptionsDialog(context, docId, data, 'package'),
      child: Card(
        color: Colors.white.withOpacity(0.1),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["title"] ?? "Package",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Category: ${data["category"] ?? "N/A"}", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              if (data["tools"] != null && (data["tools"] as List).isNotEmpty)
                Text("Tools: ${(data["tools"] as List).join(', ')}", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${data["dailyRate"]?.toStringAsFixed(2) ?? '0.00'} / day",
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (bool newValue) {
                      FirebaseFirestore.instance.collection("packages").doc(docId).update({"isAvailable": newValue});
                    },
                    activeColor: Colors.lightGreenAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Map<String, dynamic> data, String docId) {
    final bool isAvailable = data["isAvailable"] ?? false;
    final String make = data["make"] ?? "Vehicle";
    final String model = data["model"] ?? "";
    final double rentPerDay = (data["rentPerDay"] ?? 0.0).toDouble();

    return InkWell(
      onTap: () => _showListingOptionsDialog(context, docId, data, 'vehicle'),
      child: Card(
        color: Colors.white.withOpacity(0.1),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$make $model',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Category: ${data["category"] ?? "N/A"}", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text("License Plate: ${data["licensePlate"] ?? "N/A"}", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${rentPerDay.toStringAsFixed(2)} / day",
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (bool newValue) {
                      FirebaseFirestore.instance.collection("vehicles").doc(docId).update({"isAvailable": newValue});
                    },
                    activeColor: Colors.lightGreenAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context, Map<String, dynamic> data, String docId) {
    final bool isAvailable = data["availability"]?['available'] ?? false;
    final String title = data["title"] ?? "Experience";
    final String category = data["category"] ?? "N/A";
    final double price = (data["price"] ?? 0.0).toDouble();
    final String serviceType = data["serviceType"] ?? "N/A";
    final String experienceLevel = data["experienceLevel"] ?? "N/A";

    return InkWell(
      onTap: () => _showListingOptionsDialog(context, docId, data, 'experience'),
      child: Card(
        color: Colors.white.withOpacity(0.1),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Category: $category", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text("Level: $experienceLevel", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text("Type: $serviceType", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${price.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (bool newValue) {
                      FirebaseFirestore.instance.collection("experienceServices").doc(docId).update({"availability.available": newValue});
                    },
                    activeColor: Colors.lightGreenAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, Map<String, dynamic> data, String docId) {
    final bool isAvailable = data["isAvailable"] ?? false;
    final String title = data["title"] ?? "Property";
    final String category = data["category"] ?? "N/A";
    final double rent = (data["rent"] ?? 0.0).toDouble();
    final int bedrooms = data["bedrooms"] ?? 0;
    final int bathrooms = data["bathrooms"] ?? 0;

    return InkWell(
      onTap: () => _showListingOptionsDialog(context, docId, data, 'property'),
      child: Card(
        color: Colors.white.withOpacity(0.1),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Category: $category", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text("Bedrooms: $bedrooms • Bathrooms: $bathrooms", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${rent.toStringAsFixed(2)} / month",
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (bool newValue) {
                      FirebaseFirestore.instance.collection("properties").doc(docId).update({"isAvailable": newValue});
                    },
                    activeColor: Colors.lightGreenAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLifestyleCard(BuildContext context, Map<String, dynamic> data, String docId) {
    final bool isAvailable = data["isAvailable"] ?? false;
    final String title = data["title"] ?? "Lifestyle Item";
    final String category = data["category"] ?? "N/A";
    final double price = (data["price"] ?? 0.0).toDouble();
    final String condition = data["condition"] ?? "N/A";

    return InkWell(
      onTap: () => _showListingOptionsDialog(context, docId, data, 'lifestyle'),
      child: Card(
        color: Colors.white.withOpacity(0.1),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Category: $category", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text("Condition: $condition", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${price.toStringAsFixed(2)} / day",
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (bool newValue) {
                      FirebaseFirestore.instance.collection("lifestyleItems").doc(docId).update({"isAvailable": newValue});
                    },
                    activeColor: Colors.lightGreenAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}