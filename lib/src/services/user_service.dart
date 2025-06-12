import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/user_model.dart';
import 'package:teamhub_productivity_suite/src/models/user_roles.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection(AppStrings.collectionUsers)
              .doc(uid)
              .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      print("Error fetching user: $e"); // Log the error for debugging
      return null;
    }
  }

  /// Gets all users from Firestore (for team member selection)
  /// Consider adding pagination for large user bases
  Future<List<UserModel>> getAllUsers({int limit = 100}) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection(AppStrings.collectionUsers)
              .orderBy(AppStrings.fieldFullName)
              .limit(limit)
              .get();

      return snapshot.docs
          .map(
            (doc) =>
                UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print("Error fetching all users: $e");
      return [];
    }
  }

  /// Fetches a list of users from Firestore, with optional filtering and searching.
  ///
  /// [roleFilter]: Optional. Filters users by a specific role ('Admin', 'Manager', 'Member').
  /// [searchQuery]: Optional. Searches users by full name or email.
  Future<List<UserModel>> getUsers({
    String? roleFilter,
    String? searchQuery,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(
        AppStrings.collectionUsers,
      );

      // Apply role filter
      if (roleFilter != null && roleFilter != 'All') {
        switch (roleFilter) {
          case 'Admin':
            query = query.where(
              '${AppStrings.fieldRoles}.${AppStrings.fieldIsAdmin}',
              isEqualTo: true,
            );
            break;
          case 'Manager':
            query = query.where(
              '${AppStrings.fieldRoles}.${AppStrings.fieldIsManager}',
              isEqualTo: true,
            );
            break;
          case 'Member':
            query = query.where(
              '${AppStrings.fieldRoles}.${AppStrings.fieldIsMember}',
              isEqualTo: true,
            );
            break;
        }
      }

      // Apply search query (simple prefix search on fullName for now)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        String searchLower = searchQuery.toLowerCase();
        query = query
            .orderBy(AppStrings.fieldFullName)
            .startAt([searchLower])
            .endAt([searchLower + '\uf8ff']);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) =>
                UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  /// Fetches a list of users by their UIDs.
  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) {
      return [];
    }
    try {
      // Firestore 'whereIn' clause has a limit of 10 UIDs
      // For more than 10, multiple queries or a Cloud Function would be needed.
      // For this example, we'll assume a small number of members or handle in batches.
      final List<UserModel> users = [];
      for (int i = 0; i < uids.length; i += 10) {
        final batchUids = uids.sublist(
          i,
          i + 10 > uids.length ? uids.length : i + 10,
        );
        QuerySnapshot snapshot =
            await _firestore
                .collection(AppStrings.collectionUsers)
                .where(FieldPath.documentId, whereIn: batchUids)
                .get();
        users.addAll(
          snapshot.docs
              .map(
                (doc) => UserModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
      }
      return users;
    } catch (e) {
      print("Error fetching users by IDs: $e");
      return [];
    }
  }

  /// Updates the roles of a specific user in Firestore.
  Future<void> updateUserRoles(String uid, UserRoles roles) async {
    try {
      await _firestore.collection(AppStrings.collectionUsers).doc(uid).update({
        AppStrings.fieldRoles: roles.toMap(),
      });
      print('User roles updated successfully for user ID: $uid');
    } catch (e) {
      print("Error updating user roles: $e");
      rethrow; // Re-throw to handle in UI
    }
  }

  /// Updates user profile information in Firestore
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(AppStrings.collectionUsers)
          .doc(uid)
          .update(updates);
      print('User profile updated successfully for user ID: $uid');
    } catch (e) {
      print("Error updating user profile: $e");
      rethrow; // Re-throw to handle in UI
    }
  }

  /// Uploads profile image to Firebase Storage and returns the download URL
  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');

      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('Profile image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print("Error uploading profile image: $e");
      rethrow;
    }
  }
}
