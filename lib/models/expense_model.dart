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
      expenseId: int.parse(json['expense_id'].toString()),
      category: json['category'] ?? '',
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
      description: json['description'],
      department: json['department'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
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
