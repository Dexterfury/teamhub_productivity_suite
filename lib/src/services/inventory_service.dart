import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/inventory_item_model.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _inventoryCollection = FirebaseFirestore.instance
      .collection(AppStrings.collectionInventory);

  /// Fetches a single inventory item by its ID.
  Future<InventoryItemModel?> getInventoryItem(String itemId) async {
    try {
      DocumentSnapshot doc = await _inventoryCollection.doc(itemId).get();
      if (doc.exists) {
        return InventoryItemModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      print("Error fetching inventory item: $e");
      return null;
    }
  }

  /// Fetches a list of inventory items with optional filters.
  ///
  /// [category]: Optional. Filters items by a specific category.
  /// [searchQuery]: Optional. Searches items by name or description.
  Future<List<InventoryItemModel>> getInventoryItems({
    String? category,
    String? searchQuery,
  }) async {
    try {
      Query<Object?> query = _inventoryCollection;

      if (category != null && category.isNotEmpty && category != 'All') {
        query = query.where(AppStrings.fieldCategory, isEqualTo: category);
      }

      // For search, we'll fetch all relevant items and then filter in-memory
      // or use a more advanced search solution (e.g., Algolia, Cloud Functions)
      // For now, a simple client-side filter for demonstration.
      QuerySnapshot snapshot = await query.get();
      List<InventoryItemModel> items =
          snapshot.docs
              .map(
                (doc) => InventoryItemModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        String searchLower = searchQuery.toLowerCase();
        items =
            items.where((item) {
              return item.name.toLowerCase().contains(searchLower) ||
                  item.description.toLowerCase().contains(searchLower);
            }).toList();
      }

      return items;
    } catch (e) {
      print("Error fetching inventory items: $e");
      return [];
    }
  }

  /// Creates a new inventory item in Firestore.
  Future<void> createInventoryItem(InventoryItemModel item) async {
    try {
      await _inventoryCollection.doc(item.id).set(item.toMap());
      print('Inventory item created successfully: ${item.name}');
    } catch (e) {
      print("Error creating inventory item: $e");
      rethrow;
    }
  }

  /// Updates an existing inventory item in Firestore.
  Future<void> updateInventoryItem(InventoryItemModel item) async {
    try {
      await _inventoryCollection.doc(item.id).update(item.toMap());
      print('Inventory item updated successfully: ${item.name}');
    } catch (e) {
      print("Error updating inventory item: $e");
      rethrow;
    }
  }

  /// Deletes an inventory item from Firestore by its ID.
  Future<void> deleteInventoryItem(String itemId) async {
    try {
      await _inventoryCollection.doc(itemId).delete();
      print('Inventory item deleted successfully: $itemId');
    } catch (e) {
      print("Error deleting inventory item: $e");
      rethrow;
    }
  }
}
