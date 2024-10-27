import 'package:finance_recorder/screens/TransactionDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Transaction.dart';

class TransactionListPage extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionListPage({super.key, required this.transactions});

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
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    Transaction transaction = transactions[index];
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
                            builder: (context) => TransactionDetailScreen(transactionId: transaction.id),
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
