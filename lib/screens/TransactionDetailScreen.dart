import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/Transaction.dart';
import 'package:toastification/toastification.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;
  final VoidCallback? onTransactionUpdated;
  final VoidCallback onTransactionDeleted;

  const TransactionDetailScreen({
    Key? key,
    required this.transactionId,
    required this.onTransactionDeleted,
    this.onTransactionUpdated,
  }) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final transaction = GlobalContent.transactions.firstWhere(
          (t) => t.id == widget.transactionId,
      orElse: () => Transaction(
        id: -1,
        name: '',
        description: '',
        price: 0.0,
        type: '',
        date: DateTime.now(),
      ),
    );

    if (transaction.id == -1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Transaction Not Found'),
          backgroundColor: Colors.redAccent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'No transaction found with this ID.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          transaction.name,
          style: TextStyle(color: Colors.white),  // Change text color to white
        ),
        backgroundColor: Colors.teal,  // Keep the original AppBar background color
        elevation: 5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),  // Change back button icon color to white
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Transaction Details',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade700),
              ),
              const SizedBox(height: 20),
              _buildTransactionCard(transaction),
              const SizedBox(height: 30),
              _buildActionButtons(transaction),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Title:', transaction.name),
            const SizedBox(height: 12),
            SingleChildScrollView( // Make the description scrollable
              child: _buildDetailRow('Description:', transaction.description),
            ),
            const SizedBox(height: 12),
            _buildAmountRow(transaction),
            const SizedBox(height: 12),
            _buildDetailRow('Type:', transaction.type),
            const SizedBox(height: 12),
            _buildDetailRow('Date:', DateFormat('dd MMM yyyy').format(transaction.date)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.7)),
            overflow: TextOverflow.visible,  // This will allow text to expand
            maxLines: null,  // Allow the description to take up more space as needed
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(Transaction transaction) {
    return Row(
      children: [
        Text(
          'Amount:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
        ),
        const SizedBox(width: 8),
        Text(
          'Rs.${transaction.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            color: transaction.type.toLowerCase() == 'expense' ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Transaction transaction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          label: 'Update',
          color: Colors.blueAccent,
          icon: Icons.edit,
          onPressed: () => _showUpdateDialog(transaction),
        ),
        _buildActionButton(
          label: 'Delete',
          color: Colors.redAccent,
          icon: Icons.delete_forever,
          onPressed: () => _deleteTransaction(transaction.id),
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required Color color, required IconData icon, required VoidCallback onPressed}) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  void _showUpdateDialog(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return UpdateTransactionDialog(
          transaction: transaction,
          onUpdate: () async {
            await _saveTransactionsToLocalStorage();
            setState(() {});
            if (widget.onTransactionUpdated != null) {
              widget.onTransactionUpdated!();
            }
            _showSnackbar('Transaction updated successfully!');
          },
        );
      },
    );
  }

  void _deleteTransaction(int transactionId) async {
    widget.onTransactionDeleted();
    Navigator.pop(context);
    setState(() {
      GlobalContent.transactions.removeWhere((t) => t.id == transactionId);
    });
    await _saveTransactionsToLocalStorage();
    _showSnackbar('Transaction deleted successfully!');
  }

  Future<void> _saveTransactionsToLocalStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(GlobalContent.transactions.map((tx) => tx.toJson()).toList());
    await prefs.setString('transactions', encodedData);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class UpdateTransactionDialog extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback onUpdate;

  const UpdateTransactionDialog({
    Key? key,
    required this.transaction,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _UpdateTransactionDialogState createState() => _UpdateTransactionDialogState();
}

class _UpdateTransactionDialogState extends State<UpdateTransactionDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController amountController;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.transaction.name);
    descriptionController = TextEditingController(text: widget.transaction.description);
    amountController = TextEditingController(text: widget.transaction.price.toString());
    selectedIndex = widget.transaction.type == 'profit' ? 0 : 1;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update Transaction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              ToggleButtons(
                isSelected: [selectedIndex == 0, selectedIndex == 1],
                onPressed: (int index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Income'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Expense'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      try {
                        final updatedTransaction = Transaction(
                          id: widget.transaction.id,
                          name: titleController.text,
                          description: descriptionController.text,
                          price: double.tryParse(amountController.text) ?? widget.transaction.price,
                          type: selectedIndex == 0 ? 'profit' : 'expense',
                          date: widget.transaction.date,
                        );

                        setState(() {
                          int index = GlobalContent.transactions.indexWhere((t) => t.id == widget.transaction.id);
                          if (index != -1) {
                            GlobalContent.transactions[index] = updatedTransaction;
                            toastification.show(
                              context: context,
                              type: ToastificationType.success,
                              style: ToastificationStyle.flat,
                              title: const Text('Success'),
                              description: const Text('Transaction updated successfully.'),
                              autoCloseDuration: const Duration(seconds: 3),
                              alignment: Alignment.topRight,
                            );
                          } else {
                            toastification.show(
                              context: context,
                              type: ToastificationType.error,
                              style: ToastificationStyle.flat,
                              title: const Text('Failure'),
                              description: const Text('Transaction not found.'),
                              autoCloseDuration: const Duration(seconds: 3),
                              alignment: Alignment.topRight,
                            );
                          }
                        });

                        widget.onUpdate();
                        Navigator.of(context).pop();
                      } catch (e) {
                        toastification.show(
                          context: context,
                          type: ToastificationType.error,
                          style: ToastificationStyle.flat,
                          title: const Text('Error'),
                          description: const Text('Failed to update transaction. Please try again.'),
                          autoCloseDuration: const Duration(seconds: 3),
                          alignment: Alignment.topRight,
                        );
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}