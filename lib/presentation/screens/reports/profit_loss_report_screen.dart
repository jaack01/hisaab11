import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/usecases/reports/generate_profit_loss_report.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/error_state.dart';

class ProfitLossReportScreen extends ConsumerStatefulWidget {
  const ProfitLossReportScreen({super.key});

  @override
  ConsumerState<ProfitLossReportScreen> createState() => _ProfitLossReportScreenState();
}

class _ProfitLossReportScreenState extends ConsumerState<ProfitLossReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Auto-generate report on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateReport();
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    final params = ProfitLossReportParams(
      startDate: _startDate.millisecondsSinceEpoch ~/ 1000,
      endDate: _endDate.millisecondsSinceEpoch ~/ 1000,
      businessId: 1, // TODO: Get from BusinessProvider
    );

    await ref.read(reportProvider.notifier).generateProfitLossReport(params);

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
        title: const Text('Profit & Loss Report'),
        actions: [
          if (reportState.profitLossReport != null) ...[
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
          // Date Range Filter
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Period',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectStartDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              app_date.AppDateUtils.formatDate(
                                _startDate.millisecondsSinceEpoch ~/ 1000,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _selectEndDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              app_date.AppDateUtils.formatDate(
                                _endDate.millisecondsSinceEpoch ~/ 1000,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
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

    if (reportState.profitLossReport == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
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

    final report = reportState.profitLossReport!;
    final isProfit = report.netProfitLoss >= 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Net Profit/Loss Card
        Card(
          color: isProfit ? Colors.green.shade50 : Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isProfit ? 'NET PROFIT' : 'NET LOSS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  CurrencyUtils.formatCurrency(report.netProfitLoss.abs()),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isProfit ? Colors.green.shade900 : Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'For period: ${app_date.AppDateUtils.formatDate(report.startDate)} - ${app_date.AppDateUtils.formatDate(report.endDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Income Section
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
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_downward,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'INCOME',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildReportRow('Sales Revenue (Debit Transactions)', report.totalRevenue),
                _buildReportRow('Invoice Payments', report.invoiceRevenue),
                const Divider(height: 24),
                _buildReportRow(
                  'Total Income',
                  report.totalIncome,
                  bold: true,
                  color: Colors.green.shade900,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Expenses Section
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
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'EXPENSES',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildReportRow('Operating Expenses', report.totalExpenses),
                _buildReportRow('Purchases (Credit Transactions)', report.totalCreditTransactions),
                if (report.expensesByCategory.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Expense Breakdown',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...report.expensesByCategory.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: _buildReportRow(
                        entry.key,
                        entry.value,
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
                const Divider(height: 24),
                _buildReportRow(
                  'Total Expenses',
                  report.totalExpensesWithTransactions,
                  bold: true,
                  color: Colors.red.shade900,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Summary Card
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUMMARY',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                ),
                const Divider(height: 24),
                _buildReportRow('Total Income', report.totalIncome, color: Colors.green.shade700),
                _buildReportRow('Total Expenses', report.totalExpensesWithTransactions, color: Colors.red.shade700),
                const Divider(height: 16),
                _buildReportRow(
                  isProfit ? 'Net Profit' : 'Net Loss',
                  report.netProfitLoss.abs(),
                  bold: true,
                  fontSize: 18,
                  color: isProfit ? Colors.green.shade900 : Colors.red.shade900,
                ),
                if (report.totalIncome > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profit Margin',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${((report.netProfitLoss / report.totalIncome) * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isProfit ? Colors.green.shade900 : Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
