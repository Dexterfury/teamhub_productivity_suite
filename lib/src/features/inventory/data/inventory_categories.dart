import 'package:flutter/material.dart';

class InventoryCategories {
  static const List<String> categories = [
    'Electronics',
    'Office Supplies',
    'Furniture',
    'IT Equipment',
    'Stationery',
    'Tools',
    'Other',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Electronics': Icons.devices,
    'Office Supplies': Icons.business_center,
    'Furniture': Icons.chair,
    'IT Equipment': Icons.computer,
    'Stationery': Icons.edit,
    'Tools': Icons.build,
    'Other': Icons.category,
  };
}
