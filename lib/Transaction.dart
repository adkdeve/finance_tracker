String currentFilter = 'all';
String? currentMonth;
int? currentYear;

class Transaction {
  final int id;
  final String name;
  final String description;
  final double price;
  final String type; // "profit" or "expense"
  final DateTime date; // New property for transaction date

  Transaction({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.date, // Include the date in the constructor
  });
}

class GlobalContent {
  static List<Transaction> transactions = [
    Transaction(
      id: 1,
      name: 'Salary',
      description: 'Monthly salary received',
      price: 5000.0,
      type: 'profit',
      date: DateTime(2022, 1, 10), // Example date
    ),
    Transaction(
      id: 2,
      name: 'Groceries',
      description: 'Weekly grocery shopping',
      price: 200.0,
      type: 'expense',
      date: DateTime(2022, 1, 12), // Example date
    ),
    Transaction(
      id: 3,
      name: 'Electricity Bill',
      description: 'Monthly electricity bill payment',
      price: 150.0,
      type: 'expense',
      date: DateTime(2022, 1, 15), // Example date
    ),
    Transaction(
      id: 4,
      name: 'Freelance Project',
      description: 'Payment received for freelance work',
      price: 1200.0,
      type: 'profit',
      date: DateTime(2022, 1, 20), // Example date
    ),
    Transaction(
      id: 5,
      name: 'Dining Out',
      description: 'Dinner with friends',
      price: 75.0,
      type: 'expense',
      date: DateTime(2022, 1, 25), // Example date
    ),
    Transaction(
      id: 6,
      name: 'Online Course',
      description: 'Purchased an online course',
      price: 300.0,
      type: 'expense',
      date: DateTime(2022, 1, 27), // Example date
    ),
    Transaction(
      id: 7,
      name: 'Investment Return',
      description: 'Returns from recent investment',
      price: 800.0,
      type: 'profit',
      date: DateTime(2022, 2, 1), // Example date
    ),
    Transaction(
      id: 8,
      name: 'Gym Membership',
      description: 'Monthly gym membership fee',
      price: 50.0,
      type: 'expense',
      date: DateTime(2022, 2, 5), // Example date
    ),
    Transaction(
      id: 9,
      name: 'Bonus',
      description: 'Year-end bonus received',
      price: 2000.0,
      type: 'profit',
      date: DateTime(2022, 2, 10), // Example date
    ),
    Transaction(
      id: 10,
      name: 'Car Repair',
      description: 'Repairs for car maintenance',
      price: 400.0,
      type: 'expense',
      date: DateTime(2022, 2, 15), // Example date
    ),
    // Adding entries for September 2024
    Transaction(
      id: 11,
      name: 'Rent',
      description: 'Monthly rent payment',
      price: 1500.0,
      type: 'expense',
      date: DateTime(2024, 9, 1),
    ),
    Transaction(
      id: 12,
      name: 'Web Development Project',
      description: 'Payment for web development services',
      price: 2500.0,
      type: 'profit',
      date: DateTime(2024, 9, 10),
    ),
    Transaction(
      id: 13,
      name: 'Utilities',
      description: 'Monthly utility bill',
      price: 200.0,
      type: 'expense',
      date: DateTime(2024, 9, 15),
    ),
    // Adding entries for October 2024
    Transaction(
      id: 14,
      name: 'Salary',
      description: 'Monthly salary received',
      price: 5000.0,
      type: 'profit',
      date: DateTime(2024, 10, 1),
    ),
    Transaction(
      id: 15,
      name: 'Grocery Shopping',
      description: 'Weekly grocery shopping',
      price: 250.0,
      type: 'expense',
      date: DateTime(2024, 10, 5),
    ),
    Transaction(
      id: 16,
      name: 'Internet Bill',
      description: 'Monthly internet bill payment',
      price: 75.0,
      type: 'expense',
      date: DateTime(2024, 10, 10),
    ),
  ];
}

