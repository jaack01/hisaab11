import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/business.dart';
import '../../providers/business_provider.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/error_state.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _invoiceFooterController = TextEditingController();

  Business? _business;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBusinessProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstNumberController.dispose();
    _panNumberController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _invoiceFooterController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await ref.read(businessProvider.notifier).loadBusinesses();
    final businessState = ref.read(businessProvider);

    if (businessState.currentBusiness != null) {
      _business = businessState.currentBusiness!;
      _populateFields();
      setState(() {
        _isLoading = false;
      });
    } else if (businessState.error != null) {
      setState(() {
        _isLoading = false;
        _error = businessState.error;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFields() {
    if (_business == null) return;

    _nameController.text = _business!.name;
    _addressController.text = _business!.address ?? '';
    _phoneController.text = _business!.phone ?? '';
    _emailController.text = _business!.email ?? '';
    _gstNumberController.text = _business!.gstNumber ?? '';
    _panNumberController.text = _business!.panNumber ?? '';
    _bankNameController.text = _business!.bankName ?? '';
    _accountNumberController.text = _business!.accountNumber ?? '';
    _ifscController.text = _business!.ifscCode ?? '';
    _invoiceFooterController.text = _business!.invoiceFooter ?? '';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final updatedBusiness = Business(
      id: _business?.id,
      name: _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      gstNumber: _gstNumberController.text.trim().isEmpty ? null : _gstNumberController.text.trim(),
      panNumber: _panNumberController.text.trim().isEmpty ? null : _panNumberController.text.trim(),
      logoPath: _business?.logoPath,
      bankName: _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim().isEmpty ? null : _accountNumberController.text.trim(),
      ifscCode: _ifscController.text.trim().isEmpty ? null : _ifscController.text.trim(),
      invoiceFooter: _invoiceFooterController.text.trim().isEmpty ? null : _invoiceFooterController.text.trim(),
      createdAt: _business?.createdAt ?? now,
      updatedAt: now,
    );

    final success = _business == null
        ? await ref.read(businessProvider.notifier).addBusiness(updatedBusiness)
        : await ref.read(businessProvider.notifier).updateBusiness(updatedBusiness);

    if (mounted) {
      setState(() => _isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business profile saved successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save business profile')),
        );
      }
    }
  }

  void _uploadLogo() {
    // TODO: Implement image picker for logo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logo upload feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Business Profile'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LoadingSkeleton(
              width: double.infinity,
              height: 150,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 16),
            LoadingSkeleton(
              width: double.infinity,
              height: 400,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Business Profile'),
        ),
        body: ErrorState(
          message: _error!,
          onRetry: _loadBusinessProfile,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Logo Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: _business?.logoPath != null
                          ? ClipOval(
                              child: Image.network(
                                _business!.logoPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.business,
                                  size: 60,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.business,
                              size: 60,
                              color: Theme.of(context).primaryColor,
                            ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _uploadLogo,
                      icon: const Icon(Icons.upload),
                      label: Text(_business?.logoPath != null ? 'Change Logo' : 'Upload Logo'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Recommended: 500x500 px, PNG or JPG',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
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
                        labelText: 'Business Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter business name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
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
                      controller: _gstNumberController,
                      decoration: const InputDecoration(
                        labelText: 'GST Number (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                        helperText: 'e.g., 22AAAAA0000A1Z5',
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _panNumberController,
                      decoration: const InputDecoration(
                        labelText: 'PAN Number (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                        helperText: 'e.g., AAAAA9999A',
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bank Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(
                        labelText: 'Bank Name (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Account Number (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance_wallet),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ifscController,
                      decoration: const InputDecoration(
                        labelText: 'IFSC Code (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.code),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Invoice Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _invoiceFooterController,
                      decoration: const InputDecoration(
                        labelText: 'Invoice Footer / Terms (Optional)',
                        hintText: 'e.g., Payment terms, thank you message, etc.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
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
              onPressed: _isSaving ? null : _saveProfile,
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
                  : const Text('Save Profile'),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
