import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../providers/customer_provider.dart';
import '../../providers/transaction_provider.dart';
import '../customers/customer_list_screen.dart';
import '../transactions/add_transaction_screen.dart';
import 'widgets/summary_card.dart';
import 'widgets/recent_transactions_widget.dart';

/// Home screen with dashboard
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final businessId = ref.read(currentBusinessIdProvider);
    ref.read(customerListProvider.notifier).loadCustomers(businessId);
    ref.read(transactionListProvider.notifier).loadTransactions(businessId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hisaab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show menu
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildDashboard() : const CustomerListScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          ).then((_) => _loadData());
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final customerState = ref.watch(customerListProvider);
    final transactionState = ref.watch(transactionListProvider);

    // Calculate summary
    double totalReceivable = 0;
    double totalPayable = 0;

    for (final customer in customerState.customers) {
      if (customer.hasOutstanding) {
        totalReceivable += customer.currentBalance;
      } else if (customer.hasCredit) {
        totalPayable += customer.currentBalance.abs();
      }
    }

    if (customerState.isLoading || transactionState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'To Receive',
                  amount: totalReceivable,
                  color: AppColors.success,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCard(
                  title: 'To Pay',
                  amount: totalPayable,
                  color: AppColors.error,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Stats',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    'Total Customers',
                    customerState.customers.length.toString(),
                  ),
                  _buildStatRow(
                    'Total Transactions',
                    transactionState.transactions.length.toString(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Transactions
          Text(
            'Recent Transactions',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 12),

          RecentTransactionsWidget(
            transactions: transactionState.transactions.take(10).toList(),
            customers: customerState.customers,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
