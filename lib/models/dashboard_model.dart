class DashboardData {
  final TodayData today;
  final MonthlyData monthly;
  final TopProduct? topProduct;
  final AlertsData alerts;

  DashboardData({
    required this.today,
    required this.monthly,
    this.topProduct,
    required this.alerts,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      today: TodayData.fromJson(json['today']),
      monthly: MonthlyData.fromJson(json['monthly']),
      topProduct: json['top_product'] != null
          ? TopProduct.fromJson(json['top_product'])
          : null,
      alerts: AlertsData.fromJson(json['alerts']),
    );
  }
}

class TodayData {
  final String date;
  final int productionLogs;

  TodayData({required this.date, required this.productionLogs});

  factory TodayData.fromJson(Map<String, dynamic> json) {
    return TodayData(
      date: json['date'],
      productionLogs: json['production_logs'],
    );
  }
}

class MonthlyData {
  final double totalSales;
  final double totalExpenses;
  final double netIncome;

  MonthlyData({
    required this.totalSales,
    required this.totalExpenses,
    required this.netIncome,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalExpenses: (json['total_expenses'] ?? 0).toDouble(),
      netIncome: (json['net_income'] ?? 0).toDouble(),
    );
  }
}

class TopProduct {
  final String name;
  final double quantitySold;
  final double totalSales;

  TopProduct({
    required this.name,
    required this.quantitySold,
    required this.totalSales,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      name: json['name'],
      quantitySold: (json['quantity_sold'] ?? 0).toDouble(),
      totalSales: (json['total_sales'] ?? 0).toDouble(),
    );
  }
}

class AlertsData {
  final int lowStockCount;

  AlertsData({required this.lowStockCount});

  factory AlertsData.fromJson(Map<String, dynamic> json) {
    return AlertsData(lowStockCount: json['low_stock_count'] ?? 0);
  }
}
