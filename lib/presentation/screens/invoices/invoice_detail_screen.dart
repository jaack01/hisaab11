import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/entities/invoice.dart';
import '../../../domain/entities/customer.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/error_state.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final int invoiceId;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  Invoice? _invoice;
  Customer? _customer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInvoiceDetails();
  }

  Future<void> _loadInvoiceDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load invoice
      final invoiceState = ref.read(invoiceProvider);
      _invoice = invoiceState.invoices.firstWhere(
        (inv) => inv.id == widget.invoiceId,
        orElse: () => throw Exception('Invoice not found'),
      );

      // Load customer
      final customerState = ref.read(customerProvider);
      _customer = customerState.customers.firstWhere(
        (c) => c.id == _invoice!.customerId,
        orElse: () => throw Exception('Customer not found'),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text(
          'Are you sure you want to delete this invoice? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && _invoice != null) {
      final success = await ref.read(invoiceProvider.notifier).deleteInvoice(
            _invoice!.id!,
            _invoice!.businessId,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice deleted successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete invoice')),
          );
        }
      }
    }
  }

  Future<void> _recordPayment() async {
    if (_invoice == null) return;

    final amountController = TextEditingController(
      text: (_invoice!.totalAmount - _invoice!.paidAmount).toString(),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: ${CurrencyUtils.formatCurrency(_invoice!.totalAmount)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Paid Amount: ${CurrencyUtils.formatCurrency(_invoice!.paidAmount)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Balance: ${CurrencyUtils.formatCurrency(_invoice!.totalAmount - _invoice!.paidAmount)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                prefixText: CurrencyUtils.rupeeSymbol + ' ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      final newPaidAmount = _invoice!.paidAmount + result;
      String newStatus;

      if (newPaidAmount >= _invoice!.totalAmount) {
        newStatus = 'PAID';
      } else if (newPaidAmount > 0) {
        newStatus = 'PARTIAL';
      } else {
        newStatus = 'PENDING';
      }

      final updatedInvoice = Invoice(
        id: _invoice!.id,
        businessId: _invoice!.businessId,
        customerId: _invoice!.customerId,
        invoiceNumber: _invoice!.invoiceNumber,
        invoiceDate: _invoice!.invoiceDate,
        dueDate: _invoice!.dueDate,
        subtotal: _invoice!.subtotal,
        taxAmount: _invoice!.taxAmount,
        discount: _invoice!.discount,
        totalAmount: _invoice!.totalAmount,
        paidAmount: newPaidAmount,
        paymentStatus: newStatus,
        notes: _invoice!.notes,
        createdAt: _invoice!.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      final success = await ref.read(invoiceProvider.notifier).updateInvoice(updatedInvoice);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment recorded successfully')),
          );
          _loadInvoiceDetails();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to record payment')),
          );
        }
      }
    }
  }

  void _shareInvoice() {
    // TODO: Implement PDF generation and sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share invoice feature coming soon!'),
      ),
    );
  }

  void _downloadPDF() {
    // TODO: Implement PDF generation and download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download PDF feature coming soon!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invoice Details'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LoadingSkeleton(
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 16),
            LoadingSkeleton(
              width: double.infinity,
              height: 150,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 16),
            LoadingSkeleton(
              width: double.infinity,
              height: 300,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invoice Details'),
        ),
        body: ErrorState(
          message: _error!,
          onRetry: _loadInvoiceDetails,
        ),
      );
    }

    if (_invoice == null || _customer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invoice Details'),
        ),
        body: const Center(
          child: Text('Invoice not found'),
        ),
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final isOverdue = _invoice!.paymentStatus != 'PAID' && _invoice!.dueDate < now;

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${_invoice!.invoiceNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Download PDF',
            onPressed: _downloadPDF,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: _shareInvoice,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                // TODO: Navigate to edit screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit feature coming soon!')),
                );
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Payment Status Card
          _buildPaymentStatusCard(isOverdue),

          const SizedBox(height: 16),

          // Customer Details
          _buildCustomerCard(),

          const SizedBox(height: 16),

          // Invoice Details
          _buildInvoiceDetailsCard(),

          const SizedBox(height: 16),

          // Items List
          _buildItemsCard(),

          const SizedBox(height: 16),

          // Totals
          _buildTotalsCard(),

          if (_invoice!.notes != null) ...[
            const SizedBox(height: 16),
            _buildNotesCard(),
          ],

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
      floatingActionButton: _invoice!.paymentStatus != 'PAID'
          ? FloatingActionButton.extended(
              onPressed: _recordPayment,
              icon: const Icon(Icons.payment),
              label: const Text('Record Payment'),
            )
          : null,
    );
  }

  Widget _buildPaymentStatusCard(bool isOverdue) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_invoice!.paymentStatus) {
      case 'PAID':
        statusColor = Colors.green;
        statusText = 'Paid';
        statusIcon = Icons.check_circle;
        break;
      case 'PARTIAL':
        statusColor = Colors.orange;
        statusText = 'Partially Paid';
        statusIcon = Icons.timelapse;
        break;
      default:
        statusColor = isOverdue ? Colors.red : Colors.orange;
        statusText = isOverdue ? 'Overdue' : 'Pending';
        statusIcon = isOverdue ? Icons.warning : Icons.schedule;
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  if (_invoice!.paymentStatus != 'PAID')
                    Text(
                      'Balance: ${CurrencyUtils.formatCurrency(_invoice!.totalAmount - _invoice!.paidAmount)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyUtils.formatCurrency(_invoice!.totalAmount),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                ),
                if (_invoice!.paidAmount > 0)
                  Text(
                    'Paid: ${CurrencyUtils.formatCurrency(_invoice!.paidAmount)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Customer Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.customerDetails,
                      arguments: {'customerId': _customer!.id},
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View'),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _customer!.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _customer!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (_customer!.phone != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16),
                            const SizedBox(width: 4),
                            Text(_customer!.phone!),
                          ],
                        ),
                      ],
                      if (_customer!.email != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email, size: 16),
                            const SizedBox(width: 4),
                            Text(_customer!.email!),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _buildDetailRow('Invoice Number:', _invoice!.invoiceNumber),
            _buildDetailRow(
              'Invoice Date:',
              app_date.AppDateUtils.formatDate(_invoice!.invoiceDate),
            ),
            _buildDetailRow(
              'Due Date:',
              app_date.AppDateUtils.formatDate(_invoice!.dueDate),
            ),
            _buildDetailRow(
              'Payment Status:',
              _formatPaymentStatus(_invoice!.paymentStatus),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    // TODO: Fetch actual invoice items
    // For now, showing placeholder
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Invoice items will be displayed here',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal:', _invoice!.subtotal),
            _buildTotalRow('Tax:', _invoice!.taxAmount),
            if (_invoice!.discount > 0)
              _buildTotalRow('Discount:', _invoice!.discount, isNegative: true),
            const Divider(),
            _buildTotalRow(
              'Total:',
              _invoice!.totalAmount,
              bold: true,
              large: true,
            ),
            if (_invoice!.paidAmount > 0) ...[
              _buildTotalRow('Paid:', _invoice!.paidAmount, isPositive: true),
              const Divider(),
              _buildTotalRow(
                'Balance:',
                _invoice!.totalAmount - _invoice!.paidAmount,
                bold: true,
                color: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            Text(_invoice!.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool bold = false,
    bool large = false,
    bool isNegative = false,
    bool isPositive = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: large ? 18 : null,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}${CurrencyUtils.formatCurrency(amount)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: large ? 18 : null,
              color: color ??
                  (isPositive
                      ? Colors.green
                      : isNegative
                          ? Colors.red
                          : null),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPaymentStatus(String status) {
    switch (status) {
      case 'PAID':
        return 'Paid';
      case 'PARTIAL':
        return 'Partially Paid';
      case 'PENDING':
        return 'Pending';
      default:
        return status;
    }
  }
}
