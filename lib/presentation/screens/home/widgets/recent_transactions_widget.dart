import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/entities/transaction.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Customer> customers;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final customer = customers.firstWhere(
            (c) => c.id == transaction.customerId,
            orElse: () => Customer(
              businessId: 0,
              name: 'Unknown',
              createdAt: 0,
              updatedAt: 0,
            ),
          );

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction.isCredit
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              child: Icon(
                transaction.isCredit
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: transaction.isCredit ? AppColors.error : AppColors.success,
                size: 20,
              ),
            ),
            title: Text(
              customer.name,
              style: AppTextStyles.titleSmall,
            ),
            subtitle: Text(
              AppDateUtils.formatTimestamp(transaction.transactionDate),
              style: AppTextStyles.bodySmall,
            ),
            trailing: Text(
              CurrencyUtils.formatCurrency(transaction.amount),
              style: AppTextStyles.transactionAmount.copyWith(
                color: transaction.isCredit ? AppColors.error : AppColors.success,
              ),
            ),
          );
        },
      ),
    );
  }
}
