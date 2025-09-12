import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tool_rental_app/screens/RentTool/tool_detail_screen.dart';
import 'chat_screen.dart';

class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen> {
  static const Map<String, String> trackingSteps = {
    'pending': '1. Request Sent',
    'accepted': '2. Accepted by Owner',
    'collected-renter': '3. Renter Confirmed Collection',
    'collected': '3. Tool Collected',
    'returned-renter': '4. Renter Confirmed Return',
    'returned': '4. Owner Confirmed Return',
    'completed': '5. Transaction Completed',
    'rejected': 'Request Rejected',
  };

  late final Stream<DateTime> _ticker;
  final DateFormat _dateFormat = DateFormat.yMMMd().add_jm();
  final StreamController<void> _updateStream = StreamController.broadcast();
  int _selectedIndex = 0;

  final Map<String, String> _categoryImages = {
    "Home & Garden": "lib/assets/Categories/Home_Garden.png",
    "Automotive": "lib/assets/Categories/Automotive.png",
    "Electronics": "lib/assets/Categories/Electronics.png",
    "Construction": "lib/assets/Categories/Construction.png",
    "Events": "lib/assets/Categories/Events.png",
    "Sports & Outdoors": "lib/assets/Categories/Sports_Outdoors.png",
    "Medical & Health": "lib/assets/Categories/Medical_Health.png",
    "Office": "lib/assets/Categories/Office.png",
    "Photography & Video": "lib/assets/Categories/Photography_video.png",
    "Musical Instruments": "lib/assets/Categories/Musical_Instruments.png",
    "Party Supplies": "lib/assets/Categories/Party_Supplies.png",
    "Heavy Machinery": "lib/assets/Categories/Heavy_Machinary.png",
    "Miscellaneous": "lib/assets/Categories/Miscellaneous.png",
    "All": "lib/assets/Categories/All.png",
  };

  @override
  void initState() {
    super.initState();
    _ticker = Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now()).asBroadcastStream();
  }

  @override
  void dispose() {
    _updateStream.close();
    super.dispose();
  }

  String formatTimestamp(Timestamp? ts) {
    if (ts == null) return 'N/A';
    try {
      return _dateFormat.format(ts.toDate());
    } catch (e) {
      return 'N/A';
    }
  }

  Future<bool> _handleBackNavigation() async {
    Navigator.pushReplacementNamed(context, '/home');
    return false;
  }

  void _openWhatsApp({required String phoneNumber, required String message}) async {
    final Uri url = Uri.parse("https://wa.me/$phoneNumber/?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("WhatsApp is not installed.")),
      );
    }
  }

  void _showTrackingDialog(BuildContext context, String currentStatus, Map<String, dynamic> rentalData, String docId, Map<String, dynamic> toolData) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0b2a33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Rental Status", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...trackingSteps.entries.map((step) {
                  final keys = trackingSteps.keys.toList();
                  final isCurrent = step.key == currentStatus;
                  final isCompleted = keys.indexOf(step.key) < keys.indexOf(currentStatus);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted || isCurrent ? Colors.greenAccent : Colors.white54,
                          ),
                          child: Center(
                            child: Icon(
                              isCompleted ? Icons.check : Icons.circle,
                              color: Colors.black,
                              size: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step.value,
                            style: TextStyle(
                              color: isCurrent || isCompleted ? Colors.white : Colors.white54,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(rentalData['ownerId'] == FirebaseAuth.instance.currentUser!.uid ? rentalData['renterId'] : rentalData['ownerId']).get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return const SizedBox.shrink();
                    final otherUser = userSnapshot.data!.data() as Map<String, dynamic>;
                    final phoneNumber = otherUser['contact'] ?? '';
                    final isOwner = rentalData['ownerId'] == FirebaseAuth.instance.currentUser!.uid;

                    return ElevatedButton.icon(
                      onPressed: phoneNumber.isNotEmpty
                          ? () => _openWhatsApp(
                        phoneNumber: phoneNumber,
                        message: isOwner ? "Hi, I'm interested in the tool I rented from you, ${rentalData['toolName']}." : "Hi, I'm the owner of the tool, ${rentalData['toolName']}. Let's chat about the rental.",
                      )
                          : null,
                      icon: const Icon(Icons.chat, color: Colors.green),
                      label: const Text("WhatsApp", style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Close", style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  void _showCompletedDialog(BuildContext context, Map<String, dynamic> rentalData) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final isOwner = rentalData['ownerId'] == FirebaseAuth.instance.currentUser!.uid;
        return AlertDialog(
          backgroundColor: const Color(0xFF0b2a33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(rentalData['toolName'] ?? 'Tool', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Status: ${rentalData['status']?.toUpperCase()}", style: TextStyle(color: Colors.greenAccent)),
              const SizedBox(height: 8),
              Text(
                isOwner
                    ? "Renter: ${rentalData['renterName'] ?? 'N/A'}"
                    : "Owner: ${rentalData['ownerName'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              _buildHistoryInfoRow(label: "Requested On", value: formatTimestamp(rentalData['requestDate'])),
              _buildHistoryInfoRow(label: "Accepted On", value: formatTimestamp(rentalData['responseDate'])),
              _buildHistoryInfoRow(label: "Collected On", value: formatTimestamp(rentalData['collectedAt'])),
              _buildHistoryInfoRow(label: "Returned On", value: formatTimestamp(rentalData['returnedAt'])),
              _buildHistoryInfoRow(label: "Completed On", value: formatTimestamp(rentalData['completedAt'])),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Close", style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryInfoRow({required String label, required String value}) {
    if (value == 'N/A') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        "$label: $value",
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Future<void> _handleRequest(BuildContext context, String docId, String newStatus) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('rentalRequests').doc(docId);
      final doc = await docRef.get();
      if (!doc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request not found.')));
        return;
      }
      final rentalData = doc.data() as Map<String, dynamic>;
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      Map<String, dynamic> updateData = {
        'status': newStatus,
        'responseDate': FieldValue.serverTimestamp(),
      };

      if (newStatus == 'collected-renter' && rentalData['renterId'] == currentUserId) {
        // Renter marks tool as collected, waiting for owner confirmation
      } else if (newStatus == 'collected' && rentalData['ownerId'] == currentUserId) {
        updateData['collectedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == 'returned-renter' && rentalData['renterId'] == currentUserId) {
        // Renter marks tool as returned, waiting for owner confirmation
      } else if (newStatus == 'returned' && rentalData['ownerId'] == currentUserId) {
        updateData['returnedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == 'completed' && rentalData['ownerId'] == currentUserId) {
        final completedDoc = {
          ...rentalData,
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'participants': [rentalData['ownerId'], rentalData['renterId']],
        };
        await FirebaseFirestore.instance.collection('completedRentals').add(completedDoc);
        final toolRef = FirebaseFirestore.instance.collection('tools').doc(rentalData['toolId']);
        await toolRef.update({'available': true});
        await docRef.delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction completed and moved to history!')));
        return;
      } else {
        await docRef.update(updateData);
      }
      await docRef.update(updateData);

      if (newStatus == 'accepted') {
        final toolRef = FirebaseFirestore.instance.collection('tools').doc(rentalData['toolId']);
        await toolRef.update({'available': false});
      }

      if (!mounted) return;
      _updateStream.add(null);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request updated to $newStatus')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update request: $e')));
    }
  }

  Widget _buildRentalRequestCard(BuildContext context, QueryDocumentSnapshot doc, String userType) {
    final rentalData = doc.data() as Map<String, dynamic>;
    final status = rentalData['status'] as String? ?? 'pending';
    final toolId = rentalData['toolId'];

    if (toolId == null) {
      return Card(
        color: Colors.white.withOpacity(0.06),
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const ListTile(
          title: Text('Error: Tool ID not found', style: TextStyle(color: Colors.redAccent)),
          subtitle: Text('This rental request is missing key information.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('tools').doc(toolId).get(),
      builder: (context, toolSnapshot) {
        if (toolSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white70));
        }

        final toolData = toolSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final category = toolData['category'] ?? "Miscellaneous";
        final headerImage = _categoryImages[category] ?? "lib/assets/Categories/Miscellaneous.png";

        Widget? trailingWidget;
        bool isOwner = userType == 'owner';
        final currentStatus = rentalData['status'];

        if (isOwner) {
          if (currentStatus == 'pending') {
            trailingWidget = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => _handleRequest(context, doc.id, 'accepted'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                  child: const Text('Accept', style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _handleRequest(context, doc.id, 'rejected'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: const Text('Reject', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          } else if (currentStatus == 'accepted') {
            trailingWidget = ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Waiting for Renter...', style: TextStyle(color: Colors.white)),
            );
          } else if (currentStatus == 'collected-renter') {
            trailingWidget = ElevatedButton(
              onPressed: () => _handleRequest(context, doc.id, 'collected'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              child: const Text('Confirm Collection', style: TextStyle(color: Colors.black)),
            );
          } else if (currentStatus == 'collected') {
            trailingWidget = ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Waiting for Renter...', style: TextStyle(color: Colors.white)),
            );
          } else if (currentStatus == 'returned-renter') {
            trailingWidget = ElevatedButton(
              onPressed: () => _handleRequest(context, doc.id, 'returned'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              child: const Text('Confirm Return', style: TextStyle(color: Colors.black)),
            );
          } else if (currentStatus == 'returned') {
            trailingWidget = ElevatedButton(
              onPressed: () => _handleRequest(context, doc.id, 'completed'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              child: const Text('Confirm & Close', style: TextStyle(color: Colors.black)),
            );
          }
        } else { // renter
          if (currentStatus == 'pending') {
            trailingWidget = const Text('Waiting', style: TextStyle(color: Colors.white70));
          } else if (currentStatus == 'accepted') {
            trailingWidget = ElevatedButton(
              onPressed: () => _handleRequest(context, doc.id, 'collected-renter'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              child: const Text('Tool Collected', style: TextStyle(color: Colors.black)),
            );
          } else if (currentStatus == 'collected-renter') {
            trailingWidget = ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Waiting for Owner...', style: TextStyle(color: Colors.white)),
            );
          } else if (currentStatus == 'collected') {
            trailingWidget = ElevatedButton(
              onPressed: () => _handleRequest(context, doc.id, 'returned-renter'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text('Return Tool', style: TextStyle(color: Colors.white)),
            );
          } else if (currentStatus == 'returned-renter') {
            trailingWidget = ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Waiting for Owner...', style: TextStyle(color: Colors.white)),
            );
          } else if (currentStatus == 'returned') {
            trailingWidget = ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Waiting for Owner...', style: TextStyle(color: Colors.white)),
            );
          }
        }

        final title = toolData['name'] ?? rentalData['toolName'] ?? 'Tool';
        final subtitle = isOwner
            ? "Renter: ${rentalData['renterName'] ?? 'N/A'}"
            : "Owner: ${rentalData['ownerName'] ?? 'N/A'}";

        return InkWell(
          onTap: () {
            // Show the tracking and chat dialog on tap
            _showTrackingDialog(context, status, rentalData, doc.id, toolData);
          },
          child: Card(
            color: Colors.white.withOpacity(0.06),
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      headerImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        _buildStatusBadge(status),
                      ],
                    ),
                  ),
                  if (trailingWidget != null) ...[
                    const SizedBox(width: 8),
                    trailingWidget,
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.access_time;
        text = 'Pending';
        break;
      case 'accepted':
        color = Colors.blueAccent;
        icon = Icons.check_circle_outline;
        text = 'Accepted';
        break;
      case 'collected':
        color = Colors.green;
        icon = Icons.handshake;
        text = 'Collected';
        break;
      case 'collected-renter':
        color = Colors.blue;
        icon = Icons.pending;
        text = 'Waiting Owner';
        break;
      case 'returned-renter':
        color = Colors.teal;
        icon = Icons.pending;
        text = 'Waiting Owner';
        break;
      case 'returned':
        color = Colors.greenAccent;
        icon = Icons.autorenew;
        text = 'Returned';
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.done_all;
        text = 'Completed';
        break;
      case 'rejected':
        color = Colors.redAccent;
        icon = Icons.cancel;
        text = 'Rejected';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedRentalsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('completedRentals')
          .where('participants', arrayContains: userId)
          .orderBy('completedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text("No completed rentals in your history.", style: TextStyle(color: Colors.white70))),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final rentalData = docs[index].data() as Map<String, dynamic>;
            final isOwner = rentalData['ownerId'] == userId;

            return Card(
              color: Colors.white.withOpacity(0.06),
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => _showCompletedDialog(context, rentalData),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(rentalData['toolName'] ?? 'Tool', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  isOwner
                      ? "Rented by: ${rentalData['renterName'] ?? 'N/A'}"
                      : "Rented from: ${rentalData['ownerName'] ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.rate_review, color: Colors.white70),
                  onPressed: () {
                    if (rentalData['toolId'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tool data not available for review.")));
                      return;
                    }
                    _showReviewDialog(context, rentalData);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReviewDialog(BuildContext context, Map<String, dynamic> rentalData) {
    double rating = 5.0;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0b2a33),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Leave a Review", style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Review for: ${rentalData['toolName']}", style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  StarRating(
                    rating: rating,
                    enableInteraction: true,
                    onRatingChanged: (r) {
                      setState(() => rating = r.toDouble());
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Write your review...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    final reviewerName = (await FirebaseFirestore.instance.collection('users').doc(uid).get()).data()?['name'] ?? 'User';

                    final toolRef = FirebaseFirestore.instance.collection('tools').doc(rentalData['toolId']);
                    FirebaseFirestore.instance.runTransaction((transaction) async {
                      final toolDoc = await transaction.get(toolRef);
                      if (toolDoc.exists) {
                        final currentRating = (toolDoc.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;
                        final currentCount = (toolDoc.data()?['ratingCount'] as int?) ?? 0;
                        final newRating = ((currentRating * currentCount) + rating) / (currentCount + 1);
                        transaction.update(toolRef, {
                          'averageRating': newRating,
                          'ratingCount': currentCount + 1,
                        });
                      }
                    });

                    await FirebaseFirestore.instance.collection('toolReviews').add({
                      'toolId': rentalData['toolId'],
                      'userId': uid,
                      'reviewerName': reviewerName,
                      'rating': rating,
                      'review': controller.text.trim(),
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted!')));
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActiveRentalsTab(String userId) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Text("Tools I'm Renting", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildRentedToolsList(userId),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Text("Tools I'm Renting Out", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildToolsRentedOutList(userId),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your rentals.")),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Rentals", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0b2a33),
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF071018), Color(0xFF0b2a33), Color(0xFF12343d)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedIndex == 0 ? Colors.greenAccent : Colors.white10,
                          foregroundColor: _selectedIndex == 0 ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Active Rentals", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedIndex == 1 ? Colors.greenAccent : Colors.white10,
                          foregroundColor: _selectedIndex == 1 ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _selectedIndex == 0
                    ? _buildActiveRentalsTab(user.uid)
                    : _buildCompletedRentalsList(user.uid),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRentedToolsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rentalRequests')
          .where('renterId', isEqualTo: userId)
          .orderBy('requestDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.greenAccent)));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text("You have no active rental requests.", style: TextStyle(color: Colors.white70))),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return _buildRentalRequestCard(context, docs[index], 'renter');
          },
        );
      },
    );
  }

  Widget _buildToolsRentedOutList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rentalRequests')
          .where('ownerId', isEqualTo: userId)
          .orderBy('requestDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.greenAccent)));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text("You have no incoming rental requests.", style: TextStyle(color: Colors.white70))),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return _buildRentalRequestCard(context, docs[index], 'owner');
          },
        );
      },
    );
  }
}

// Placeholder for ToolDetailScreen (from previous chats)
// This should be in a separate file.

// Placeholder for ChatScreen
class ChatScreen extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String toolName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.toolName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(toolName)),
      body: Center(child: Text('Chat with $otherUserName')),
    );
  }
}

// Placeholder for StarRating
class StarRating extends StatelessWidget {
  final double rating;
  final bool enableInteraction;
  final ValueChanged<int>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.enableInteraction = true,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) {
          int starIndex = index + 1;
          IconData icon;
          if (starIndex <= rating.floor()) {
            icon = Icons.star;
          } else if (starIndex > rating.floor() && starIndex - rating <= 0.5) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }

          return GestureDetector(
            onTap: enableInteraction
                ? () {
              if (onRatingChanged != null) onRatingChanged!(starIndex);
            }
                : null,
            child: Icon(
              icon,
              color: Colors.amber,
              size: 18,
            ),
          );
        },
      ),
    );
  }
}