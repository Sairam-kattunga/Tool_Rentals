import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AddAddressScreen.dart'; // Ensure this screen is correctly imported

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  // Function to show the action bottom sheet
  void _showAddressActions(BuildContext context, DocumentSnapshot addressDoc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF203a43),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Address Options",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blueAccent),
                title: const Text('Edit Address',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddAddressScreen(
                        addressDoc: addressDoc,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Delete Address',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDelete(context, addressDoc.reference);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Function to confirm and delete an address
  Future<bool?> _confirmDelete(
      BuildContext context, DocumentReference docRef) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          title: const Text("Confirm Delete",
              style: TextStyle(color: Colors.white)),
          content: const Text("Are you sure you want to delete this address?",
              style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Delete",
                  style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ??
        false;

    if (confirm) {
      try {
        await docRef.delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address deleted successfully!')),
          );
        }
        return true; // Return true on successful deletion
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete address: $e')),
          );
        }
        return false; // Return false on error
      }
    }
    return false; // Return false if the user cancels
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to manage your addresses.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        backgroundColor: const Color(0xFF203a43),
        foregroundColor: Colors.white,
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
              padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
              child: Text(
                'Your Addresses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Manage your stored addresses here.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            // Fixed "Add Address" button
            Card(
              color: Colors.white.withOpacity(0.08),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.greenAccent),
                title: const Text('Add a New Address',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.white70),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddAddressScreen(),
                    ),
                  );
                },
              ),
            ),
            // Address List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('userAddresses')
                    .where('ownerId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No addresses found.',
                            style: TextStyle(color: Colors.white70)));
                  }

                  final addresses = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index].data() as Map<String, dynamic>;
                      return Dismissible(
                        key: Key(addresses[index].id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.redAccent,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) => _confirmDelete(context, addresses[index].reference),
                        child: Card(
                          color: Colors.white.withOpacity(0.1),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: const Icon(Icons.location_on, color: Colors.white70),
                            title: Text(address['addressName'] ?? 'Unnamed Address',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${address['street']}, ${address['city']}, ${address['state']} - ${address['postalCode']}',
                              style: const TextStyle(color: Colors.white54),
                            ),
                            onTap: () => _showAddressActions(context, addresses[index]),
                            trailing: const Icon(Icons.more_vert, color: Colors.white54),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}