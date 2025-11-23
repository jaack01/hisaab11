import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/entities/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/error_state.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final int transactionId;

  const EditTransactionScreen({
    super.key,
    required this.transactionId,
  });

  @override
  ConsumerState<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Transaction? _transaction;
  bool _isLoading = true;
  String? _error;
  bool _isSaving = false;
  DateTime? _selectedDate;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transactionState = ref.read(transactionProvider);
      final transaction = transactionState.transactions.firstWhere(
        (t) => t.id == widget.transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      setState(() {
        _transaction = transaction;
        _amountController.text = transaction.amount.toString();
        _descriptionController.text = transaction.description ?? '';
        _selectedDate = DateTime.fromMillisecondsSinceEpoch(
          transaction.transactionDate * 1000,
        );
        _selectedType = transaction.transactionType;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_transaction == null) return;

    setState(() => _isSaving = true);

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final transactionDate = _selectedDate!.millisecondsSinceEpoch ~/ 1000;

    final updatedTransaction = Transaction(
      id: _transaction!.id,
      businessId: _transaction!.businessId,
      customerId: _transaction!.customerId,
      transactionType: _selectedType!,
      amount: double.parse(_amountController.text.trim()),
      transactionDate: transactionDate,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      attachmentPath: _transaction!.attachmentPath,
      createdAt: _transaction!.createdAt,
      updatedAt: now,
    );

    final success = await ref
        .read(transactionProvider.notifier)
        .updateTransaction(updatedTransaction);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction updated successfully')),
        );
        Navigator.pop(context);
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update transaction')),
        );
      }
    }
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    final success = await ref
        .read(transactionProvider.notifier)
        .deleteTransaction(
          widget.transactionId,
          _transaction!.businessId,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully')),
        );
        Navigator.pop(context);
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete transaction')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Transaction'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: LoadingSkeleton(
            width: double.infinity,
            height: 400,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Transaction'),
        ),
        body: ErrorState(
          message: _error!,
          onRetry: _loadTransaction,
        ),
      );
    }

    if (_transaction == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Transaction'),
        ),
        body: const ErrorState(
          message: 'Transaction not found',
        ),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isSaving ? null : _deleteTransaction,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer info (read-only)
            if (_transaction!.customerName != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              _transaction!.customerName!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Transaction Type
            Text(
              'Transaction Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'CREDIT',
                  label: Text('You Gave'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: 'DEBIT',
                  label: Text('You Got'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_selectedType ?? 'CREDIT'},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedType = selection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount *',
                prefixText: CurrencyUtils.rupeeSymbol + ' ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: ValidationUtils.validateAmount,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),

            // Date
            InkWell(
              onTap: _isSaving ? null : _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Transaction Date *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate != null
                      ? app_date.AppDateUtils.formatDate(
                          _selectedDate!.millisecondsSinceEpoch ~/ 1000,
                        )
                      : 'Select date',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add a note...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _isSaving ? null : _saveTransaction,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
