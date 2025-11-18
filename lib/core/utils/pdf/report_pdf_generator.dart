import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/business.dart';
import '../../../domain/entities/reports.dart';
import '../currency_utils.dart';
import '../date_utils.dart';

/// PDF generator for business reports
class ReportPdfGenerator {
  ReportPdfGenerator._();

  /// Generate Ledger Report PDF
  static Future<File> generateLedgerPdf({
    required Business business,
    required LedgerReport report,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(business, 'LEDGER REPORT'),
          pw.SizedBox(height: 10),
          _buildCustomerInfo(report.customerName),
          pw.SizedBox(height: 10),
          _buildDateRange(report.startDate, report.endDate),
          pw.SizedBox(height: 20),
          _buildLedgerTable(report),
          pw.SizedBox(height: 20),
          _buildLedgerSummary(report),
        ],
      ),
    );

    return await _saveFile(pdf, 'Ledger_${report.customerName}');
  }

  /// Generate Daybook Report PDF
  static Future<File> generateDaybookPdf({
    required Business business,
    required DaybookReport report,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(business, 'DAYBOOK REPORT'),
          pw.SizedBox(height: 10),
          _buildSingleDate(report.date),
          pw.SizedBox(height: 20),
          _buildDaybookTable(report),
          pw.SizedBox(height: 20),
          _buildDaybookSummary(report),
        ],
      ),
    );

    final dateStr = AppDateUtils.formatDate(report.date);
    return await _saveFile(pdf, 'Daybook_$dateStr');
  }

  /// Generate Profit & Loss Report PDF
  static Future<File> generateProfitLossPdf({
    required Business business,
    required ProfitLossReport report,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(business, 'PROFIT & LOSS STATEMENT'),
          pw.SizedBox(height: 10),
          _buildDateRange(report.startDate, report.endDate),
          pw.SizedBox(height: 20),
          _buildProfitLossTable(report),
          pw.SizedBox(height: 20),
          _buildExpenseBreakdown(report.expensesByCategory),
        ],
      ),
    );

    return await _saveFile(pdf, 'ProfitLoss');
  }

  /// Generate Balance Sheet Report PDF
  static Future<File> generateBalanceSheetPdf({
    required Business business,
    required BalanceSheetReport report,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(business, 'BALANCE SHEET'),
          pw.SizedBox(height: 10),
          _buildAsOfDate(report.asOfDate),
          pw.SizedBox(height: 20),
          _buildBalanceSheetTable(report),
        ],
      ),
    );

    return await _saveFile(pdf, 'BalanceSheet');
  }

  /// Build header
  static pw.Widget _buildHeader(Business business, String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          business.name,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        if (business.address != null)
          pw.Text(business.address!, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Build customer info
  static pw.Widget _buildCustomerInfo(String customerName) {
    return pw.Row(
      children: [
        pw.Text('Customer: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(customerName),
      ],
    );
  }

  /// Build date range
  static pw.Widget _buildDateRange(int startDate, int endDate) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Period: ${AppDateUtils.formatDate(startDate)} to ${AppDateUtils.formatDate(endDate)}'),
        pw.Text('Generated: ${AppDateUtils.formatDate(DateTime.now().millisecondsSinceEpoch ~/ 1000)}'),
      ],
    );
  }

  /// Build single date
  static pw.Widget _buildSingleDate(int date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Date: ${AppDateUtils.formatDate(date)}'),
        pw.Text('Generated: ${AppDateUtils.formatDate(DateTime.now().millisecondsSinceEpoch ~/ 1000)}'),
      ],
    );
  }

  /// Build as of date
  static pw.Widget _buildAsOfDate(int date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('As of: ${AppDateUtils.formatDate(date)}'),
        pw.Text('Generated: ${AppDateUtils.formatDate(DateTime.now().millisecondsSinceEpoch ~/ 1000)}'),
      ],
    );
  }

  /// Build ledger table
  static pw.Widget _buildLedgerTable(LedgerReport report) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildCell('Date'),
            _buildCell('Type'),
            _buildCell('Description'),
            _buildCell('You Gave', align: pw.TextAlign.right),
            _buildCell('You Got', align: pw.TextAlign.right),
            _buildCell('Balance', align: pw.TextAlign.right),
          ],
        ),
        // Opening balance
        pw.TableRow(
          children: [
            _buildCell(''),
            _buildCell(''),
            _buildCell('Opening Balance', bold: true),
            _buildCell(''),
            _buildCell(''),
            _buildCell(CurrencyUtils.formatCurrency(report.openingBalance), align: pw.TextAlign.right),
          ],
        ),
        // Transactions
        ...report.transactions.map((txn) {
          final isCredit = txn.transactionType == 'CREDIT';
          return pw.TableRow(
            children: [
              _buildCell(AppDateUtils.formatDate(txn.transactionDate)),
              _buildCell(isCredit ? 'Credit' : 'Debit'),
              _buildCell(txn.description ?? '-'),
              _buildCell(isCredit ? CurrencyUtils.formatCurrency(txn.amount) : '-', align: pw.TextAlign.right),
              _buildCell(!isCredit ? CurrencyUtils.formatCurrency(txn.amount) : '-', align: pw.TextAlign.right),
              _buildCell('', align: pw.TextAlign.right),
            ],
          );
        }),
      ],
    );
  }

  /// Build ledger summary
  static pw.Widget _buildLedgerSummary(LedgerReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          _buildSummaryRow('Total You Gave:', report.totalCredit),
          _buildSummaryRow('Total You Got:', report.totalDebit),
          pw.Divider(),
          _buildSummaryRow('Closing Balance:', report.closingBalance, bold: true),
        ],
      ),
    );
  }

  /// Build daybook table
  static pw.Widget _buildDaybookTable(DaybookReport report) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildCell('Time'),
            _buildCell('Customer'),
            _buildCell('Type'),
            _buildCell('You Gave', align: pw.TextAlign.right),
            _buildCell('You Got', align: pw.TextAlign.right),
          ],
        ),
        // Transactions
        ...report.transactions.map((txn) {
          final isCredit = txn.transactionType == 'CREDIT';
          return pw.TableRow(
            children: [
              _buildCell(AppDateUtils.formatTime(txn.createdAt)),
              _buildCell('Customer ${txn.customerId}'), // TODO: Add customer name
              _buildCell(isCredit ? 'Credit' : 'Debit'),
              _buildCell(isCredit ? CurrencyUtils.formatCurrency(txn.amount) : '-', align: pw.TextAlign.right),
              _buildCell(!isCredit ? CurrencyUtils.formatCurrency(txn.amount) : '-', align: pw.TextAlign.right),
            ],
          );
        }),
      ],
    );
  }

  /// Build daybook summary
  static pw.Widget _buildDaybookSummary(DaybookReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          _buildSummaryRow('Total Transactions:', report.transactionCount.toDouble(), isCount: true),
          _buildSummaryRow('Total You Gave:', report.totalCredit),
          _buildSummaryRow('Total You Got:', report.totalDebit),
          pw.Divider(),
          _buildSummaryRow('Net Cash Flow:', report.netCashFlow, bold: true),
        ],
      ),
    );
  }

  /// Build profit & loss table
  static pw.Widget _buildProfitLossTable(ProfitLossReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('INCOME', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          _buildSummaryRow('Total Revenue:', report.totalRevenue),
          pw.SizedBox(height: 10),
          pw.Text('EXPENSES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          _buildSummaryRow('Total Expenses:', report.totalExpenses),
          pw.SizedBox(height: 10),
          pw.Divider(thickness: 2),
          _buildSummaryRow('Gross Profit:', report.grossProfit, bold: true),
          _buildSummaryRow('Net Profit:', report.netProfit, bold: true),
          _buildSummaryRow('Profit Margin:', report.profitMargin, suffix: '%', bold: true),
        ],
      ),
    );
  }

  /// Build expense breakdown
  static pw.Widget _buildExpenseBreakdown(Map<String, double> expenses) {
    if (expenses.isEmpty) return pw.SizedBox();

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('EXPENSE BREAKDOWN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          ...expenses.entries.map((entry) => _buildSummaryRow(entry.key, entry.value)),
        ],
      ),
    );
  }

  /// Build balance sheet table
  static pw.Widget _buildBalanceSheetTable(BalanceSheetReport report) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Assets
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ASSETS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                _buildSummaryRow('Cash in Hand:', report.cashInHand),
                _buildSummaryRow('Receivables:', report.totalReceivable),
                _buildSummaryRow('Inventory:', report.inventoryValue),
                pw.Divider(),
                _buildSummaryRow('Total Assets:', report.totalAssets, bold: true),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 20),
        // Liabilities
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('LIABILITIES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                _buildSummaryRow('Payables:', report.totalPayable),
                pw.Divider(),
                _buildSummaryRow('Total Liabilities:', report.totalLiabilities, bold: true),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 2),
                _buildSummaryRow('Net Worth:', report.netWorth, bold: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildCell(String text, {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
        textAlign: align,
      ),
    );
  }

  /// Build summary row
  static pw.Widget _buildSummaryRow(String label, double value, {bool bold = false, String suffix = '', bool isCount = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(
            isCount ? value.toInt().toString() : CurrencyUtils.formatCurrency(value) + suffix,
            style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }

  /// Save PDF file
  static Future<File> _saveFile(pw.Document pdf, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${directory.path}/reports');

    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${reportsDir.path}/${filename}_$timestamp.pdf');
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    return file;
  }
}
