import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/di/injection.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/transaction.dart';
import '../../providers/customer_provider.dart';
import '../transactions/add_transaction_screen.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    final getTransactions = ref.read(getTransactionsByCustomerUseCaseProvider);
    final result = await getTransactions(customerId: widget.customer.id!);

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (transactions) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _makePhoneCall() async {
    if (widget.customer.phone == null) return;

    final uri = Uri(scheme: 'tel', path: widget.customer.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to make phone call')),
        );
      }
    }
  }

  Future<void> _sendSMS() async {
    if (widget.customer.phone == null) return;

    final uri = Uri(scheme: 'sms', path: widget.customer.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to send SMS')),
        );
      }
    }
  }

  Future<void> _sendEmail() async {
    if (widget.customer.email == null) return;

    final uri = Uri(scheme: 'mailto', path: widget.customer.email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to send email')),
        );
      }
    }
  }

  void _viewLedger() {
    Navigator.pushNamed(
      context,
      Routes.ledgerReport,
      arguments: {'customerId': widget.customer.id},
    );
  }

  void _createInvoice() {
    Navigator.pushNamed(
      context,
      Routes.createInvoice,
      arguments: {'customerId': widget.customer.id},
    );
  }

  void _editCustomer() {
    Navigator.pushNamed(
      context,
      Routes.editCustomer,
      arguments: {'customerId': widget.customer.id},
    );
  }

  Future<void> _deleteCustomer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete ${widget.customer.name}? This will also delete all transactions with this customer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(customerProvider.notifier).deleteCustomer(
            widget.customer.id!,
            widget.customer.businessId,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer deleted successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete customer')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editCustomer,
            tooltip: 'Edit Customer',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'invoice',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long),
                    SizedBox(width: 8),
                    Text('Create Invoice'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'ledger',
                child: Row(
                  children: [
                    Icon(Icons.assessment),
                    SizedBox(width: 8),
                    Text('View Ledger'),
                  ],
                ),
              ),
              if (widget.customer.phone != null) ...[
                const PopupMenuItem(
                  value: 'call',
                  child: Row(
                    children: [
                      Icon(Icons.phone),
                      SizedBox(width: 8),
                      Text('Call'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'sms',
                  child: Row(
                    children: [
                      Icon(Icons.message),
                      SizedBox(width: 8),
                      Text('Send SMS'),
                    ],
                  ),
                ),
              ],
              if (widget.customer.email != null)
                const PopupMenuItem(
                  value: 'email',
                  child: Row(
                    children: [
                      Icon(Icons.email),
                      SizedBox(width: 8),
                      Text('Send Email'),
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
              switch (value) {
                case 'invoice':
                  _createInvoice();
                  break;
                case 'ledger':
                  _viewLedger();
                  break;
                case 'call':
                  _makePhoneCall();
                  break;
                case 'sms':
                  _sendSMS();
                  break;
                case 'email':
                  _sendEmail();
                  break;
                case 'delete':
                  _deleteCustomer();
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: widget.customer.hasOutstanding
                ? AppColors.success.withOpacity(0.1)
                : widget.customer.hasCredit
                    ? AppColors.error.withOpacity(0.1)
                    : Colors.grey[100],
            child: Column(
              children: [
                Text(
                  widget.customer.hasOutstanding
                      ? 'You will get'
                      : widget.customer.hasCredit
                          ? 'You will give'
                          : 'Settled',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyUtils.formatCurrency(widget.customer.absoluteBalance),
                  style: AppTextStyles.displaySmall.copyWith(
                    color: widget.customer.hasOutstanding
                        ? AppColors.success
                        : widget.customer.hasCredit
                            ? AppColors.error
                            : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.customer.phone != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.customer.phone!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTransactionScreen(
                            customer: widget.customer,
                            initialType: 'CREDIT',
                          ),
                        ),
                      ).then((_) => _loadTransactions());
                    },
                    icon: const Icon(Icons.arrow_upward, color: AppColors.error),
                    label: const Text('You Gave'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTransactionScreen(
                            customer: widget.customer,
                            initialType: 'DEBIT',
                          ),
                        ),
                      ).then((_) => _loadTransactions());
                    },
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('You Got'),
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadTransactions,
                    child: _transactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pull down to refresh',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _transactions.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final transaction = _transactions[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: transaction.isCredit
                                      ? AppColors.error.withOpacity(0.1)
                                      : AppColors.success.withOpacity(0.1),
                                  child: Icon(
                                    transaction.isCredit
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: transaction.isCredit
                                        ? AppColors.error
                                        : AppColors.success,
                                  ),
                                ),
                                title: Text(
                                  transaction.transactionTypeDisplay,
                                  style: AppTextStyles.titleSmall,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppDateUtils.formatTimestamp(
                                        transaction.transactionDate,
                                      ),
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    if (transaction.description != null)
                                      Text(
                                        transaction.description!,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  CurrencyUtils.formatCurrency(transaction.amount),
                                  style: AppTextStyles.transactionAmount.copyWith(
                                    color: transaction.isCredit
                                        ? AppColors.error
                                        : AppColors.success,
                                  ),
                                ),
                                onTap: () {
                                  // TODO: Navigate to transaction detail
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
