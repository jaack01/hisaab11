import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/usecases/reports/generate_balance_sheet_report.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/error_state.dart';

class BalanceSheetReportScreen extends ConsumerStatefulWidget {
  const BalanceSheetReportScreen({super.key});

  @override
  ConsumerState<BalanceSheetReportScreen> createState() => _BalanceSheetReportScreenState();
}

class _BalanceSheetReportScreenState extends ConsumerState<BalanceSheetReportScreen> {
  DateTime _asOfDate = DateTime.now();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Auto-generate report on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateReport();
    });
  }

  Future<void> _selectAsOfDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _asOfDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _asOfDate = picked;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    final params = BalanceSheetReportParams(
      asOfDate: _asOfDate.millisecondsSinceEpoch ~/ 1000,
      businessId: 1, // TODO: Get from BusinessProvider
    );

    await ref.read(reportProvider.notifier).generateBalanceSheetReport(params);

    setState(() => _isGenerating = false);
  }

  void _downloadPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF download feature coming soon!')),
    );
  }

  void _sharePDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF share feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance Sheet'),
        actions: [
          if (reportState.balanceSheetReport != null) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _downloadPDF,
              tooltip: 'Download PDF',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePDF,
              tooltip: 'Share',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // As-of Date Filter
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Date',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectAsOfDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'As of Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        helperText: 'Balance sheet shows position as of this date',
                      ),
                      child: Text(
                        app_date.AppDateUtils.formatDate(
                          _asOfDate.millisecondsSinceEpoch ~/ 1000,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isGenerating ? null : _generateReport,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(_isGenerating ? 'Generating...' : 'Refresh Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Report Content
          Expanded(
            child: _buildReportContent(reportState),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(ReportState reportState) {
    if (reportState.isLoading) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LoadingSkeleton(
            width: double.infinity,
            height: 150,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),
          LoadingSkeleton(
            width: double.infinity,
            height: 400,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      );
    }

    if (reportState.error != null) {
      return ErrorState(
        message: reportState.error!,
        onRetry: _generateReport,
      );
    }

    if (reportState.balanceSheetReport == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Report Generated',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      );
    }

    final report = reportState.balanceSheetReport!;
    final isBalanced = (report.totalAssets - report.totalLiabilities).abs() < 0.01;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Balance Status Card
        Card(
          color: isBalanced ? Colors.green.shade50 : Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isBalanced ? Icons.check_circle : Icons.info,
                  color: isBalanced ? Colors.green.shade700 : Colors.orange.shade700,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBalanced ? 'Sheet is Balanced' : 'Balance Check',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isBalanced ? Colors.green.shade900 : Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'As of ${app_date.AppDateUtils.formatDate(report.asOfDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Assets Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ASSETS',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Current Assets
                Text(
                  'Current Assets',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      _buildReportRow('Cash & Bank', report.cash),
                      _buildReportRow('Accounts Receivable', report.accountsReceivable),
                      _buildReportRow('Inventory', report.inventory),
                    ],
                  ),
                ),
                const Divider(height: 16),
                _buildReportRow(
                  'Total Current Assets',
                  report.totalCurrentAssets,
                  bold: true,
                ),

                const SizedBox(height: 16),

                // Fixed Assets
                Text(
                  'Fixed Assets',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      _buildReportRow('Property & Equipment', report.fixedAssets),
                    ],
                  ),
                ),
                const Divider(height: 16),
                _buildReportRow(
                  'Total Fixed Assets',
                  report.fixedAssets,
                  bold: true,
                ),

                const Divider(height: 24),
                _buildReportRow(
                  'TOTAL ASSETS',
                  report.totalAssets,
                  bold: true,
                  fontSize: 16,
                  color: Colors.blue.shade900,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Liabilities Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.trending_down,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'LIABILITIES',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Current Liabilities
                Text(
                  'Current Liabilities',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      _buildReportRow('Accounts Payable', report.accountsPayable),
                      _buildReportRow('Outstanding Invoices', report.outstandingInvoices),
                    ],
                  ),
                ),
                const Divider(height: 16),
                _buildReportRow(
                  'Total Current Liabilities',
                  report.totalCurrentLiabilities,
                  bold: true,
                ),

                const SizedBox(height: 16),

                // Long-term Liabilities
                Text(
                  'Long-term Liabilities',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      _buildReportRow('Long-term Debt', report.longTermDebt),
                    ],
                  ),
                ),
                const Divider(height: 16),
                _buildReportRow(
                  'Total Long-term Liabilities',
                  report.longTermDebt,
                  bold: true,
                ),

                const Divider(height: 24),
                _buildReportRow(
                  'TOTAL LIABILITIES',
                  report.totalLiabilities,
                  bold: true,
                  fontSize: 16,
                  color: Colors.orange.shade900,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Equity Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'EQUITY',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900,
                          ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildReportRow('Owner\'s Equity', report.ownersEquity),
                _buildReportRow('Retained Earnings', report.retainedEarnings),
                const Divider(height: 16),
                _buildReportRow(
                  'TOTAL EQUITY',
                  report.totalEquity,
                  bold: true,
                  fontSize: 16,
                  color: Colors.purple.shade900,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Summary Equation
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'ACCOUNTING EQUATION',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                ),
                const Divider(height: 24),
                _buildReportRow('Assets', report.totalAssets, bold: true),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('=', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                _buildReportRow('Liabilities', report.totalLiabilities, bold: true),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('+', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                _buildReportRow('Equity', report.totalEquity, bold: true),
                const Divider(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBalanced ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Difference:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBalanced ? Colors.green.shade900 : Colors.orange.shade900,
                        ),
                      ),
                      Text(
                        CurrencyUtils.formatCurrency((report.totalAssets - report.totalLiabilities - report.totalEquity).abs()),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBalanced ? Colors.green.shade900 : Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportRow(
    String label,
    double amount, {
    bool bold = false,
    double fontSize = 14,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
                color: color,
              ),
            ),
          ),
          Text(
            CurrencyUtils.formatCurrency(amount),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: fontSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
