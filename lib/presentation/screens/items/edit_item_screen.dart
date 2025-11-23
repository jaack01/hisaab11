import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/item.dart';
import '../../providers/item_provider.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/error_state.dart';
import 'add_item_screen.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  final int itemId;

  const EditItemScreen({
    super.key,
    required this.itemId,
  });

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  Item? _item;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final itemState = ref.read(itemProvider);
      _item = itemState.items.firstWhere(
        (item) => item.id == widget.itemId,
        orElse: () => throw Exception('Item not found'),
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
          title: const Text('Edit Item'),
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
          title: const Text('Edit Item'),
        ),
        body: ErrorState(
          message: _error!,
          onRetry: _loadItem,
        ),
      );
    }

    if (_item == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Item'),
        ),
        body: const Center(
          child: Text('Item not found'),
        ),
      );
    }

    // Delegate to AddItemScreen with item data for editing
    return AddItemScreen(item: _item);
  }
}
