import 'package:finance_recorder/models/Transaction.dart';
import 'package:finance_recorder/screens/TransactionDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Transaction> filteredTransactions = GlobalContent.transactions;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {}); // Rebuilds the widget to show/hide the clear button based on focus
    });
  }

  void _filterTransactions(String query) {
    setState(() {
      filteredTransactions = GlobalContent.transactions
          .where((transaction) => transaction.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.unfocus(); // Dismiss the keyboard
    _filterTransactions(''); // Reset the filtered list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Transactions'),
      ),
      resizeToAvoidBottomInset: true, // Ensures content resizes when the keyboard appears
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    labelText: 'Search by Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _focusNode.hasFocus
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                        : null,
                  ),
                  onChanged: _filterTransactions,
                ),
              ),
              const SizedBox(height: 20),
              if (_searchController.text.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, size: 100, color: Colors.blue),
                        const SizedBox(height: 20),
                        const Text(
                          "Search for Transactions",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Enter a title to start searching for transactions.",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredTransactions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt, size: 100, color: Colors.red),
                        const SizedBox(height: 20),
                        const Text(
                          "No Transactions Found",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Try a different search term.",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true, // Ensures the ListView takes only the space it needs
                  physics: const NeverScrollableScrollPhysics(), // Prevents scrolling inside the ListView
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return ListTile(
                      title: Text(
                        transaction.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(transaction.description),
                          const SizedBox(height: 4),
                          Text('Amount: Rs.${transaction.price.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: Text(DateFormat('yyyy-MM-dd').format(transaction.date)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionDetailScreen(
                              transactionId: transaction.id,
                              onTransactionDeleted: () {
                                setState(() {
                                  _filterTransactions('');
                                });
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
      ),
    );
  }

}


