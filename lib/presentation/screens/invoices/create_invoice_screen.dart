import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../core/utils/validation_utils.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/entities/invoice_item.dart';
import '../../providers/customer_provider.dart';
import '../../providers/item_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/business_provider.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  final int? customerId; // Pre-selected customer (optional)

  const CreateInvoiceScreen({
    super.key,
    this.customerId,
  });

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Form data
  Customer? _selectedCustomer;
  final List<InvoiceItemData> _invoiceItems = [];
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  String _paymentStatus = 'PENDING';

  bool _isSaving = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _invoiceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);

    // Load customers
    await ref.read(customerProvider.notifier).loadAllCustomers();

    // Load items
    await ref.read(itemProvider.notifier).loadAllItems();

    // Pre-select customer if provided
    if (widget.customerId != null) {
      final customerState = ref.read(customerProvider);
      try {
        _selectedCustomer = customerState.customers.firstWhere(
          (c) => c.id == widget.customerId,
        );
      } catch (e) {
        // Customer not found
      }
    }

    // Generate invoice number
    _generateInvoiceNumber();

    setState(() => _isLoadingData = false);
  }

  void _generateInvoiceNumber() {
    final now = DateTime.now();
    final invoiceNumber = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
    _invoiceNumberController.text = invoiceNumber;
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedFromStep(int step) {
    switch (step) {
      case 0:
        return _selectedCustomer != null;
      case 1:
        return _invoiceItems.isNotEmpty;
      case 2:
        return _invoiceNumberController.text.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _saveInvoice() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final businessId = ref.read(businessProvider).currentBusiness?.id ?? 1;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final invoiceDate = _invoiceDate.millisecondsSinceEpoch ~/ 1000;
    final dueDate = _dueDate.millisecondsSinceEpoch ~/ 1000;

    // Calculate totals
    final subtotal = _calculateSubtotal();
    final taxAmount = _calculateTax();
    final total = subtotal + taxAmount;

    // Create invoice
    final invoice = Invoice(
      businessId: businessId,
      customerId: _selectedCustomer!.id!,
      invoiceNumber: _invoiceNumberController.text,
      invoiceDate: invoiceDate,
      dueDate: dueDate,
      subtotal: subtotal,
      taxAmount: taxAmount,
      discount: 0,
      totalAmount: total,
      paidAmount: _paymentStatus == 'PAID' ? total : 0,
      paymentStatus: _paymentStatus,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    // Save invoice
    final success = await ref.read(invoiceProvider.notifier).addInvoice(invoice);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice created successfully')),
        );
        Navigator.pop(context);
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create invoice')),
        );
      }
    }
  }

  double _calculateSubtotal() {
    return _invoiceItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double _calculateTax() {
    return _invoiceItems.fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Invoice'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Text('Back'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCustomerSelection(),
                _buildItemsSelection(),
                _buildDetailsAndReview(),
              ],
            ),
          ),

          // Bottom buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Customer'),
          Expanded(child: _buildStepLine(0)),
          _buildStepIndicator(1, 'Items'),
          Expanded(child: _buildStepLine(1)),
          _buildStepIndicator(2, 'Review'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = step < _currentStep;
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isCompleted
          ? Theme.of(context).primaryColor
          : Colors.grey.shade300,
    );
  }

  Widget _buildCustomerSelection() {
    final customerState = ref.watch(customerProvider);
    final customers = customerState.customers;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Select Customer',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a customer for this invoice',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 24),

        // Search bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search customers...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (query) {
            // TODO: Implement search
          },
        ),
        const SizedBox(height: 16),

        // Customer list
        if (customers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text('No customers found'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: Navigate to add customer
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Customer'),
                  ),
                ],
              ),
            ),
          )
        else
          ...customers.map((customer) => _buildCustomerCard(customer)),
      ],
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final isSelected = _selectedCustomer?.id == customer.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCustomer = customer;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    customer.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (customer.phone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        customer.phone!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsSelection() {
    final itemState = ref.watch(itemProvider);
    final items = itemState.items;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Add Items',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select products or services for this invoice',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 24),

        // Selected items summary
        if (_invoiceItems.isNotEmpty) ...[
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selected Items',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${_invoiceItems.length} item(s)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._invoiceItems.map((item) => _buildSelectedItemTile(item)),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text(
                        CurrencyUtils.formatCurrency(_calculateSubtotal()),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tax:'),
                      Text(
                        CurrencyUtils.formatCurrency(_calculateTax()),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        CurrencyUtils.formatCurrency(
                          _calculateSubtotal() + _calculateTax(),
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Available items
        Text(
          'Available Items',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        if (items.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text('No items found'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: Navigate to add item
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
            ),
          )
        else
          ...items.map((item) => _buildItemCard(item)),
      ],
    );
  }

  Widget _buildSelectedItemTile(InvoiceItemData itemData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemData.itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${itemData.quantity} x ${CurrencyUtils.formatCurrency(itemData.unitPrice)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            CurrencyUtils.formatCurrency(itemData.total),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () {
              setState(() {
                _invoiceItems.remove(itemData);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAddItemDialog(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyUtils.formatCurrency(item.salePrice),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  if (item.gstRate != null)
                    Text(
                      'GST: ${item.gstRate}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddItemDialog(Item item) async {
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: item.salePrice.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Unit Price',
                prefixText: CurrencyUtils.rupeeSymbol + ' ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 1;
              final unitPrice = double.tryParse(priceController.text) ?? item.salePrice;

              final subtotal = quantity * unitPrice;
              final taxRate = item.gstRate ?? 0;
              final taxAmount = subtotal * (taxRate / 100);
              final total = subtotal + taxAmount;

              setState(() {
                _invoiceItems.add(InvoiceItemData(
                  itemId: item.id!,
                  itemName: item.name,
                  quantity: quantity,
                  unitPrice: unitPrice,
                  taxRate: taxRate,
                  taxAmount: taxAmount,
                  total: total,
                ));
              });

              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsAndReview() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Invoice Details',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),

        // Invoice Number
        TextField(
          controller: _invoiceNumberController,
          decoration: const InputDecoration(
            labelText: 'Invoice Number *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Invoice Date
        InkWell(
          onTap: () => _selectInvoiceDate(),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Invoice Date *',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              app_date.AppDateUtils.formatDate(
                _invoiceDate.millisecondsSinceEpoch ~/ 1000,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Due Date
        InkWell(
          onTap: () => _selectDueDate(),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Due Date *',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              app_date.AppDateUtils.formatDate(
                _dueDate.millisecondsSinceEpoch ~/ 1000,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Payment Status
        DropdownButtonFormField<String>(
          value: _paymentStatus,
          decoration: const InputDecoration(
            labelText: 'Payment Status',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
            DropdownMenuItem(value: 'PAID', child: Text('Paid')),
            DropdownMenuItem(value: 'PARTIAL', child: Text('Partially Paid')),
          ],
          onChanged: (value) {
            setState(() {
              _paymentStatus = value ?? 'PENDING';
            });
          },
        ),
        const SizedBox(height: 16),

        // Notes
        TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes / Terms (Optional)',
            hintText: 'Add payment terms, notes, etc.',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),

        // Summary
        Card(
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(),
                _buildSummaryRow('Customer:', _selectedCustomer?.name ?? '-'),
                _buildSummaryRow('Items:', '${_invoiceItems.length}'),
                _buildSummaryRow('Subtotal:', CurrencyUtils.formatCurrency(_calculateSubtotal())),
                _buildSummaryRow('Tax:', CurrencyUtils.formatCurrency(_calculateTax())),
                const Divider(),
                _buildSummaryRow(
                  'Total:',
                  CurrencyUtils.formatCurrency(_calculateSubtotal() + _calculateTax()),
                  bold: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectInvoiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _invoiceDate = picked;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: _invoiceDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: _canProceedFromStep(_currentStep)
                  ? (_currentStep == 2 ? _saveInvoice : _nextStep)
                  : null,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_currentStep == 2 ? 'Create Invoice' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for invoice items
class InvoiceItemData {
  final int itemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double taxRate;
  final double taxAmount;
  final double total;

  InvoiceItemData({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
  });
}
