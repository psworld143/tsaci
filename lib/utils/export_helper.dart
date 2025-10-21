import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

/// Export Helper - CSV, Excel, and PDF export utilities
class ExportHelper {
  /// Export data to CSV format
  static Future<String?> exportToCSV({
    required List<Map<String, dynamic>> data,
    required String filename,
    List<String>? headers,
  }) async {
    if (data.isEmpty) {
      throw Exception('No data to export');
    }

    // Generate CSV content
    final csv = _generateCSV(data, headers);

    // Save based on platform
    if (kIsWeb) {
      return _downloadWebCSV(csv, filename);
    } else {
      return _saveMobileCSV(csv, filename);
    }
  }

  /// Generate CSV string from data
  static String _generateCSV(
    List<Map<String, dynamic>> data,
    List<String>? headers,
  ) {
    final buffer = StringBuffer();

    // Use provided headers or extract from first row
    final columnHeaders = headers ?? data.first.keys.toList();

    // Add headers
    buffer.writeln(columnHeaders.map((h) => _escapeCSV(h)).join(','));

    // Add data rows
    for (var row in data) {
      final values = columnHeaders
          .map((header) {
            final value = row[header]?.toString() ?? '';
            return _escapeCSV(value);
          })
          .join(',');
      buffer.writeln(values);
    }

    return buffer.toString();
  }

  /// Escape CSV values (handle commas, quotes, newlines)
  static String _escapeCSV(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Download CSV for web platform
  static String? _downloadWebCSV(String csvContent, String filename) {
    try {
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
        ..setAttribute('download', '$filename.csv')
        ..click();

      html.Url.revokeObjectUrl(url);
      return filename;
    } catch (e) {
      throw Exception('Failed to download CSV: $e');
    }
  }

  /// Save CSV for mobile/desktop platforms
  static Future<String> _saveMobileCSV(
    String csvContent,
    String filename,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename.csv');
      await file.writeAsString(csvContent);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save CSV: $e');
    }
  }

  /// Export users to CSV
  static Future<String?> exportUsers(List<dynamic> users) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'users_export_$timestamp';

    final data = users.map((user) {
      return {
        'ID': user['user_id'] ?? user['userId'] ?? '',
        'Name': user['name'] ?? '',
        'Email': user['email'] ?? '',
        'Role': user['role'] ?? '',
        'Created At': user['created_at'] ?? user['createdAt'] ?? '',
      };
    }).toList();

    return await exportToCSV(data: data, filename: filename);
  }

  /// Export products to CSV
  static Future<String?> exportProducts(List<dynamic> products) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'products_export_$timestamp';

    final data = products.map((product) {
      return {
        'ID': product['product_id'] ?? product['productId'] ?? '',
        'Name': product['name'] ?? '',
        'Category': product['category'] ?? '',
        'Price': product['price'] ?? '',
        'Unit': product['unit'] ?? '',
      };
    }).toList();

    return await exportToCSV(data: data, filename: filename);
  }

  /// Export inventory to CSV
  static Future<String?> exportInventory(List<dynamic> inventory) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'inventory_export_$timestamp';

    final data = inventory.map((item) {
      return {
        'ID': item['inventory_id'] ?? item['inventoryId'] ?? '',
        'Product': item['product_name'] ?? item['productName'] ?? '',
        'Category': item['category'] ?? '',
        'Quantity': item['quantity'] ?? '',
        'Location': item['location'] ?? '',
        'Min Threshold':
            item['minimum_threshold'] ?? item['minimumThreshold'] ?? '',
        'Status':
            (item['quantity'] ?? 0) <=
                (item['minimum_threshold'] ?? item['minimumThreshold'] ?? 0)
            ? 'Low Stock'
            : 'In Stock',
      };
    }).toList();

    return await exportToCSV(data: data, filename: filename);
  }

  /// Export sales to CSV
  static Future<String?> exportSales(List<dynamic> sales) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'sales_export_$timestamp';

    final data = sales.map((sale) {
      return {
        'ID': sale['sale_id'] ?? sale['saleId'] ?? '',
        'Customer': sale['customer_name'] ?? sale['customerName'] ?? '',
        'Product': sale['product_name'] ?? sale['productName'] ?? '',
        'Quantity': sale['quantity'] ?? '',
        'Unit Price': sale['unit_price'] ?? sale['unitPrice'] ?? '',
        'Total Amount': sale['total_amount'] ?? sale['totalAmount'] ?? '',
        'Status': sale['status'] ?? '',
        'Date': sale['date'] ?? '',
      };
    }).toList();

    return await exportToCSV(data: data, filename: filename);
  }

  /// Export expenses to CSV
  static Future<String?> exportExpenses(List<dynamic> expenses) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'expenses_export_$timestamp';

    final data = expenses.map((expense) {
      return {
        'ID': expense['expense_id'] ?? expense['expenseId'] ?? '',
        'Category': expense['category'] ?? '',
        'Amount': expense['amount'] ?? '',
        'Date': expense['date'] ?? '',
        'Description': expense['description'] ?? '',
        'Department': expense['department'] ?? '',
      };
    }).toList();

    return await exportToCSV(data: data, filename: filename);
  }

  /// Export production data to CSV
  static Future<String?> exportProduction(List<dynamic> production) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'production_export_$timestamp';

    final data = production.map((prod) {
      return {
        'ID': prod['production_id'] ?? prod['productionId'] ?? '',
        'Product': prod['product_name'] ?? prod['productName'] ?? '',
        'Supervisor': prod['supervisor_name'] ?? prod['supervisorName'] ?? '',
        'Input Qty': prod['input_qty'] ?? prod['inputQty'] ?? '',
        'Output Qty': prod['output_qty'] ?? prod['outputQty'] ?? '',
        'Efficiency %': prod['efficiency'] ?? _calculateEfficiency(prod) ?? '',
        'Date': prod['date'] ?? '',
        'Notes': prod['notes'] ?? '',
      };
    }).toList();

    return await exportToCSV(data: data, filename: filename);
  }

  static String _calculateEfficiency(dynamic prod) {
    try {
      final input = double.parse(
        (prod['input_qty'] ?? prod['inputQty'] ?? 0).toString(),
      );
      final output = double.parse(
        (prod['output_qty'] ?? prod['outputQty'] ?? 0).toString(),
      );
      if (input > 0) {
        return ((output / input) * 100).toStringAsFixed(2);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return '0';
  }

  /// Export report data with custom formatting
  static Future<String?> exportReport({
    required String reportName,
    required Map<String, dynamic> reportData,
  }) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename =
        '${reportName.toLowerCase().replaceAll(' ', '_')}_$timestamp';

    // Convert report data to CSV-friendly format
    final List<Map<String, dynamic>> data = [];

    // Add summary section
    if (reportData.containsKey('summary')) {
      final summary = reportData['summary'] as Map<String, dynamic>;
      summary.forEach((key, value) {
        data.add({'Metric': key, 'Value': value.toString()});
      });
    }

    return await exportToCSV(data: data, filename: filename);
  }
}
