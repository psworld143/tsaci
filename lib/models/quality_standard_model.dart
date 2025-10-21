class QualityStandard {
  final int? standardId;
  final int productId;
  final String productName;
  final Map<String, StandardRange> parameters;
  final DateTime effectiveFrom;

  QualityStandard({
    this.standardId,
    required this.productId,
    required this.productName,
    required this.parameters,
    required this.effectiveFrom,
  });

  factory QualityStandard.fromJson(Map<String, dynamic> json) {
    return QualityStandard(
      standardId: json['standard_id'],
      productId: _parseInt(json['product_id']),
      productName: json['product_name'] ?? '',
      parameters: _parseParameters(json['parameters']),
      effectiveFrom: DateTime.parse(
        json['effective_from'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (standardId != null) 'standard_id': standardId,
      'product_id': productId,
      'product_name': productName,
      'parameters': parameters.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'effective_from': effectiveFrom.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return double.parse(value.toString()).toInt();
  }

  static Map<String, StandardRange> _parseParameters(dynamic params) {
    if (params == null) return {};
    if (params is Map) {
      return params.map(
        (key, value) => MapEntry(
          key.toString(),
          StandardRange.fromJson(value as Map<String, dynamic>),
        ),
      );
    }
    return {};
  }

  // Default standards for common products
  static QualityStandard getDefault(int productId, String productName) {
    return QualityStandard(
      productId: productId,
      productName: productName,
      parameters: _getDefaultParameters(productName),
      effectiveFrom: DateTime.now(),
    );
  }

  static Map<String, StandardRange> _getDefaultParameters(String productName) {
    if (productName.toLowerCase().contains('coconut')) {
      return {
        'pH Level': StandardRange(
          parameterName: 'pH Level',
          minValue: 6.5,
          maxValue: 7.5,
          unit: 'pH',
        ),
        'Moisture Content': StandardRange(
          parameterName: 'Moisture Content',
          minValue: 0,
          maxValue: 5,
          unit: '%',
        ),
        'Ash Content': StandardRange(
          parameterName: 'Ash Content',
          minValue: 0,
          maxValue: 5,
          unit: '%',
        ),
        'Particle Size': StandardRange(
          parameterName: 'Particle Size',
          minValue: 1.5,
          maxValue: 3.0,
          unit: 'mm',
        ),
        'Iodine Number': StandardRange(
          parameterName: 'Iodine Number',
          minValue: 900,
          maxValue: 9999,
          unit: 'mg/g',
        ),
      };
    } else if (productName.toLowerCase().contains('rice')) {
      return {
        'pH Level': StandardRange(
          parameterName: 'pH Level',
          minValue: 6.0,
          maxValue: 7.0,
          unit: 'pH',
        ),
        'Moisture Content': StandardRange(
          parameterName: 'Moisture Content',
          minValue: 0,
          maxValue: 6,
          unit: '%',
        ),
        'Ash Content': StandardRange(
          parameterName: 'Ash Content',
          minValue: 0,
          maxValue: 8,
          unit: '%',
        ),
        'Particle Size': StandardRange(
          parameterName: 'Particle Size',
          minValue: 1.0,
          maxValue: 2.5,
          unit: 'mm',
        ),
        'Iodine Number': StandardRange(
          parameterName: 'Iodine Number',
          minValue: 850,
          maxValue: 9999,
          unit: 'mg/g',
        ),
      };
    }

    // Default generic standards
    return {
      'pH Level': StandardRange(
        parameterName: 'pH Level',
        minValue: 6.0,
        maxValue: 8.0,
        unit: 'pH',
      ),
      'Moisture Content': StandardRange(
        parameterName: 'Moisture Content',
        minValue: 0,
        maxValue: 5,
        unit: '%',
      ),
      'Ash Content': StandardRange(
        parameterName: 'Ash Content',
        minValue: 0,
        maxValue: 6,
        unit: '%',
      ),
    };
  }
}

class StandardRange {
  final String parameterName;
  final double minValue;
  final double maxValue;
  final String unit;

  StandardRange({
    required this.parameterName,
    required this.minValue,
    required this.maxValue,
    required this.unit,
  });

  factory StandardRange.fromJson(Map<String, dynamic> json) {
    return StandardRange(
      parameterName: json['parameter_name'] ?? '',
      minValue: _parseDouble(json['min_value']),
      maxValue: _parseDouble(json['max_value']),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameter_name': parameterName,
      'min_value': minValue,
      'max_value': maxValue,
      'unit': unit,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.parse(value.toString());
  }

  String get rangeText => '$minValue - $maxValue $unit';

  bool isInRange(double value) {
    return value >= minValue && value <= maxValue;
  }
}
