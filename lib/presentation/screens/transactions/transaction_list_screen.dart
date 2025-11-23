import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/entities/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/loading_skeleton.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  final int? customerId; // Optional: filter by customer

  const TransactionListScreen({
    super.key,
    this.customerId,
  });

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load transactions on screen load
    Future.microtask(() {
      if (widget.customerId != null) {
        ref.read(transactionProvider.notifier).loadCustomerTransactions(widget.customerId!);
      } else {
        ref.read(transactionProvider.notifier).loadAllTransactions();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.customerId != null
              ? 'Customer Transactions'
              : 'All Transactions',
        ),
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
              // TODO: Implement filter by date range
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'You Gave'),
            Tab(text: 'You Got'),
          ],
        ),
      ),
      body: transactionState.isLoading
          ? _buildLoadingState()
          : transactionState.error != null
              ? ErrorState(
                  message: transactionState.error!,
                  onRetry: () {
                    if (widget.customerId != null) {
                      ref.read(transactionProvider.notifier)
                          .loadCustomerTransactions(widget.customerId!);
                    } else {
                      ref.read(transactionProvider.notifier).loadAllTransactions();
                    }
                  },
                )
              : _buildTransactionList(transactionState),
      floatingActionButton: widget.customerId != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.addTransaction,
                  arguments: {'customerId': widget.customerId},
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LoadingSkeleton(
          width: double.infinity,
          height: 80,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTransactionList(TransactionState state) {
    final List<Transaction> creditTransactions = state.transactions
        .where((t) => t.transactionType == 'CREDIT')
        .toList();

    final List<Transaction> debitTransactions = state.transactions
        .where((t) => t.transactionType == 'DEBIT')
        .toList();

    return TabBarView(
      controller: _tabController,
      children: [
        _buildTransactionTab(state.transactions, 'All'),
        _buildTransactionTab(creditTransactions, 'You Gave'),
        _buildTransactionTab(debitTransactions, 'You Got'),
      ],
    );
  }

  Widget _buildTransactionTab(List<Transaction> transactions, String tabName) {
    if (transactions.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long,
        title: 'No $tabName Transactions',
        subtitle: 'Record your first transaction to get started',
        actionLabel: widget.customerId != null ? 'Add Transaction' : null,
        onAction: widget.customerId != null
            ? () {
                Navigator.pushNamed(
                  context,
                  Routes.addTransaction,
                  arguments: {'customerId': widget.customerId},
                );
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.customerId != null) {
          await ref.read(transactionProvider.notifier)
              .loadCustomerTransactions(widget.customerId!);
        } else {
          await ref.read(transactionProvider.notifier).loadAllTransactions();
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _TransactionCard(
            transaction: transaction,
            showCustomer: widget.customerId == null,
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.editTransaction,
                arguments: {'transactionId': transaction.id},
              );
            },
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final bool showCustomer;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.transaction,
    required this.showCustomer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = transaction.transactionType == 'CREDIT';
    final color = isCredit ? Colors.red : Colors.green;
    final icon = isCredit ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Type indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer name (if showing)
                    if (showCustomer && transaction.customerName != null) ...[
                      Text(
                        transaction.customerName!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Description or default text
                    Text(
                      transaction.description ??
                          (isCredit ? 'You gave money' : 'You got money'),
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          app_date.AppDateUtils.formatDate(transaction.transactionDate),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyUtils.formatCurrency(transaction.amount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCredit ? 'You Gave' : 'You Got',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
