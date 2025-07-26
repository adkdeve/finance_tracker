import 'package:finance_recorder/screens/TransactionDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Transaction.dart';

class TransactionListPage extends StatefulWidget {
  final List<Transaction> transactions;

  const TransactionListPage({super.key, required this.transactions});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  late List<Transaction> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = List.from(widget.transactions); // Initialize the transactions list
  }

  void _updateTransactions() {
    setState(() {
      _transactions = List.from(widget.transactions); // Refresh the transactions list
    });
  }

  void _removeTransaction(int id) {
    setState(() {
      _transactions.removeWhere((transaction) => transaction.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction List"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    Transaction transaction = _transactions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: transaction.type == 'profit' ? Colors.green : Colors.red,
                        child: const Icon(Icons.shopping_bag, color: Colors.white),
                      ),
                      title: Text(
                        transaction.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM dd, yyyy').format(transaction.date)),
                          Text(
                            '₹${transaction.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionDetailScreen(
                              transactionId: transaction.id,
                              onTransactionUpdated: () {
                                _updateTransactions(); // Update the list on return
                              },
                              onTransactionDeleted: () {
                                _removeTransaction(transaction.id); // Remove transaction if deleted
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

