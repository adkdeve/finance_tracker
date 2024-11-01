import 'package:finance_recorder/screens/TransactionDetailScreen.dart';
import 'package:finance_recorder/screens/TransactionListPage.dart';
import 'package:finance_recorder/screens/transaction_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_recorder/Transaction.dart';
import 'package:finance_recorder/screens/AddTransactionScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double balance = 2410.0;
  int _currentIndex = 0;
  int _currentStep = 0;
  double? _amount;
  String? _transactionType;
  DateTime? _selectedDate;
  String? _title;
  String? _description;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Cash Wallet', style: TextStyle(color: Colors.black)),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: _currentIndex == 0
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildMonthSelector(),
            const SizedBox(height: 20),
            _buildTransactionSummary(),
            const SizedBox(height: 10),
            _buildTransactionList(),
          ],
        ),
      )
          : TransactionHistoryScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            _currentStep = 0; // Reset to first step
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 24,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_currentStep == 0) ...[
                            const Text(
                              'Add Transaction - Step 1',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                prefixIcon: const Icon(Icons.attach_money),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (value) => _amount = double.tryParse(value),
                            ),
                            const SizedBox(height: 16),
                            // DropdownButtonFormField<String>(
                            //   decoration: InputDecoration(
                            //     labelText: 'Currency Type',
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(10),
                            //     ),
                            //   ),
                            //   items: ['USD', 'INR', 'EUR'].map((String value) {
                            //     return DropdownMenuItem<String>(
                            //       value: value,
                            //       child: Text(value),
                            //     );
                            //   }).toList(),
                            //   onChanged: (value) => _currencyType = value,
                            // ),
                            // const SizedBox(height: 16),
                          ] else if (_currentStep == 1) ...[
                            const Text(
                              'Add Transaction - Step 2',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Transaction Type',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: ['Income', 'Expense'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) => _transactionType = value,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Date',
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                setModalState(() => _selectedDate = pickedDate);
                              },
                            ),
                            const SizedBox(height: 16),
                          ] else if (_currentStep == 2) ...[
                            const Text(
                              'Add Transaction - Step 3',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Title',
                                prefixIcon: const Icon(Icons.title),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (value) => _title = value,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Description',
                                prefixIcon: const Icon(Icons.description),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (value) => _description = value,
                            ),
                            const SizedBox(height: 16),
                          ],
                          ElevatedButton(
                            onPressed: () {
                              setModalState(() {
                                if (_currentStep < 2) {
                                  _currentStep++; // Move to next step
                                } else {
                                  _saveTransaction();
                                  Navigator.pop(context); // Close the bottom sheet
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              backgroundColor: const Color(0xFF6A6BB2),
                            ),
                            child: Text(
                              _currentStep < 2 ? 'Next' : 'Save Transaction',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6A6BB2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('₹${balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('available balance', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showAddAmountDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6A6BB2),
                ),
                child: const Text('Add Amount'),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     // Navigate to add expense screen
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.white,
              //     foregroundColor: const Color(0xFF6A6BB2),
              //   ),
              //   child: const Text('Add expense'),
              // ),
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

    // Sort the filtered transactions by date in descending order
    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

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
              // Button below the ListView
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionListPage(transactions: filteredTransactions),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6A6BB2),
                  ),
                  child: const Text(
                    'More Transactions',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Show clear filter button if any filter is active
        if (isFilterActive)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  currentFilter = 'all'; // Clear the filter
                  currentMonth = null; // Reset month filter
                  currentYear = null; // Reset year filter
                });
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.clear, color: Colors.white),
            ),
          ),
      ],
    );
  }

  void _saveTransaction() {
    if (_amount != null && _transactionType != null && _selectedDate != null && _title != null && _description != null) {
      final newTransaction = Transaction(
        id: GlobalContent.transactions.length + 1, // Incremental ID
        name: _title!,
        description: _description!,
        price: _amount!,
        type: _transactionType!,
        date: _selectedDate!,
      );
      GlobalContent.transactions.add(newTransaction);
    }
  }

  void _showAddAmountDialog() {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Amount'),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter amount',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without updating
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (amountController.text.isNotEmpty) {
                  double? enteredAmount = double.tryParse(amountController.text);
                  if (enteredAmount != null) {
                    setState(() {
                      balance += enteredAmount; // Update the balance
                    });
                    Navigator.pop(context); // Close the dialog
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  List<String> _generateMonthList(int count) {
    List<String> monthList = [];
    DateTime now = DateTime.now();

    for (int i = 0; i < count; i++) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      String formattedDate = DateFormat('MMM yyyy').format(date);
      monthList.add(formattedDate);
    }

    return monthList;
  }
}
