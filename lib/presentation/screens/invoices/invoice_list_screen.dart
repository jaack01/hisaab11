import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/entities/invoice.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/loading_skeleton.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load invoices on screen load
    Future.microtask(() {
      ref.read(invoiceProvider.notifier).loadAllInvoices();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(invoiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Paid'),
            Tab(text: 'Overdue'),
          ],
        ),
      ),
      body: invoiceState.isLoading
          ? _buildLoadingState()
          : invoiceState.error != null
              ? ErrorState(
                  message: invoiceState.error!,
                  onRetry: () {
                    ref.read(invoiceProvider.notifier).loadAllInvoices();
                  },
                )
              : _buildInvoiceList(invoiceState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, Routes.createInvoice);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: LoadingSkeleton(
          width: double.infinity,
          height: 120,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildInvoiceList(InvoiceState state) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildInvoiceTab(state.invoices, 'All'),
        _buildInvoiceTab(
          ref.read(invoiceProvider.notifier).pendingInvoices,
          'Pending',
        ),
        _buildInvoiceTab(
          ref.read(invoiceProvider.notifier).paidInvoices,
          'Paid',
        ),
        _buildInvoiceTab(
          ref.read(invoiceProvider.notifier).overdueInvoices,
          'Overdue',
        ),
      ],
    );
  }

  Widget _buildInvoiceTab(List<Invoice> invoices, String tabName) {
    if (invoices.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long,
        title: 'No $tabName Invoices',
        subtitle: 'Create your first invoice to get started',
        actionLabel: 'Create Invoice',
        onAction: () {
          Navigator.pushNamed(context, Routes.createInvoice);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(invoiceProvider.notifier).loadAllInvoices();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return _InvoiceCard(
            invoice: invoice,
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.invoiceDetail,
                arguments: {'invoiceId': invoice.id},
              );
            },
          );
        },
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const _InvoiceCard({
    required this.invoice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(invoice.paymentStatus);
    final statusIcon = _getStatusIcon(invoice.paymentStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Invoice number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatStatus(invoice.paymentStatus),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Customer name
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      invoice.customerName ?? 'Customer',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Invoice date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    app_date.AppDateUtils.formatDate(invoice.invoiceDate),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Divider(),
              const SizedBox(height: 8),

              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatCurrency(invoice.totalAmount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),

              // Paid amount (if partially paid)
              if (invoice.paymentStatus == 'PARTIAL' && invoice.paidAmount > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paid Amount',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      CurrencyUtils.formatCurrency(invoice.paidAmount),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Balance Due',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      CurrencyUtils.formatCurrency(
                        invoice.totalAmount - invoice.paidAmount,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'PARTIAL':
        return Colors.blue;
      case 'OVERDUE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PAID':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'PARTIAL':
        return Icons.payments;
      case 'OVERDUE':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'PAID':
        return 'Paid';
      case 'PENDING':
        return 'Pending';
      case 'PARTIAL':
        return 'Partial';
      case 'OVERDUE':
        return 'Overdue';
      default:
        return status;
    }
  }
}
