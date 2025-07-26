import 'package:finance_recorder/screens/EventRecordScreen.dart';
import 'package:finance_recorder/screens/ProfileScreen.dart';
import 'package:finance_recorder/screens/SearchScreen.dart';
import 'package:finance_recorder/screens/TransactionDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Transaction.dart';
import 'TransactionListPage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  int _currentStep = 0;
  double? _amount;
  String? _transactionType;
  DateTime? _selectedDate;
  String? _title;
  String? _description;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  double balance = 0.0;

  // Controllers for text fields
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadTransactions();
    calculateTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _currentIndex == 0
          ? AppBar(
        title: const Text('Cash Wallet', style: TextStyle(color: Colors.black)),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildBalanceCard(),
                const SizedBox(height: 20),
                _buildMonthSelector(),
                const SizedBox(height: 20),
                const Divider(),
                _buildTransactionSummary(),
                const Divider(),
                const SizedBox(height: 10),
                _buildTransactionList(),
              ],
            ),
          ),
          SearchScreen(),
          Container(),
          EventRecordScreen(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          if (index == 2) {
            _currentStep = 0;
            _resetTransactionInputs();
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
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(10), // Adjust padding as needed
                                  child: Text(
                                    'Rs.', // Pakistani Rupee sign
                                    style: TextStyle(
                                      fontSize: 20, // Adjust font size to align with other icons
                                      fontWeight: FontWeight.bold, // Optional: for making it bold
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (value) => _amount = double.tryParse(value),
                            ),
                            const SizedBox(height: 16),
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
                              controller: _dateController,
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
                                if (pickedDate != null) {
                                  setModalState(() {
                                    _selectedDate = pickedDate;
                                    _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                  });
                                }
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
                              controller: _titleController,
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
                              controller: _descriptionController,
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
                                  _currentStep++;
                                } else {
                                  _saveTransaction();
                                  toastification.show(
                                    context: context,
                                    type: ToastificationType.success,
                                    style: ToastificationStyle.flat,
                                    title: const Text('Success'),
                                    description: const Text('Transaction saved successfully.'),
                                    autoCloseDuration: const Duration(seconds: 3),
                                    alignment: Alignment.topRight,
                                  );
                                  Navigator.pop(context);
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
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Event Records',
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
    double totalPaidToday = calculateTotalPaidToday();
    double totalOweThisMonth = calculateTotalOweThisMonth();
    double totalDueLast12Months = calculateTotalDueLast12Months();
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Color(0xFF6A6BB2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('Rs. ${totalPaidToday.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Total Transaction Today', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('This Month: Rs.${totalOweThisMonth.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('This Year: Rs.${totalDueLast12Months.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust spacing
          children: [
            _buildSummaryItem(
              'Rs.${totalIncome.toStringAsFixed(2)}',
              'Income',
              Colors.green,
              Icons.arrow_upward,
            ),
            _buildSummaryItem(
              'Rs.${totalExpenses.toStringAsFixed(2)}',
              'Expenses',
              Colors.red,
              Icons.arrow_downward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String amount, String type, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentFilter = type.toLowerCase();
        });
        toastification.show(
          context: context,
          type: ToastificationType.info,
          style: ToastificationStyle.flat,
          title: Text('Filter Applied'),
          description: Text('Showing only $type transactions.'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topRight,
        );
      },
      child: Row(
        children: [
          Icon(icon, color: color, size: 24.0), // Icon for visual appeal
          const SizedBox(width: 8.0), // Space between icon and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18, // Slightly larger font size
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                type,
                style: const TextStyle(
                  fontSize: 16, // Smaller font size for type
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    List<String> months = _generateMonthList(12);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: months.map((month) {
          bool isSelected = displayMonth == month;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildMonthButton(month, isSelected),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthButton(String label, bool isSelected) {
    DateTime selectedDate;
    try {
      selectedDate = DateFormat('MMMM yyyy').parse(label);
    } catch (e) {
      selectedDate = DateFormat('MMM yyyy').parse(label);
    }

    return ElevatedButton(
      onPressed: () {
        setState(() {
          currentMonth = DateFormat('MMMM').format(selectedDate);
          currentYear = selectedDate.year;
          displayMonth = label;
          calculateTotal();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : const Color(0xFF6A6BB2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildTransactionList() {
    List<Transaction> filteredTransactions;

    if (currentFilter == 'income') {
      filteredTransactions = GlobalContent.transactions
          .where((transaction) => transaction.type == 'profit')
          .toList();
    } else if (currentFilter == 'expenses') {
      filteredTransactions = GlobalContent.transactions
          .where((transaction) => transaction.type == 'expense')
          .toList();
    } else {
      filteredTransactions = GlobalContent.transactions;
    }

    if (currentMonth != null && currentYear != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return DateFormat('MMMM').format(transaction.date) == currentMonth &&
            transaction.date.year == currentYear;
      }).toList();
    }

    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

    bool isFilterActive = (currentMonth != null && currentYear != null) || currentFilter != 'all';

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
                          'Rs.${transaction.price.toStringAsFixed(2)}',
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
                            onTransactionDeleted: () {
                              setState(() {});
                              toastification.show(
                                context: context,
                                type: ToastificationType.success,
                                style: ToastificationStyle.flat,
                                title: const Text('Transaction Deleted'),
                                description: Text('${transaction.name} was deleted.'),
                                autoCloseDuration: const Duration(seconds: 3),
                                alignment: Alignment.topRight,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (filteredTransactions.isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0), // Individual padding for "More Transactions"
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
                            backgroundColor: const Color(0xFF6A6BB2),
                          ),
                          child: const Text(
                            'More Transactions',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  if (isFilterActive)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0), // Individual padding for "Clear Filter"
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentFilter = 'all';
                            currentMonth = null;
                            currentYear = null;
                            displayMonth = null;
                            calculateTotal();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15), // Adjust padding for circle size
                          backgroundColor: const Color(0xFF6A6BB2), // Match color of "More Transactions" button
                        ),
                        child: const Icon(Icons.clear, color: Colors.white),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loadTransactions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('transactions');

    if (encodedData != null) {
      List<dynamic> decodedData = jsonDecode(encodedData);
      GlobalContent.transactions = decodedData
          .map((tx) => Transaction.fromJson(tx))
          .toList()
          .cast<Transaction>();
      calculateTotal();
    }

    setState(() {});
  }

  Future<void> _saveTransactions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(GlobalContent.transactions.map((tx) => tx.toJson()).toList());
    await prefs.setString('transactions', encodedData);
  }

  void _saveTransaction() {
    if (_amount != null && _transactionType != null && _selectedDate != null && _title != null) {
      String type = _transactionType == 'Income' ? 'profit' : 'expense';

      int nextId = GlobalContent.transactions.isNotEmpty
          ? GlobalContent.transactions.map((tx) => tx.id).reduce((a, b) => a > b ? a : b) + 1
          : 1;

      GlobalContent.transactions.add(Transaction(
        id: nextId,
        name: _title!,
        description: _description ?? '',
        price: _transactionType == "Income"
            ? _amount ?? 0.0
            : -(_amount ?? 0.0), // Make expense negative
        type: type,
        date: _selectedDate!,
      ));

      calculateTotal();
      _saveTransactions();
      _resetTransactionInputs();
    }
    setState(() {});
  }

  void calculateTotal() {
    List<Transaction> filteredTransactions = GlobalContent.transactions;

    if (currentMonth != null && currentYear != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return DateFormat('MMMM').format(transaction.date) == currentMonth &&
            transaction.date.year == currentYear;
      }).toList();
    }

    totalIncome = filteredTransactions
        .where((t) => t.type == 'profit')
        .fold(0.0, (sum, item) => sum + item.price);

    totalExpenses = filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.price);
  }

  void _resetTransactionInputs() {
    _amountController.clear();
    _dateController.clear();
    _titleController.clear();
    _descriptionController.clear();
    _amount = null;
    _transactionType = null;
    _selectedDate = null;
    _title = null;
    _description = null;
  }

  double calculateTotalPaidToday() {
    DateTime today = DateTime.now();
    return GlobalContent.transactions.where((tx) =>
    tx.date.year == today.year &&
        tx.date.month == today.month &&
        tx.date.day == today.day
    ).fold(0.0, (sum, current) => sum + current.price); // Positive for income, negative for expense
  }

  double calculateTotalOweThisMonth() {
    DateTime today = DateTime.now();
    return GlobalContent.transactions.where((tx) =>
    tx.date.year == today.year &&
        tx.date.month == today.month
    ).fold(0.0, (sum, current) => sum + current.price); // Positive for income, negative for expense
  }

  double calculateTotalDueLast12Months() {
    DateTime oneYearAgo = DateTime.now().subtract(Duration(days: 365));
    return GlobalContent.transactions.where((tx) =>
        tx.date.isAfter(oneYearAgo)
    ).fold(0.0, (sum, current) => sum + current.price); // Positive for income, negative for expense
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
