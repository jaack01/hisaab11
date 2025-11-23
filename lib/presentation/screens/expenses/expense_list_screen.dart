import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/entities/expense.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/loading_skeleton.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load expenses on screen load
    Future.microtask(() {
      ref.read(expenseProvider.notifier).loadAllExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    final categories = ref.read(expenseProvider.notifier).categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          if (categories.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter by Category',
              onSelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
                ref.read(expenseProvider.notifier)
                    .loadExpensesByCategory(category);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'ALL',
                  child: Text('All Categories'),
                ),
                const PopupMenuDivider(),
                ...categories.map(
                  (category) => PopupMenuItem(
                    value: category,
                    child: Text(category),
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Filter by Date',
            onPressed: () {
              // TODO: Implement date range picker
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Total expense card
          if (!expenseState.isLoading && expenseState.expenses.isNotEmpty)
            Card(
              margin: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Expenses',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        if (_selectedCategory != null &&
                            _selectedCategory != 'ALL')
                          Text(
                            _selectedCategory!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    Text(
                      CurrencyUtils.formatCurrency(
                        ref.read(expenseProvider.notifier).totalExpenses,
                      ),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                    ),
                  ],
                ),
              ),
            ),

          // Expense list
          Expanded(
            child: expenseState.isLoading
                ? _buildLoadingState()
                : expenseState.error != null
                    ? ErrorState(
                        message: expenseState.error!,
                        onRetry: () {
                          if (_selectedCategory != null &&
                              _selectedCategory != 'ALL') {
                            ref.read(expenseProvider.notifier)
                                .loadExpensesByCategory(_selectedCategory!);
                          } else {
                            ref.read(expenseProvider.notifier).loadAllExpenses();
                          }
                        },
                      )
                    : _buildExpenseList(expenseState.expenses),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addExpense);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
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

  Widget _buildExpenseList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return EmptyState(
        icon: Icons.receipt,
        title: 'No Expenses',
        subtitle: 'Record your first expense to get started',
        actionLabel: 'Add Expense',
        onAction: () {
          Navigator.pushNamed(context, Routes.addExpense);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedCategory != null && _selectedCategory != 'ALL') {
          await ref.read(expenseProvider.notifier)
              .loadExpensesByCategory(_selectedCategory!);
        } else {
          await ref.read(expenseProvider.notifier).loadAllExpenses();
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return _ExpenseCard(
            expense: expense,
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.editExpense,
                arguments: {'expenseId': expense.id},
              );
            },
          );
        },
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const _ExpenseCard({
    required this.expense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(expense.category),
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 16),

              // Expense details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.category,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (expense.description != null)
                      Text(
                        expense.description!,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          app_date.AppDateUtils.formatDate(expense.expenseDate),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                CurrencyUtils.formatCurrency(expense.amount),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Icons.home;
      case 'utilities':
        return Icons.electrical_services;
      case 'salary':
        return Icons.payments;
      case 'supplies':
        return Icons.inventory;
      case 'marketing':
        return Icons.campaign;
      case 'transport':
        return Icons.local_shipping;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.receipt;
    }
  }
}
