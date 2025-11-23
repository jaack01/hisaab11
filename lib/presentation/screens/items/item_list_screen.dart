import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../domain/entities/item.dart';
import '../../providers/item_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/loading_skeleton.dart';

class ItemListScreen extends ConsumerStatefulWidget {
  const ItemListScreen({super.key});

  @override
  ConsumerState<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends ConsumerState<ItemListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load items on screen load
    Future.microtask(() {
      ref.read(itemProvider.notifier).loadAllItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(itemProvider.notifier).searchItems(query);
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Items & Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortOptions(context);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: itemState.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(itemProvider.notifier).clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Products'),
                  Tab(text: 'Services'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: itemState.isLoading
          ? _buildLoadingState()
          : itemState.error != null
              ? ErrorState(
                  message: itemState.error!,
                  onRetry: () {
                    ref.read(itemProvider.notifier).loadAllItems();
                  },
                )
              : _buildItemList(itemState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addItem);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
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

  Widget _buildItemList(ItemState state) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildItemTab(state.items, 'All'),
        _buildItemTab(
          ref.read(itemProvider.notifier).productItems,
          'Products',
        ),
        _buildItemTab(
          ref.read(itemProvider.notifier).serviceItems,
          'Services',
        ),
      ],
    );
  }

  Widget _buildItemTab(List<Item> items, String tabName) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2,
        title: 'No $tabName',
        subtitle: 'Add your first item to get started',
        actionLabel: 'Add Item',
        onAction: () {
          Navigator.pushNamed(context, Routes.addItem);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(itemProvider.notifier).loadAllItems();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _ItemCard(
            item: item,
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.editItem,
                arguments: {'itemId': item.id},
              );
            },
          );
        },
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Sort by Name'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sorting
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Sort by Price'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sorting
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const _ItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProduct = item.itemType == 'PRODUCT';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Type icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isProduct ? Colors.blue : Colors.green)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isProduct ? Icons.inventory_2 : Icons.design_services,
                  color: isProduct ? Colors.blue : Colors.green,
                ),
              ),
              const SizedBox(width: 16),

              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (isProduct ? Colors.blue : Colors.green)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isProduct ? 'Product' : 'Service',
                            style: TextStyle(
                              color: isProduct ? Colors.blue : Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (item.hsn != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'HSN: ${item.hsn}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyUtils.formatCurrency(item.salePrice),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  if (item.purchasePrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Cost: ${CurrencyUtils.formatCurrency(item.purchasePrice!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
