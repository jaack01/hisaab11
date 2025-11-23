import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/entities/reminder.dart';
import '../../../domain/entities/customer.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/business_provider.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  final Reminder? reminder; // If provided, screen works in edit mode
  final int? customerId; // Pre-selected customer (optional)

  const AddReminderScreen({
    super.key,
    this.reminder,
    this.customerId,
  });

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  Customer? _selectedCustomer;
  String _reminderType = 'PAYMENT';
  DateTime _reminderDate = DateTime.now().add(const Duration(days: 1));
  bool _isSaving = false;

  final List<ReminderTypeOption> _reminderTypes = [
    ReminderTypeOption('PAYMENT', 'Payment Reminder', Icons.payments, Colors.orange),
    ReminderTypeOption('FOLLOW_UP', 'Follow-up Reminder', Icons.follow_the_signs, Colors.blue),
    ReminderTypeOption('CUSTOM', 'Custom Reminder', Icons.note, Colors.purple),
  ];

  bool get _isEditMode => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    if (_isEditMode) {
      _loadReminderData();
    } else if (widget.customerId != null) {
      _preselectCustomer();
    }
  }

  Future<void> _loadCustomers() async {
    await ref.read(customerProvider.notifier).loadAllCustomers();
  }

  void _preselectCustomer() {
    final customerState = ref.read(customerProvider);
    try {
      _selectedCustomer = customerState.customers.firstWhere(
        (c) => c.id == widget.customerId,
      );
    } catch (e) {
      // Customer not found
    }
  }

  void _loadReminderData() {
    final reminder = widget.reminder!;
    _messageController.text = reminder.message ?? '';
    _reminderType = reminder.reminderType;
    _reminderDate = DateTime.fromMillisecondsSinceEpoch(reminder.reminderDate * 1000);

    // Load customer
    final customerState = ref.read(customerProvider);
    try {
      _selectedCustomer = customerState.customers.firstWhere(
        (c) => c.id == reminder.customerId,
      );
    } catch (e) {
      // Customer not found
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reminderDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _reminderDate = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final businessId = ref.read(businessProvider).currentBusiness?.id ?? 1;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final reminderDate = _reminderDate.millisecondsSinceEpoch ~/ 1000;

    final reminder = Reminder(
      id: _isEditMode ? widget.reminder!.id : null,
      businessId: businessId,
      customerId: _selectedCustomer!.id!,
      customerName: _selectedCustomer!.name,
      reminderType: _reminderType,
      reminderDate: reminderDate,
      message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
      isSent: _isEditMode ? widget.reminder!.isSent : false,
      createdAt: _isEditMode ? widget.reminder!.createdAt : now,
      updatedAt: now,
    );

    final success = _isEditMode
        ? await ref.read(reminderProvider.notifier).updateReminder(reminder)
        : await ref.read(reminderProvider.notifier).addReminder(reminder);

    if (mounted) {
      setState(() => _isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder ${_isEditMode ? 'updated' : 'added'} successfully'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isEditMode ? 'update' : 'add'} reminder'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerProvider);
    final customers = customerState.customers;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Reminder' : 'Add Reminder'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Reminder Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ..._reminderTypes.map((type) => _buildReminderTypeCard(type)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedCustomer != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _selectedCustomer!.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCustomer!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_selectedCustomer!.phone != null)
                                    Text(
                                      _selectedCustomer!.phone!,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _selectedCustomer = null;
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () => _showCustomerPicker(customers),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Select Customer'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reminder Date
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder Date',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          app_date.AppDateUtils.formatDate(
                            _reminderDate.millisecondsSinceEpoch ~/ 1000,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Reminder Message (Optional)',
                        hintText: 'Add a message for this reminder',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.message),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            FilledButton(
              onPressed: _isSaving ? null : _saveReminder,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isEditMode ? 'Update Reminder' : 'Add Reminder'),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTypeCard(ReminderTypeOption type) {
    final isSelected = _reminderType == type.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _reminderType = type.value;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? type.color.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? type.color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: type.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(type.icon, color: type.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? type.color : null,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: type.color),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomerPicker(List<Customer> customers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Customer',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: customers.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No customers found'),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                customer.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          title: Text(customer.name),
                          subtitle: customer.phone != null ? Text(customer.phone!) : null,
                          onTap: () {
                            setState(() {
                              _selectedCustomer = customer;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReminderTypeOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  ReminderTypeOption(this.value, this.label, this.icon, this.color);
}
