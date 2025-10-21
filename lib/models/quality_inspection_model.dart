class QualityInspection {
  final int? inspectionId;
  final int batchId;
  final String batchNumber;
  final String productName;
  final int inspectorId;
  final String inspectorName;
  final DateTime inspectionDate;
  final Map<String, TestResult> tests;
  final String status; // pending, approved, rejected, conditional
  final String? remarks;
  final List<Defect> defects;
  final DateTime createdAt;
  final DateTime? updatedAt;

  QualityInspection({
    this.inspectionId,
    required this.batchId,
    required this.batchNumber,
    required this.productName,
    required this.inspectorId,
    required this.inspectorName,
    required this.inspectionDate,
    required this.tests,
    required this.status,
    this.remarks,
    required this.defects,
    required this.createdAt,
    this.updatedAt,
  });

  factory QualityInspection.fromJson(Map<String, dynamic> json) {
    return QualityInspection(
      inspectionId: json['inspection_id'],
      batchId: _parseInt(json['batch_id']),
      batchNumber: json['batch_number'] ?? '',
      productName: json['product_name'] ?? '',
      inspectorId: _parseInt(json['inspector_id']),
      inspectorName: json['inspector_name'] ?? '',
      inspectionDate: DateTime.parse(
        json['inspection_date'] ?? DateTime.now().toIso8601String(),
      ),
      tests: _parseTests(json['tests']),
      status: json['status'] ?? 'pending',
      remarks: json['remarks'],
      defects: _parseDefects(json['defects']),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (inspectionId != null) 'inspection_id': inspectionId,
      'batch_id': batchId,
      'batch_number': batchNumber,
      'product_name': productName,
      'inspector_id': inspectorId,
      'inspector_name': inspectorName,
      'inspection_date': inspectionDate.toIso8601String(),
      'tests': tests.map((key, value) => MapEntry(key, value.toJson())),
      'status': status,
      if (remarks != null) 'remarks': remarks,
      'defects': defects.map((d) => d.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return double.parse(value.toString()).toInt();
  }

  static Map<String, TestResult> _parseTests(dynamic tests) {
    if (tests == null) return {};
    if (tests is Map) {
      return tests.map(
        (key, value) => MapEntry(
          key.toString(),
          TestResult.fromJson(value as Map<String, dynamic>),
        ),
      );
    }
    return {};
  }

  static List<Defect> _parseDefects(dynamic defects) {
    if (defects == null) return [];
    if (defects is List) {
      return defects
          .map((d) => Defect.fromJson(d as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isPending => status == 'pending';
  bool get allTestsPassed => tests.values.every((test) => test.passed);
  int get defectCount => defects.length;
  int get criticalDefects =>
      defects.where((d) => d.severity == 'critical').length;
}

class TestResult {
  final String testName;
  final double measuredValue;
  final double minStandard;
  final double maxStandard;
  final String unit;
  final bool passed;

  TestResult({
    required this.testName,
    required this.measuredValue,
    required this.minStandard,
    required this.maxStandard,
    required this.unit,
    required this.passed,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    final measured = _parseDouble(json['measured_value']);
    final min = _parseDouble(json['min_standard']);
    final max = _parseDouble(json['max_standard']);
    final passed = measured >= min && measured <= max;

    return TestResult(
      testName: json['test_name'] ?? '',
      measuredValue: measured,
      minStandard: min,
      maxStandard: max,
      unit: json['unit'] ?? '',
      passed: json['passed'] ?? passed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_name': testName,
      'measured_value': measuredValue,
      'min_standard': minStandard,
      'max_standard': maxStandard,
      'unit': unit,
      'passed': passed,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.parse(value.toString());
  }

  String get statusText => passed ? 'PASS' : 'FAIL';
  String get rangeText => '$minStandard - $maxStandard $unit';
}

class Defect {
  final int? defectId;
  final int? inspectionId;
  final String defectType;
  final String severity; // critical, major, minor, cosmetic
  final String description;
  final String? correctiveAction;
  final String status; // open, resolved, pending
  final DateTime reportedAt;

  Defect({
    this.defectId,
    this.inspectionId,
    required this.defectType,
    required this.severity,
    required this.description,
    this.correctiveAction,
    required this.status,
    required this.reportedAt,
  });

  factory Defect.fromJson(Map<String, dynamic> json) {
    return Defect(
      defectId: json['defect_id'],
      inspectionId: json['inspection_id'],
      defectType: json['defect_type'] ?? '',
      severity: json['severity'] ?? 'minor',
      description: json['description'] ?? '',
      correctiveAction: json['corrective_action'],
      status: json['status'] ?? 'open',
      reportedAt: DateTime.parse(
        json['reported_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (defectId != null) 'defect_id': defectId,
      if (inspectionId != null) 'inspection_id': inspectionId,
      'defect_type': defectType,
      'severity': severity,
      'description': description,
      if (correctiveAction != null) 'corrective_action': correctiveAction,
      'status': status,
      'reported_at': reportedAt.toIso8601String(),
    };
  }

  bool get isCritical => severity == 'critical';
  bool get isOpen => status == 'open';
  bool get isResolved => status == 'resolved';
}
