import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/utils/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/inventory_item_model.dart';
import 'package:teamhub_productivity_suite/src/features/inventory/data/inventory_categories.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

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

  List<InventoryItemModel> get filteredItems {
    return placeholderItems.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.inventoryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildInventoryStats(),
          _buildCategoryChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildInventoryList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/inventory/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search inventory...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildInventoryStats() {
    final totalItems = placeholderItems.length;
    final totalQuantity = placeholderItems.fold<int>(0, (sum, item) => sum + item.quantity);
    final lowStock = placeholderItems.where((item) => item.quantity < 5).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total Items', totalItems.toString(), Icons.inventory),
          _buildStatCard('Total Quantity', totalQuantity.toString(), Icons.production_quantity_limits),
          _buildStatCard('Low Stock', lowStock.toString(), Icons.warning, color: lowStock > 0 ? Colors.orange : null),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color? color}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
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

  Widget _buildCategoryChip(String category, IconData icon) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: isSelected,
        label: Text(category),
        avatar: Icon(icon, size: 18),
        onSelected: (selected) => setState(() => _selectedCategory = category),
      ),
    );
  }

  Widget _buildInventoryList() {
    return ListView.builder(
      itemCount: filteredItems.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(InventoryCategories.categoryIcons[item.category] ?? Icons.category),
            ),
            title: Text(item.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildChip('Quantity: ${item.quantity}', Icons.production_quantity_limits),
                    const SizedBox(width: 8),
                    _buildChip(item.category, Icons.category),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go('/inventory/${item.id}/edit'),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
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

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter by Category', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
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
