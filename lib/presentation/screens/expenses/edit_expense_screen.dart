import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/expense.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/error_state.dart';
import 'add_expense_screen.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final int expenseId;

  const EditExpenseScreen({
    super.key,
    required this.expenseId,
  });

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  Expense? _expense;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExpense();
  }

  Future<void> _loadExpense() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final expenseState = ref.read(expenseProvider);
      _expense = expenseState.expenses.firstWhere(
        (expense) => expense.id == widget.expenseId,
        orElse: () => throw Exception('Expense not found'),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Expense'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: LoadingSkeleton(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Expense'),
        ),
        body: ErrorState(
          message: _error!,
          onRetry: _loadExpense,
        ),
      );
    }

    if (_expense == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Expense'),
        ),
        body: const Center(
          child: Text('Expense not found'),
        ),
      );
    }

    // Delegate to AddExpenseScreen with expense data for editing
    return AddExpenseScreen(expense: _expense);
  }
}
