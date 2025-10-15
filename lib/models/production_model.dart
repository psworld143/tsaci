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
      inputQty: double.parse(json['input_qty'].toString()),
      outputQty: double.parse(json['output_qty'].toString()),
      date: json['date'],
      notes: json['notes'],
      productName: json['product_name'],
      supervisorName: json['supervisor_name'],
    );
  }

  double get efficiency => inputQty > 0 ? (outputQty / inputQty) * 100 : 0;
}
