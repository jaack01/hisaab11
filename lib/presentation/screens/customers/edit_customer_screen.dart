import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/customer.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/error_state.dart';
import 'add_customer_screen.dart';

/// Edit customer screen that loads customer data and shows edit form
class EditCustomerScreen extends ConsumerStatefulWidget {
  final int customerId;

  const EditCustomerScreen({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends ConsumerState<EditCustomerScreen> {
  Customer? _customer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final customerState = ref.read(customerProvider);
    final customer = customerState.customers.firstWhere(
      (c) => c.id == widget.customerId,
      orElse: () => throw Exception('Customer not found'),
    );

    setState(() {
      _customer = customer;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Customer'),
        ),
        body: Center(
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
          title: const Text('Edit Customer'),
        ),
        body: ErrorState(
          message: _error!,
          onRetry: _loadCustomer,
        ),
      );
    }

    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Customer'),
        ),
        body: const ErrorState(
          message: 'Customer not found',
        ),
      );
    }

    // Show AddCustomerScreen with customer data for editing
    return AddCustomerScreen(customer: _customer);
  }
}
