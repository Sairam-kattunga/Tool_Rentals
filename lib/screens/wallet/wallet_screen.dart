// wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_rental_app/screens/wallet/add_funds_screen.dart'; // Assuming you have these screens
import 'package:tool_rental_app/screens/wallet/withdraw_funds_screen.dart';


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Wallet', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0b2a33),
          elevation: 2,
        ),
        body: const Center(
          child: Text('Please log in to view your wallet.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0b2a33),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
            _buildBalanceCard(user!),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Transaction History',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _buildTransactionHistory(user!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(User user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: const Color(0xFF2c5364),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
              ),
            ),
          );
        }

        double balance = (snapshot.data?.data() as Map<String, dynamic>?)?['balance'] as double? ?? 0.0;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: const Color(0xFF2c5364),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'Current Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currencyFormat.format(balance),
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddFundsScreen()));
              },
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text('Add Funds', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WithdrawFundsScreen()));
              },
              icon: const Icon(Icons.remove, color: Colors.white),
              label: const Text('Withdraw', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No transactions yet.', style: TextStyle(color: Colors.white70)));
        }

        final transactions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index].data() as Map<String, dynamic>;
            final isDeposit = transaction['type'] == 'deposit';
            final amount = (transaction['amount'] as num).toDouble();
            final timestamp = (transaction['timestamp'] as Timestamp).toDate();

            return ListTile(
              leading: Icon(
                isDeposit ? Icons.add_circle : Icons.remove_circle,
                color: isDeposit ? Colors.greenAccent : Colors.redAccent,
              ),
              title: Text(
                isDeposit ? 'Deposit' : 'Withdrawal',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat.yMMMd().add_jm().format(timestamp),
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Text(
                _currencyFormat.format(amount.abs()),
                style: TextStyle(
                  color: isDeposit ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        );
      },
    );
  }
}