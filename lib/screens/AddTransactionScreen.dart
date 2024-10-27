import 'package:flutter/material.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Number of columns
          mainAxisSpacing: 20, // Vertical spacing
          crossAxisSpacing: 20, // Horizontal spacing
          children: [
            _buildCardButton(context, 'Income', Icons.money),
            _buildCardButton(context, 'Expense', Icons.shopping_cart),
            _buildCardButton(context, 'Food', Icons.fastfood),
            _buildCardButton(context, 'Transport', Icons.directions_car),
            _buildCardButton(context, 'Shopping', Icons.store),
            _buildCardButton(context, 'Utilities', Icons.home),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Handle button tap
        // You can push the details of the selected category or just show a dialog, etc.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $title')),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
