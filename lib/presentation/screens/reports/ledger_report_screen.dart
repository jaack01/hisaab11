import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/reports/generate_ledger_report.dart';
import '../../providers/customer_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/error_state.dart';

class LedgerReportScreen extends ConsumerStatefulWidget {
  final int? customerId; // Pre-selected customer (optional)

  const LedgerReportScreen({
    super.key,
    this.customerId,
  });

  @override
  ConsumerState<LedgerReportScreen> createState() => _LedgerReportScreenState();
}

class _LedgerReportScreenState extends ConsumerState<LedgerReportScreen> {
  Customer? _selectedCustomer;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    if (widget.customerId != null) {
      _preselectCustomer();
    }
  }

  Future<void> _loadCustomers() async {
    await ref.read(customerProvider.notifier).loadAllCustomers();
  }

  void _preselectCustomer() {
    final customerState = ref.read(customerProvider);
    try {
      _selectedCustomer = customerState.customers.firstWhere(
        (c) => c.id == widget.customerId,
      );
      // Auto-generate report if customer is pre-selected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateReport();
      });
    } catch (e) {
      // Customer not found
    }
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
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final params = LedgerReportParams(
      customerId: _selectedCustomer!.id!,
      startDate: _startDate.millisecondsSinceEpoch ~/ 1000,
      endDate: _endDate.millisecondsSinceEpoch ~/ 1000,
    );

    await ref.read(reportProvider.notifier).generateLedgerReport(params);

    setState(() => _isGenerating = false);
  }

  void _downloadPDF() {
    // TODO: Implement PDF download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF download feature coming soon!')),
    );
  }

  void _sharePDF() {
    // TODO: Implement PDF sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF share feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);
    final customerState = ref.watch(customerProvider);
    final customers = customerState.customers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger Report'),
        actions: [
          if (reportState.ledgerReport != null) ...[
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
          // Filters Section
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Customer Selector
                  if (_selectedCustomer != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _selectedCustomer!.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedCustomer!.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (_selectedCustomer!.phone != null)
                                  Text(
                                    _selectedCustomer!.phone!,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedCustomer = null;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _showCustomerPicker(customers),
                      icon: const Icon(Icons.person),
                      label: const Text('Select Customer'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Date Range
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

                  // Generate Button
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
                          : const Icon(Icons.assessment),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate Report'),
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
            height: 100,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),
          LoadingSkeleton(
            width: double.infinity,
            height: 300,
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

    if (reportState.ledgerReport == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
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
            const SizedBox(height: 8),
            Text(
              'Select a customer and date range,\nthen click Generate Report',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ),
      );
    }

    final report = reportState.ledgerReport!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        Card(
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(),
                _buildSummaryRow('Customer:', report.customerName),
                _buildSummaryRow(
                  'Period:',
                  '${app_date.AppDateUtils.formatDate(report.startDate)} - ${app_date.AppDateUtils.formatDate(report.endDate)}',
                ),
                _buildSummaryRow('Opening Balance:', CurrencyUtils.formatCurrency(report.openingBalance)),
                const Divider(),
                _buildSummaryRow(
                  'Total Credit (You Gave):',
                  CurrencyUtils.formatCurrency(report.totalCredit),
                  color: Colors.red,
                ),
                _buildSummaryRow(
                  'Total Debit (You Got):',
                  CurrencyUtils.formatCurrency(report.totalDebit),
                  color: Colors.green,
                ),
                const Divider(),
                _buildSummaryRow(
                  'Closing Balance:',
                  CurrencyUtils.formatCurrency(report.closingBalance),
                  bold: true,
                  color: report.closingBalance >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Transactions List
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                if (report.transactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text('No transactions in this period'),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      // Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Description',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Credit',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Debit',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Balance',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Transaction Rows
                      ...report.transactions.map((txn) => _buildTransactionRow(txn)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(LedgerTransaction txn) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              app_date.AppDateUtils.formatDate(txn.date),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              txn.description ?? '-',
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              txn.type == 'CREDIT' ? CurrencyUtils.formatCurrency(txn.amount) : '-',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              txn.type == 'DEBIT' ? CurrencyUtils.formatCurrency(txn.amount) : '-',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              CurrencyUtils.formatCurrency(txn.runningBalance),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: txn.runningBalance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerPicker(List<Customer> customers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Customer',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: customers.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No customers found'),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                customer.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          title: Text(customer.name),
                          subtitle: customer.phone != null ? Text(customer.phone!) : null,
                          onTap: () {
                            setState(() {
                              _selectedCustomer = customer;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
