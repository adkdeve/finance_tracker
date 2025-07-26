import 'package:finance_recorder/models/Transaction.dart';
import 'package:finance_recorder/screens/TransactionDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: GlobalContent.transactions.length,
            itemBuilder: (context, index) {
              Transaction transaction = GlobalContent.transactions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(transaction.name),
                  subtitle: Text(DateFormat('dd-MM-yyyy').format(transaction.date)),
                  trailing: Text(
                    '₹ ${transaction.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: transaction.type == 'profit' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailScreen(
                          transactionId: transaction.id,
                          onTransactionDeleted: () {
                            setState(() {
                              GlobalContent.transactions.removeWhere((t) => t.id == transaction.id);
                            });
                            Navigator.pop(context, true); // Indicate deletion success
                          },
                          onTransactionUpdated: () {
                            setState(() {
                              // Refresh the list to reflect updates
                            });
                          },
                        ),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        // Rebuild the screen if deletion occurred
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
