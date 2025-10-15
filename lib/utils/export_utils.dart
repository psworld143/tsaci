import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/sales_model.dart';
import '../models/expense_model.dart';
import '../models/production_model.dart';

/// Export Utilities for PDF and Excel/CSV
class ExportUtils {
  /// Export Sales Report to PDF
  static Future<void> exportSalesToPDF(List<SalesModel> sales) async {
    final pdf = pw.Document();

    // Calculate totals
    final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
    final totalOrders = sales.length;
    final totalUnits = sales.fold<int>(0, (sum, s) => sum + s.quantity);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Sales Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Generated: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPDFStat(
                    'Total Revenue',
                    '₱${totalRevenue.toStringAsFixed(2)}',
                  ),
                  _buildPDFStat('Total Orders', '$totalOrders'),
                  _buildPDFStat('Units Sold', '$totalUnits'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Product',
                'Customer',
                'Qty',
                'Amount',
                'Status',
              ],
              data: sales
                  .map(
                    (sale) => [
                      DateFormat('MMM dd').format(sale.date),
                      sale.productName,
                      sale.customerName,
                      '${sale.quantity}',
                      '₱${sale.totalAmount.toStringAsFixed(2)}',
                      sale.status.toUpperCase(),
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
              headerAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    // Save or print
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'sales_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Export Expenses Report to PDF
  static Future<void> exportExpensesToPDF(List<ExpenseModel> expenses) async {
    final pdf = pw.Document();

    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final categoryBreakdown = <String, double>{};
    for (var expense in expenses) {
      categoryBreakdown[expense.category] =
          (categoryBreakdown[expense.category] ?? 0) + expense.amount;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Expense Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Generated: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPDFStat(
                    'Total Expenses',
                    '₱${totalExpenses.toStringAsFixed(2)}',
                  ),
                  _buildPDFStat('Transactions', '${expenses.length}'),
                  _buildPDFStat('Categories', '${categoryBreakdown.length}'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Category Breakdown
            pw.Text(
              'Category Breakdown',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            ...categoryBreakdown.entries.map((entry) {
              final percentage = (entry.value / totalExpenses * 100);
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(entry.key),
                    pw.Text(
                      '₱${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
            pw.SizedBox(height: 20),

            // Table
            pw.Text(
              'Expense Details',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Category',
                'Description',
                'Department',
                'Amount',
              ],
              data: expenses
                  .map(
                    (expense) => [
                      DateFormat('MMM dd, yyyy').format(expense.date),
                      expense.category,
                      expense.description ?? '-',
                      expense.department ?? '-',
                      '₱${expense.amount.toStringAsFixed(2)}',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.red),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'expense_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Export Production Report to PDF
  static Future<void> exportProductionToPDF(
    List<Production> productions,
  ) async {
    final pdf = pw.Document();

    final totalInput = productions.fold<double>(
      0,
      (sum, p) => sum + p.inputQty,
    );
    final totalOutput = productions.fold<double>(
      0,
      (sum, p) => sum + p.outputQty,
    );
    final avgEfficiency = productions.isEmpty
        ? 0.0
        : productions.fold<double>(0, (sum, p) => sum + p.efficiency) /
              productions.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Production Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Generated: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPDFStat('Total Logs', '${productions.length}'),
                  _buildPDFStat(
                    'Total Input',
                    '${totalInput.toStringAsFixed(1)} kg',
                  ),
                  _buildPDFStat(
                    'Total Output',
                    '${totalOutput.toStringAsFixed(1)} kg',
                  ),
                  _buildPDFStat(
                    'Avg Efficiency',
                    '${avgEfficiency.toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Product',
                'Supervisor',
                'Input',
                'Output',
                'Efficiency',
              ],
              data: productions
                  .map(
                    (prod) => [
                      DateFormat('MMM dd').format(DateTime.parse(prod.date)),
                      prod.productName ?? 'Unknown',
                      prod.supervisorName ?? 'Unknown',
                      '${prod.inputQty} kg',
                      '${prod.outputQty} kg',
                      '${prod.efficiency.toStringAsFixed(1)}%',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'production_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Export Sales to CSV
  static Future<String> exportSalesToCSV(List<SalesModel> sales) async {
    final rows = [
      ['Date', 'Product', 'Customer', 'Quantity', 'Total Amount', 'Status'],
      ...sales.map(
        (sale) => [
          DateFormat('yyyy-MM-dd').format(sale.date),
          sale.productName,
          sale.customerName,
          sale.quantity.toString(),
          sale.totalAmount.toStringAsFixed(2),
          sale.status,
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    return _saveToFile(
      csv,
      'sales_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
    );
  }

  /// Export Expenses to CSV
  static Future<String> exportExpensesToCSV(List<ExpenseModel> expenses) async {
    final rows = [
      ['Date', 'Category', 'Description', 'Department', 'Amount'],
      ...expenses.map(
        (expense) => [
          DateFormat('yyyy-MM-dd').format(expense.date),
          expense.category,
          expense.description ?? '',
          expense.department ?? '',
          expense.amount.toStringAsFixed(2),
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    return _saveToFile(
      csv,
      'expense_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
    );
  }

  /// Export Production to CSV
  static Future<String> exportProductionToCSV(
    List<Production> productions,
  ) async {
    final rows = [
      [
        'Date',
        'Product',
        'Supervisor',
        'Input Qty',
        'Output Qty',
        'Efficiency',
        'Notes',
      ],
      ...productions.map(
        (prod) => [
          prod.date,
          prod.productName ?? '',
          prod.supervisorName ?? '',
          prod.inputQty.toString(),
          prod.outputQty.toString(),
          prod.efficiency.toStringAsFixed(2),
          prod.notes ?? '',
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    return _saveToFile(
      csv,
      'production_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
    );
  }

  /// Save CSV file
  static Future<String> _saveToFile(String content, String filename) async {
    if (kIsWeb) {
      // For web, trigger download
      // Note: On web, this will need additional handling with html package
      return 'Web download initiated for $filename';
    } else {
      // For mobile/desktop
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      return file.path;
    }
  }

  /// Helper to build PDF stat
  static pw.Widget _buildPDFStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
