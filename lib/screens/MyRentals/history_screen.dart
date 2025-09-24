import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DateFormat _dateFormat = DateFormat.yMMMd().add_jm();

  String formatTimestamp(Timestamp? ts) {
    if (ts == null) return 'N/A';
    try {
      return _dateFormat.format(ts.toDate());
    } catch (e) {
      return 'N/A';
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ID copied to clipboard")),
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> data, bool isCompleted) {
    final isOwner = data['ownerId'] == FirebaseAuth.instance.currentUser!.uid;
    final itemId = data['toolId'] ?? data['packageId'] ?? 'N/A';
    final itemName = data['toolName'] ?? data['packageName'] ?? 'Item';
    final pricePerDay = data['pricePerDay']?.toString() ?? 'N/A';

     showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0b2a33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            itemName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status: ${data['status']?.toUpperCase() ?? ''}",
                    style: TextStyle(color: isCompleted ? Colors.greenAccent : Colors.redAccent)),
                const SizedBox(height: 8),
                Text(
                  isOwner
                      ? "Renter: ${data['renterName'] ?? 'N/A'}"
                      : "Owner: ${data['ownerName'] ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                _buildRow("Item ID", itemId),
                _buildRow("Price Per Day", "₹$pricePerDay"),
                _buildRow("Requested On", formatTimestamp(data['requestDate'])),
                _buildRow("Responded On", formatTimestamp(data['responseDate'])),
                if (isCompleted) ...[
                  _buildRow("Collected On", formatTimestamp(data['collectedAt'])),
                  _buildRow("Returned On", formatTimestamp(data['returnedAt'])),
                  _buildRow("Completed On", formatTimestamp(data['completedAt'])),
                ] else ...[
                  _buildRow("Rejected On", formatTimestamp(data['rejectedAt'])),
                ],
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

  Widget _buildRow(String label, String value) {
    if (value == 'N/A') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(color: Colors.white, fontSize: 14)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
          if (label.contains("ID"))
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white54, size: 14),
              onPressed: () => _copyToClipboard(context, value),
            ),
        ],
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _getHistoryStream(String userId) {
    final completedStream = FirebaseFirestore.instance
        .collection('completedRentals')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'docId': doc.id, 'isCompleted': true}).toList());

    final rejectedStream = FirebaseFirestore.instance
        .collection('rejectedRentals')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'docId': doc.id, 'isCompleted': false}).toList());

    return completedStream.asyncMap((completedList) async {
      final rejectedList = await rejectedStream.first;
      return [...completedList, ...rejectedList];
    });
  }

  void _showReviewDialog(BuildContext context, Map<String, dynamic> rentalData, bool isPackage) {
    double rating = 5.0;
    final controller = TextEditingController();
    final reviewCollection = isPackage ? 'packageReviews' : 'toolReviews';
    final itemCollection = isPackage ? 'packages' : 'tools';
    final itemIdKey = isPackage ? 'packageId' : 'toolId';
    final uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection(reviewCollection)
        .where(itemIdKey, isEqualTo: rentalData[itemIdKey])
        .where('userId', isEqualTo: uid)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("You have already reviewed this item.")));
        }
        return;
      }

      showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF0b2a33),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text("Leave a Review", style: TextStyle(color: Colors.white)),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("Review for: ${rentalData['toolName'] ?? rentalData['packageName']}",
                          style: const TextStyle(color: Colors.white70)),
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
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final reviewerName = (await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .get())
                          .data()?['name'] ??
                          'User';

                      final itemRef = FirebaseFirestore.instance
                          .collection(itemCollection)
                          .doc(rentalData[itemIdKey]);
                      FirebaseFirestore.instance.runTransaction((transaction) async {
                        final itemDoc = await transaction.get(itemRef);
                        if (itemDoc.exists) {
                          final currentRating =
                              (itemDoc.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;
                          final currentCount = (itemDoc.data()?['ratingCount'] as int?) ?? 0;
                          final newRating =
                              ((currentRating * currentCount) + rating) / (currentCount + 1);
                          transaction.update(itemRef, {
                            'averageRating': newRating,
                            'ratingCount': currentCount + 1,
                          });
                        }
                      });

                      await FirebaseFirestore.instance.collection(reviewCollection).add({
                        itemIdKey: rentalData[itemIdKey],
                        'userId': uid,
                        'reviewerName': reviewerName,
                        'rating': rating,
                        'review': controller.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Review submitted!')));
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your rental history.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rental History", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0b2a33),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071018), Color(0xFF0b2a33), Color(0xFF12343d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getHistoryStream(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white70)));
            }
            final historyList = snapshot.data ?? [];
            if (historyList.isEmpty) {
              return const Center(
                  child: Text("No history available.",
                      style: TextStyle(color: Colors.white70)));
            }

            historyList.sort((a, b) {
              final aTime = (a['completedAt'] ?? a['rejectedAt']) as Timestamp?;
              final bTime = (b['completedAt'] ?? b['rejectedAt']) as Timestamp?;
              return (bTime?.compareTo(aTime ?? Timestamp.now()) ?? 0);
            });

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final data = historyList[index];
                final isCompleted = data['isCompleted'] == true;
                final itemName = data['toolName'] ?? data['packageName'] ?? 'Item';
                final itemPrice = data['pricePerDay']?.toString() ?? 'N/A';
                final isRenter = data['renterId'] == user.uid;
                final isPackage = data['packageId'] != null;

                return Card(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    onTap: () => _showDetailsDialog(context, data, isCompleted),
                    title: Text(itemName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompleted
                              ? "Completed Rental"
                              : "Rejected Rental",
                          style: TextStyle(
                              color: isCompleted ? Colors.greenAccent : Colors.redAccent),
                        ),
                        const SizedBox(height: 4),
                        Text("Price Per Day: ₹$itemPrice",
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                    trailing: isCompleted && isRenter
                        ? IconButton(
                      icon: const Icon(Icons.rate_review, color: Colors.white70),
                      onPressed: () => _showReviewDialog(context, data, isPackage),
                    )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

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
            onTap: enableInteraction ? () => onRatingChanged?.call(starIndex) : null,
            child: Icon(icon, color: Colors.amber, size: 18),
          );
        },
      ),
    );
  }
}
