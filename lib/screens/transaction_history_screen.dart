import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final List<Map<String, String>> transactions = [
    {"amount": "\$100", "category": "Food", "description": "Lunch", "date": "Oct 10"},
    {"amount": "\$150", "category": "Transport", "description": "Uber Ride", "date": "Oct 8"},
    {"amount": "\$200", "category": "Entertainment", "description": "Movies", "date": "Oct 5"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return Card(
            elevation: 3,
            child: ListTile(
              title: Text("${transaction['category']} - ${transaction['amount']}"),
              subtitle: Text(transaction['description']!),
              trailing: Text(transaction['date']!),
            ),
          );
        },
      ),
    );
  }
}
