class ExpenseModel {
  final int expenseId;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;
  final String? department;
  final DateTime createdAt;

  ExpenseModel({
    required this.expenseId,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    this.department,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      expenseId: _parseInt(json['expense_id']),
      category: json['category'] ?? '',
      amount: _parseDouble(json['amount']),
      date: DateTime.parse(json['date']),
      description: json['description'],
      department: json['department'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Safely parse integer values (handles both int and double from JSON)
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return double.parse(value.toString()).toInt();
  }

  /// Safely parse double values
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.parse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'department': department,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
