String currentFilter = 'all';
String? currentMonth;
int? currentYear;
String? displayMonth;


class Transaction {
  int id;
  String name;
  String description;
  double price;
  String type;
  DateTime date;

  Transaction({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      type: json['type'],
      date: DateTime.parse(json['date']),
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, name: $name, description: $description, price: $price, type: $type, date: $date)';
  }
}

class GlobalContent {
  static List<Transaction> transactions = [
  ];
}

