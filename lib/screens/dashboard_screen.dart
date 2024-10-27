import 'package:finance_recorder/screens/TransactionDetailScreen.dart';
import 'package:finance_recorder/screens/TransactionListPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_recorder/Transaction.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0; // Track the currently selected tab

  final List<Widget> _screens = [
    const DashboardScreen(), // Dashboard Screen
    const TransactionListPage(transactions: []), // Transaction List Screen
    const Center(child: Text('Profile Screen')), // Placeholder for Profile Screen
  ];

  // Initialize currentMonth and currentYear
  String? currentMonth;
  int? currentYear;
  String currentFilter = 'all'; // Default filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Wallet', style: TextStyle(color: Colors.black)),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildMonthSelector(),
            const SizedBox(height: 20),
            _buildTransactionSummary(), // Transaction summary
            const SizedBox(height: 10),
            Expanded( // Wrap the transaction list in Expanded
              child: _buildTransactionList(), // Transaction list
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    double balance = 2410.0; // Replace with your dynamic balance calculation
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6A6BB2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Center( // Center the price
            child: Text(
              '₹${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30, // Smaller font size for elegance
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align button to the right
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to add money screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6A6BB2),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), // Smaller padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5, // Add some elevation to the button
                ),
                child: const Text(
                  'Add Money',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Slightly smaller font size
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary() {
    // Filter transactions based on the selected month and year
    List<Transaction> filteredTransactions = GlobalContent.transactions;

    if (currentMonth != null && currentYear != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return DateFormat('MMMM').format(transaction.date) == currentMonth &&
            transaction.date.year == currentYear;
      }).toList();
    }

    // Calculate total income and expenses based on the filtered transactions
    double totalIncome = filteredTransactions
        .where((transaction) => transaction.type == 'profit')
        .fold(0, (sum, transaction) => sum + transaction.price);

    double totalExpenses = filteredTransactions
        .where((transaction) => transaction.type == 'expense')
        .fold(0, (sum, transaction) => sum + transaction.price);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                currentFilter = 'income'; // Set the filter to income
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${totalIncome.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const Text('Income'),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                currentFilter = 'expenses'; // Set the filter to expenses
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const Text('Expenses'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    List<String> months = _generateMonthList(12); // Function to generate month list

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: months.map((month) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildMonthButton(month),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthButton(String label) {
    DateTime selectedDate;
    try {
      selectedDate = DateFormat('MMMM yyyy').parse(label);
    } catch (e) {
      // If parsing fails, fall back to an alternate format
      selectedDate = DateFormat('MMM yyyy').parse(label);
    }

    return OutlinedButton(
      onPressed: () {
        setState(() {
          currentMonth = DateFormat('MMMM').format(selectedDate); // Get the full month name
          currentYear = selectedDate.year; // Get the year
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF6A6BB2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildTransactionList() {
    List<Transaction> filteredTransactions;

    // Filter transactions based on the current filter (income or expenses)
    if (currentFilter == 'income') {
      filteredTransactions = GlobalContent.transactions
          .where((transaction) => transaction.type == 'profit')
          .toList();
    } else if (currentFilter == 'expenses') {
      filteredTransactions = GlobalContent.transactions
          .where((transaction) => transaction.type == 'expense')
          .toList();
    } else {
      filteredTransactions = GlobalContent.transactions; // Show all transactions
    }

    // Further filter based on the selected month and year
    if (currentMonth != null && currentYear != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return DateFormat('MMMM').format(transaction.date) == currentMonth &&
            transaction.date.year == currentYear;
      }).toList();
    }

    // Determine if the clear filter button should be shown
    bool isFilterActive = currentMonth != null && currentYear != null || currentFilter != 'all';

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  Transaction transaction = filteredTransactions[index];
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
              if (filteredTransactions.isEmpty)
                const Center(
                  child: Text('No transactions found for the selected filters.'),
                ),
            ],
          ),
        ),
        if (isFilterActive)
          Positioned(
            top: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentMonth = null; // Reset the month filter
                  currentYear = null; // Reset the year filter
                  currentFilter = 'all'; // Reset the filter
                });
              },
              child: const Text('Clear Filters'),
            ),
          ),
      ],
    );
  }

  List<String> _generateMonthList(int months) {
    return List.generate(months, (index) {
      DateTime date = DateTime.now().subtract(Duration(days: index * 30)); // Approximation for months
      return DateFormat('MMMM yyyy').format(date);
    }).reversed.toList(); // To display recent months first
  }
}
