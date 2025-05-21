import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/features/inventory/data/inventory_categories.dart';
import 'package:teamhub_productivity_suite/src/models/inventory_item_model.dart';
import 'package:teamhub_productivity_suite/src/widgets/inputfield.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

class AddEditInventoryItemScreen extends StatefulWidget {
  final String? itemId;
  final InventoryItemModel? item;

  const AddEditInventoryItemScreen({super.key, this.itemId, this.item});

  bool get isEditing => itemId != null;

  @override
  State<AddEditInventoryItemScreen> createState() =>
      _AddEditInventoryItemScreenState();
}

class _AddEditInventoryItemScreenState
    extends State<AddEditInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _supplierController;
  String _selectedCategory = InventoryCategories.categories.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values if editing
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '0',
    );
    _supplierController = TextEditingController(
      text: widget.item?.supplier ?? '',
    );
    if (widget.item?.category != null) {
      _selectedCategory = widget.item!.category;
    }
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  // Save inventory item
  Future<void> _saveItem() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create item model from form data
      final item = InventoryItemModel(
        id: widget.itemId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        quantity: int.parse(_quantityController.text),
        category: _selectedCategory,
        supplier:
            _supplierController.text.isEmpty ? null : _supplierController.text,
        createdById: 'user1', // TODO: Get from auth service
        createdAt: DateTime.now(),
      );

      // Simulate saving to backend
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Saving item: ${item.toMap()}');

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Item updated successfully'
                : 'Item added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      context.pop();
    } catch (e) {
      if (!mounted) return;
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.genericError),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? AppStrings.editInventoryItemTitle
              : AppStrings.addInventoryItemTitle,
        ),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveItem,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.save),
            label: Text(AppStrings.saveButton),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ResponsiveContainer(
            maxWidthMedium: 800,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Header
                  _buildFormHeader(context),

                  const SizedBox(height: 24.0),

                  // Form Fields - Different layouts for different screen sizes
                  if (isTabletOrLarger)
                    _buildTabletForm()
                  else
                    _buildMobileForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Form header with title and instructions
  Widget _buildFormHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isEditing ? 'Edit Item Details' : 'Add New Inventory Item',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in the details below to ${widget.isEditing ? 'update' : 'add'} an inventory item.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  // Tablet and larger screen form layout
  Widget _buildTabletForm() {
    return Column(
      children: [
        // Name field
        InputField(
          controller: _nameController,
          labelText: AppStrings.itemNameHint,
          icon: Icons.inventory,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.requiredFieldError;
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),

        // Description field
        InputField(
          controller: _descriptionController,
          labelText: AppStrings.itemDescriptionHint,
          icon: Icons.description,
          maxLines: 3,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16.0),

        // Quantity and Category in a row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quantity field
            Expanded(
              child: InputField(
                controller: _quantityController,
                labelText: AppStrings.quantityHint,
                icon: Icons.production_quantity_limits,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredFieldError;
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity < 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16.0),

            // Category dropdown
            Expanded(child: _buildCategoryDropdown()),
          ],
        ),
        const SizedBox(height: 16.0),

        // Supplier field
        InputField(
          controller: _supplierController,
          labelText: AppStrings.supplierHint,
          icon: Icons.business,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  // Mobile screen form layout
  Widget _buildMobileForm() {
    return Column(
      children: [
        // Name field
        InputField(
          controller: _nameController,
          labelText: AppStrings.itemNameHint,
          icon: Icons.inventory,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.requiredFieldError;
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),

        // Description field
        InputField(
          controller: _descriptionController,
          labelText: AppStrings.itemDescriptionHint,
          icon: Icons.description,
          maxLines: 3,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16.0),

        // Quantity field
        InputField(
          controller: _quantityController,
          labelText: AppStrings.quantityHint,
          icon: Icons.production_quantity_limits,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.requiredFieldError;
            }
            final quantity = int.tryParse(value);
            if (quantity == null || quantity < 0) {
              return 'Please enter a valid quantity';
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),

        // Category dropdown
        _buildCategoryDropdown(),
        const SizedBox(height: 16.0),

        // Supplier field
        InputField(
          controller: _supplierController,
          labelText: AppStrings.supplierHint,
          icon: Icons.business,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  // Category dropdown widget
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: AppStrings.categoryHint,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(InventoryCategories.categoryIcons[_selectedCategory]),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
      items:
          InventoryCategories.categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(InventoryCategories.categoryIcons[category], size: 20),
                  const SizedBox(width: 8),
                  Text(category),
                ],
              ),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategory = value);
        }
      },
      isExpanded: true,
    );
  }
}
