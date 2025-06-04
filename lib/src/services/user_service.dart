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
