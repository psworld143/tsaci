class Production {
  final int productionId;
  final int productId;
  final int supervisorId;
  final double inputQty;
  final double outputQty;
  final String date;
  final String? notes;
  final String? productName;
  final String? supervisorName;

  Production({
    required this.productionId,
    required this.productId,
    required this.supervisorId,
    required this.inputQty,
    required this.outputQty,
    required this.date,
    this.notes,
    this.productName,
    this.supervisorName,
  });

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      productionId: json['production_id'],
      productId: json['product_id'],
      supervisorId: json['supervisor_id'],
      inputQty: _parseDouble(json['input_qty']),
      outputQty: _parseDouble(json['output_qty']),
      date: json['date'],
      notes: json['notes'],
      productName: json['product_name'],
      supervisorName: json['supervisor_name'],
    );
  }

  /// Safely parse double values
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.parse(value.toString());
  }

  double get efficiency => inputQty > 0 ? (outputQty / inputQty) * 100 : 0;
}
