import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/inventory_item_model.dart';
import 'package:teamhub_productivity_suite/src/features/inventory/data/inventory_categories.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';
import 'package:teamhub_productivity_suite/src/widgets/stat_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  // Placeholder inventory items
  final List<InventoryItemModel> placeholderItems = [
    InventoryItemModel(
      id: '1',
      name: AppStrings.placeholderItemName,
      description: AppStrings.placeholderItemDescription,
      quantity: 10,
      category: 'Electronics',
      supplier: 'Supplier A',
      createdById: 'user1',
      createdAt: DateTime.now(),
    ),
    InventoryItemModel(
      id: '2',
      name: 'Monitor',
      description: 'External monitor for workstations.',
      quantity: 15,
      category: 'Electronics',
      supplier: null,
      createdById: 'user1',
      createdAt: DateTime.now(),
    ),
    InventoryItemModel(
      id: '3',
      name: 'Office Chair',
      description: 'Ergonomic office chair.',
      quantity: 5,
      category: 'Furniture',
      supplier: 'Office Furniture Co.',
      createdById: 'user1',
      createdAt: DateTime.now(),
    ),
  ];

  // Filtered items based on search and category
  List<InventoryItemModel> get filteredItems {
    return placeholderItems.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.inventoryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
          await Future.delayed(const Duration(seconds: 1));
        },
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ResponsiveContainer(
                    maxWidthMedium: 900,
                    maxWidthLarge: 1400,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        _buildSearchBar(),

                        const SizedBox(height: 16.0),

                        // Inventory Stats - Grid layout for tablet and larger
                        _buildInventoryStats(isTabletOrLarger),

                        const SizedBox(height: 16.0),

                        // Category Chips
                        _buildCategoryChips(),

                        const SizedBox(height: 16.0),

                        // Inventory List
                        _buildInventoryList(isTabletOrLarger),
                      ],
                    ),
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'inventory_fab',
        onPressed: () => context.go('/inventory/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        tooltip: 'Add new inventory item',
      ),
    );
  }

  // Search bar widget
  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search inventory...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        suffixIcon:
            _searchQuery.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                  tooltip: 'Clear search',
                )
                : null,
      ),
    );
  }

  // Inventory stats section
  Widget _buildInventoryStats(bool isTabletOrLarger) {
    final totalItems = placeholderItems.length;
    final totalQuantity = placeholderItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final lowStock = placeholderItems.where((item) => item.quantity < 5).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTabletOrLarger ? 3 : 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: isTabletOrLarger ? 2.0 : 1.5,
      children: [
        StatCard(
          title: 'Total Items',
          value: totalItems.toString(),
          icon: Icons.inventory,
          color: Colors.blue,
        ),
        StatCard(
          title: 'Total Quantity',
          value: totalQuantity.toString(),
          icon: Icons.production_quantity_limits,
          color: Colors.purple,
        ),
        StatCard(
          title: 'Low Stock',
          value: lowStock.toString(),
          icon: Icons.warning,
          color: lowStock > 0 ? Colors.orange : Colors.green,
        ),
      ],
    );
  }

  // Category filter chips
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          _buildCategoryChip('All', Icons.category),
          ...InventoryCategories.categories.map(
            (category) => _buildCategoryChip(
              category,
              InventoryCategories.categoryIcons[category] ?? Icons.category,
            ),
          ),
        ],
      ),
    );
  }

  // Individual category chip
  Widget _buildCategoryChip(String category, IconData icon) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: isSelected,
        label: Text(category),
        avatar: Icon(icon, size: 18),
        onSelected: (selected) => setState(() => _selectedCategory = category),
        showCheckmark: false,
        backgroundColor: Theme.of(context).chipTheme.backgroundColor,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
    );
  }

  // Inventory list with responsive layout
  Widget _buildInventoryList(bool isTabletOrLarger) {
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : _selectedCategory != 'All'
                  ? 'Try a different category filter'
                  : 'Add your first inventory item',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Use grid for tablet and larger screens
    if (isTabletOrLarger) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          return _buildInventoryItemCard(filteredItems[index]);
        },
      );
    } else {
      // Use list for mobile screens
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          return _buildInventoryItemCard(filteredItems[index]);
        },
      );
    }
  }

  // Individual inventory item card
  Widget _buildInventoryItemCard(InventoryItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            InventoryCategories.categoryIcons[item.category] ?? Icons.category,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildChip(
                  'Quantity: ${item.quantity}',
                  Icons.production_quantity_limits,
                ),
                _buildChip(item.category, Icons.category),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => context.go('/inventory/${item.id}/edit'),
          tooltip: 'Edit item',
        ),
        isThreeLine: true,
        onTap: () => context.go('/inventory/${item.id}'),
      ),
    );
  }

  // Small chip for item metadata
  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  // Filter dialog
  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Filter by Category',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == 'All',
                      onSelected: (selected) {
                        setState(() => _selectedCategory = 'All');
                        Navigator.pop(context);
                      },
                    ),
                    ...InventoryCategories.categories.map(
                      (category) => FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
