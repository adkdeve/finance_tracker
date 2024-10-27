import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String selectedCategory = 'Shopping';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Add Transaction', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySelection(),
            SizedBox(height: 30),
            _buildTransactionForm(),
            Spacer(),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.add, size: 40, color: Colors.blueAccent),
          ),
        ),
        SizedBox(height: 20),
        Text('Choose category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCategoryIcon(Icons.shopping_cart, 'Shopping'),
            _buildCategoryIcon(Icons.fastfood, 'Food'),
            _buildCategoryIcon(Icons.directions_car, 'Travel'),
            _buildCategoryIcon(Icons.home, 'Rent'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[300],
            child: Icon(icon, color: isSelected ? Colors.white : Colors.black),
          ),
          SizedBox(height: 5),
          Text(label, style: TextStyle(color: isSelected ? Colors.blueAccent : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildTransactionForm() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Transaction name',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            labelText: 'Date',
            border: OutlineInputBorder(),
          ),
          onTap: () {
            // Implement date picker
          },
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: () {
        // Handle adding transaction
      },
      child: Text('Add Transaction'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 120),
      ),
    );
  }
}
