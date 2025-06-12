import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';

class InventoryItemModel {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final String category;
  final String? supplier;
  final String createdById;
  final DateTime createdAt;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.category,
    this.supplier,
    required this.createdById,
    required this.createdAt,
  });

  factory InventoryItemModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime createdAtDate;
    if (map[AppStrings.fieldCreatedAt] == null) {
      createdAtDate = DateTime.now();
    } else if (map[AppStrings.fieldCreatedAt] is Timestamp) {
      createdAtDate = (map[AppStrings.fieldCreatedAt] as Timestamp).toDate();
    } else if (map[AppStrings.fieldCreatedAt] is String) {
      createdAtDate =
          DateTime.tryParse(map[AppStrings.fieldCreatedAt] as String) ??
          DateTime.now();
    } else {
      createdAtDate = DateTime.now();
    }

    return InventoryItemModel(
      id: id,
      name: map[AppStrings.fieldItemName] ?? '',
      description: map[AppStrings.fieldItemDescription] ?? '',
      quantity: map[AppStrings.fieldQuantity] ?? 0,
      category: map[AppStrings.fieldCategory] ?? '',
      supplier: map[AppStrings.fieldSupplier],
      createdById: map[AppStrings.fieldCreatedById] ?? '',
      createdAt: createdAtDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppStrings.fieldId: id,
      AppStrings.fieldItemName: name,
      AppStrings.fieldItemDescription: description,
      AppStrings.fieldQuantity: quantity,
      AppStrings.fieldCategory: category,
      AppStrings.fieldSupplier: supplier,
      AppStrings.fieldCreatedById: createdById,
      AppStrings.fieldCreatedAt: Timestamp.fromDate(createdAt),
    };
  }
}
