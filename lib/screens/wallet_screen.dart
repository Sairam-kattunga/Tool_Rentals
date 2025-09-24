// wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  double _currentBalance = 1500.50; // Dummy initial balance
  List<Map<String, dynamic>> _transactions = [
    {
      'amount': 500.0,
      'type': 'deposit',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'amount': 250.75,
      'type': 'withdrawal',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'amount': 1000.0,
      'type': 'deposit',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void _addFunds(double amount) {
    if (amount > 0) {
      setState(() {
        _currentBalance += amount;
        _transactions.insert(0, {
          'amount': amount,
          'type': 'deposit',
          'timestamp': DateTime.now(),
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('₹$amount added to wallet.')));
      }
    }
  }

  void _withdrawFunds(double amount) {
    if (amount > 0 && _currentBalance >= amount) {
      setState(() {
        _currentBalance -= amount;
        _transactions.insert(0, {
          'amount': amount,
          'type': 'withdrawal',
          'timestamp': DateTime.now(),
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('₹$amount withdrawn from wallet.')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient funds or invalid amount.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildBalanceCard(),
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
              child: _buildTransactionHistory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
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
                _currencyFormat.format(_currentBalance),
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
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showAddFundsDialog(),
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
              onPressed: () => _showWithdrawFundsDialog(),
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

  void _showAddFundsDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0b2a33),
          title: const Text('Add Funds', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixText: '₹',
              prefixStyle: const TextStyle(color: Colors.greenAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0.0;
                if (amount > 0) {
                  _addFunds(amount);
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount.')));
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showWithdrawFundsDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0b2a33),
          title: const Text('Withdraw Funds', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixText: '₹',
              prefixStyle: const TextStyle(color: Colors.greenAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0.0;
                if (amount > 0) {
                  _withdrawFunds(amount);
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount.')));
                }
              },
              child: const Text('Withdraw'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionHistory() {
    if (_transactions.isEmpty) {
      return const Center(child: Text('No transactions yet.', style: TextStyle(color: Colors.white70)));
    }

    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        final isDeposit = transaction['type'] == 'deposit';
        final amount = transaction['amount'] as double;
        final timestamp = transaction['timestamp'] as DateTime;

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
  }
}