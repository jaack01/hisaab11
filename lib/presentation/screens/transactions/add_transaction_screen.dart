import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/transaction.dart';
import '../../providers/customer_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final Customer? customer;
  final String? initialType;

  const AddTransactionScreen({
    super.key,
    this.customer,
    this.initialType,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _transactionType = AppConstants.transactionTypeCredit; // Default: You Gave
  Customer? _selectedCustomer;
  String? _paymentMode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.customer;
    if (widget.initialType != null) {
      _transactionType = widget.initialType!;
    }
    // Load customers if not pre-selected
    if (widget.customer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final businessId = ref.read(currentBusinessIdProvider);
        ref.read(customerListProvider.notifier).loadCustomers(businessId);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final businessId = ref.read(currentBusinessIdProvider);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final transaction = Transaction(
      businessId: businessId,
      customerId: _selectedCustomer!.id!,
      transactionType: _transactionType,
      amount: double.parse(_amountController.text.trim()),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      transactionDate: now,
      paymentMode: _paymentMode,
      createdAt: now,
      updatedAt: now,
    );

    final addTransaction = ref.read(addTransactionUseCaseProvider);
    final result = await addTransaction(transaction);

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction added successfully')),
          );
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Transaction Type Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(
                        'You Gave',
                        AppConstants.transactionTypeCredit,
                        AppColors.error,
                        Icons.arrow_upward,
                      ),
                    ),
                    Expanded(
                      child: _buildTypeButton(
                        'You Got',
                        AppConstants.transactionTypeDebit,
                        AppColors.success,
                        Icons.arrow_downward,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Customer Selection
            if (widget.customer == null)
              DropdownButtonFormField<Customer>(
                value: _selectedCustomer,
                decoration: const InputDecoration(
                  labelText: 'Select Customer *',
                  prefixIcon: Icon(Icons.person),
                ),
                items: customerState.customers.map((customer) {
                  return DropdownMenuItem(
                    value: customer,
                    child: Text(customer.name),
                  );
                }).toList(),
                onChanged: (customer) {
                  setState(() => _selectedCustomer = customer);
                },
                validator: (value) {
                  if (value == null) return 'Please select a customer';
                  return null;
                },
              )
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person),
                title: Text(_selectedCustomer!.name),
                subtitle: _selectedCustomer!.phone != null
                    ? Text(_selectedCustomer!.phone!)
                    : null,
              ),

            const SizedBox(height: 16),

            // Amount Input
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount *',
                hintText: 'Enter amount',
                prefixIcon: const Icon(Icons.currency_rupee),
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: ValidationUtils.validateAmountField,
              autofocus: widget.customer != null,
            ),

            const SizedBox(height: 16),

            // Payment Mode
            DropdownButtonFormField<String>(
              value: _paymentMode,
              decoration: const InputDecoration(
                labelText: 'Payment Mode',
                prefixIcon: Icon(Icons.payment),
              ),
              items: AppConstants.paymentModes.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode),
                );
              }).toList(),
              onChanged: (mode) {
                setState(() => _paymentMode = mode);
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description (optional)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
              validator: ValidationUtils.validateDescriptionField,
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: _transactionType == AppConstants.transactionTypeCredit
                    ? AppColors.error
                    : AppColors.success,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, Color color, IconData icon) {
    final isSelected = _transactionType == type;

    return GestureDetector(
      onTap: () => setState(() => _transactionType = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
