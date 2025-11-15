import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../providers/customer_provider.dart';
import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerListProvider);

    if (state.isLoading && state.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final businessId = ref.read(currentBusinessIdProvider);
                ref.read(customerListProvider.notifier).loadCustomers(businessId);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No customers yet',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first customer to get started',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddCustomerScreen(),
                  ),
                ).then((_) {
                  final businessId = ref.read(currentBusinessIdProvider);
                  ref.read(customerListProvider.notifier).loadCustomers(businessId);
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Customer'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.customers.length,
      itemBuilder: (context, index) {
        final customer = state.customers[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: customer.hasOutstanding
                ? AppColors.success.withOpacity(0.1)
                : customer.hasCredit
                    ? AppColors.error.withOpacity(0.1)
                    : Colors.grey[200],
            child: Text(
              customer.name[0].toUpperCase(),
              style: AppTextStyles.titleMedium.copyWith(
                color: customer.hasOutstanding
                    ? AppColors.success
                    : customer.hasCredit
                        ? AppColors.error
                        : Colors.grey[700],
              ),
            ),
          ),
          title: Text(customer.name, style: AppTextStyles.customerName),
          subtitle: customer.phone != null
              ? Text(customer.phone!, style: AppTextStyles.customerPhone)
              : null,
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyUtils.formatCurrency(customer.absoluteBalance),
                style: AppTextStyles.transactionAmount.copyWith(
                  color: customer.hasOutstanding
                      ? AppColors.success
                      : customer.hasCredit
                          ? AppColors.error
                          : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                customer.hasOutstanding
                    ? 'To Receive'
                    : customer.hasCredit
                        ? 'To Pay'
                        : 'Settled',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerDetailScreen(customer: customer),
              ),
            ).then((_) {
              final businessId = ref.read(currentBusinessIdProvider);
              ref.read(customerListProvider.notifier).loadCustomers(businessId);
            });
          },
        );
      },
    );
  }
}
