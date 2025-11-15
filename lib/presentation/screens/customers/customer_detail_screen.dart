import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/transaction.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show options menu
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
                : _transactions.isEmpty
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
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
