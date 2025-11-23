import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/item.dart';
import '../../providers/item_provider.dart';
import '../../providers/business_provider.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final Item? item; // If provided, screen works in edit mode

  const AddItemScreen({
    super.key,
    this.item,
  });

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _hsnController = TextEditingController();
  final _gstRateController = TextEditingController(text: '18');

  String _itemType = 'PRODUCT';
  bool _isSaving = false;

  bool get _isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadItemData();
    }
  }

  void _loadItemData() {
    final item = widget.item!;
    _nameController.text = item.name;
    _descriptionController.text = item.description ?? '';
    _salePriceController.text = item.salePrice.toString();
    _purchasePriceController.text = item.purchasePrice?.toString() ?? '';
    _hsnController.text = item.hsn ?? '';
    _gstRateController.text = item.gstRate?.toString() ?? '18';
    _itemType = item.itemType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _hsnController.dispose();
    _gstRateController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final businessId = ref.read(businessProvider).currentBusiness?.id ?? 1;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final item = Item(
      id: _isEditMode ? widget.item!.id : null,
      businessId: businessId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      itemType: _itemType,
      salePrice: double.parse(_salePriceController.text),
      purchasePrice: _purchasePriceController.text.trim().isEmpty
          ? null
          : double.parse(_purchasePriceController.text),
      hsn: _hsnController.text.trim().isEmpty ? null : _hsnController.text.trim(),
      gstRate: _gstRateController.text.trim().isEmpty
          ? null
          : double.parse(_gstRateController.text),
      createdAt: _isEditMode ? widget.item!.createdAt : now,
      updatedAt: now,
    );

    final success = _isEditMode
        ? await ref.read(itemProvider.notifier).updateItem(item)
        : await ref.read(itemProvider.notifier).addItem(item);

    if (mounted) {
      setState(() => _isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item ${_isEditMode ? 'updated' : 'added'} successfully'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isEditMode ? 'update' : 'add'} item'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Item' : 'Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Item Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            value: 'PRODUCT',
                            groupValue: _itemType,
                            onChanged: (value) {
                              setState(() => _itemType = value!);
                            },
                            title: const Text('Product'),
                            subtitle: const Text('Physical goods'),
                            secondary: const Icon(Icons.inventory_2),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            value: 'SERVICE',
                            groupValue: _itemType,
                            onChanged: (value) {
                              setState(() => _itemType = value!);
                            },
                            title: const Text('Service'),
                            subtitle: const Text('Services offered'),
                            secondary: const Icon(Icons.design_services),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Basic Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name *',
                        hintText: 'Enter item name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter item name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Enter item description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pricing Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pricing',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _salePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Sale Price *',
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter sale price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) < 0) {
                          return 'Price cannot be negative';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _purchasePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase/Cost Price (Optional)',
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_cart),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) < 0) {
                            return 'Price cannot be negative';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tax Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tax Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hsnController,
                      decoration: const InputDecoration(
                        labelText: 'HSN Code (Optional)',
                        hintText: 'Enter HSN/SAC code',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _gstRateController,
                      decoration: const InputDecoration(
                        labelText: 'GST Rate (Optional)',
                        hintText: '18',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.percent),
                        helperText: 'Common rates: 0%, 5%, 12%, 18%, 28%',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          final rate = double.parse(value);
                          if (rate < 0 || rate > 100) {
                            return 'Rate must be between 0 and 100';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            FilledButton(
              onPressed: _isSaving ? null : _saveItem,
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
                  : Text(_isEditMode ? 'Update Item' : 'Add Item'),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
