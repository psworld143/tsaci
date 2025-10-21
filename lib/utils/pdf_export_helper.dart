import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// PDF Export Helper for generating printable reports
class PDFExportHelper {
  /// Generate and save/print PDF report
  static Future<void> generateReport({
    required String title,
    required List<Map<String, dynamic>> data,
    List<String>? headers,
    String? subtitle,
    bool printDirectly = false,
  }) async {
    final pdf = pw.Document();

    // Add content to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(title, subtitle),
          pw.SizedBox(height: 20),
          _buildTable(data, headers),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    if (printDirectly) {
      // Print directly
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } else {
      // Save to file
      final bytes = await pdf.save();
      await _savePDF(bytes, title);
    }
  }

  /// Build PDF header
  static pw.Widget _buildHeader(String title, String? subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TSACI Plant Monitoring System',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green900,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        if (subtitle != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
        ],
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  /// Build PDF table
  static pw.Widget _buildTable(
    List<Map<String, dynamic>> data,
    List<String>? headers,
  ) {
    if (data.isEmpty) {
      return pw.Center(child: pw.Text('No data available'));
    }

    final columnHeaders = headers ?? data.first.keys.toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green100),
          children: columnHeaders
              .map(
                (header) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              )
              .toList(),
        ),
        // Data rows
        ...data.map(
          (row) => pw.TableRow(
            children: columnHeaders
                .map(
                  (header) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      row[header]?.toString() ?? '',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Build PDF footer
  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.Text(
          'Tupi Supreme Activated Carbon Plant',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.Text(
          'This is a computer-generated report',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
      ],
    );
  }

  /// Save PDF to file
  static Future<void> _savePDF(Uint8List bytes, String title) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename =
        '${title.toLowerCase().replaceAll(' ', '_')}_$timestamp.pdf';
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes);
  }

  /// Export users report
  static Future<void> exportUsersReport(List<dynamic> users) async {
    final data = users.map((user) {
      return {
        'ID': user['user_id'] ?? user['userId'] ?? '',
        'Name': user['name'] ?? '',
        'Email': user['email'] ?? '',
        'Role': user['role'] ?? '',
        'Created': user['created_at'] ?? user['createdAt'] ?? '',
      };
    }).toList();

    await generateReport(
      title: 'Users Report',
      subtitle: 'Complete list of system users',
      data: data,
    );
  }

  /// Export sales report
  static Future<void> exportSalesReport(
    List<dynamic> sales, {
    String? dateRange,
  }) async {
    final data = sales.map((sale) {
      return {
        'ID': sale['sale_id'] ?? '',
        'Customer': sale['customer_name'] ?? '',
        'Product': sale['product_name'] ?? '',
        'Qty': sale['quantity'] ?? '',
        'Price': sale['unit_price'] ?? '',
        'Total': sale['total_amount'] ?? '',
        'Status': sale['status'] ?? '',
        'Date': sale['date'] ?? '',
      };
    }).toList();

    await generateReport(
      title: 'Sales Report',
      subtitle: dateRange ?? 'All sales records',
      data: data,
    );
  }

  /// Export inventory report
  static Future<void> exportInventoryReport(List<dynamic> inventory) async {
    final data = inventory.map((item) {
      return {
        'Product': item['product_name'] ?? '',
        'Category': item['category'] ?? '',
        'Quantity': item['quantity'] ?? '',
        'Location': item['location'] ?? '',
        'Min Stock': item['minimum_threshold'] ?? '',
        'Status': (item['quantity'] ?? 0) <= (item['minimum_threshold'] ?? 0)
            ? 'Low Stock'
            : 'In Stock',
      };
    }).toList();

    await generateReport(
      title: 'Inventory Report',
      subtitle: 'Current stock levels',
      data: data,
    );
  }

  /// Export production report
  static Future<void> exportProductionReport(List<dynamic> production) async {
    final data = production.map((prod) {
      return {
        'ID': prod['production_id'] ?? '',
        'Product': prod['product_name'] ?? '',
        'Supervisor': prod['supervisor_name'] ?? '',
        'Input': prod['input_qty'] ?? '',
        'Output': prod['output_qty'] ?? '',
        'Efficiency': '${prod['efficiency'] ?? 0}%',
        'Date': prod['date'] ?? '',
      };
    }).toList();

    await generateReport(
      title: 'Production Report',
      subtitle: 'Production efficiency and output',
      data: data,
    );
  }

  /// Export expense report
  static Future<void> exportExpenseReport(
    List<dynamic> expenses, {
    String? dateRange,
  }) async {
    final data = expenses.map((expense) {
      return {
        'Category': expense['category'] ?? '',
        'Amount': expense['amount'] ?? '',
        'Date': expense['date'] ?? '',
        'Description': expense['description'] ?? '',
        'Department': expense['department'] ?? '',
      };
    }).toList();

    // Calculate total
    double total = 0;
    for (var expense in expenses) {
      total += double.tryParse(expense['amount'].toString()) ?? 0;
    }

    await generateReport(
      title: 'Expense Report',
      subtitle: '${dateRange ?? 'All expenses'} | Total: \$$total',
      data: data,
    );
  }

  /// Print report directly
  static Future<void> printReport({
    required String title,
    required List<Map<String, dynamic>> data,
    List<String>? headers,
  }) async {
    await generateReport(
      title: title,
      data: data,
      headers: headers,
      printDirectly: true,
    );
  }
}
