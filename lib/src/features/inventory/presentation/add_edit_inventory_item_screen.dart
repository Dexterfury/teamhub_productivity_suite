import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/features/inventory/data/inventory_categories.dart';
import 'package:teamhub_productivity_suite/src/models/inventory_item_model.dart';

class AddEditInventoryItemScreen extends StatefulWidget {
  final String? itemId;
  final InventoryItemModel? item;

  const AddEditInventoryItemScreen({Key? key, this.itemId, this.item}) : super(key: key);

  bool get isEditing => itemId != null;

  @override
  State<AddEditInventoryItemScreen> createState() => _AddEditInventoryItemScreenState();
}

class _AddEditInventoryItemScreenState extends State<AddEditInventoryItemScreen> {
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
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '0');
    _supplierController = TextEditingController(text: widget.item?.supplier ?? '');
    if (widget.item?.category != null) {
      _selectedCategory = widget.item!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final _item = InventoryItemModel(
        id: widget.itemId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        quantity: int.parse(_quantityController.text),
        category: _selectedCategory,
        supplier: _supplierController.text.isEmpty ? null : _supplierController.text,
        createdById: 'user1', // TODO: Get from auth service
        createdAt: DateTime.now(),
      );      // Simulate saving to backend
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Saving item: ${_item.toMap()}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Item updated successfully' : 'Item added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.genericError)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? AppStrings.editInventoryItemTitle : AppStrings.addInventoryItemTitle),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveItem,
            icon: _isLoading 
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppStrings.itemNameHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.inventory),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.requiredFieldError;
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppStrings.itemDescriptionHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: AppStrings.quantityHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.production_quantity_limits),
                    ),
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
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: AppStrings.categoryHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(InventoryCategories.categoryIcons[_selectedCategory]),
                    ),
                    items: InventoryCategories.categories.map((category) {
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _supplierController,
              decoration: InputDecoration(
                labelText: AppStrings.supplierHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.business),
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }
}
