import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/user_model.dart';
import 'package:teamhub_productivity_suite/src/models/user_roles.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during sign-in.';
    }
  }

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create a new user document in Firestore
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          fullName: fullName,
          isFirstLogin: true,
          createdAt: DateTime.now(),
          roles: UserRoles(),
          lastOnline: DateTime.now(),
          searchTokens: _generateSearchTokens(fullName),
        );

        await _firestore
            .collection(AppStrings.collectionUsers)
            .doc(user.uid)
            .set(newUser.toMap());
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during registration.';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred while sending the password reset email.';
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }

  List<String> _generateSearchTokens(String name) {
    final tokens = <String>[];
    if (name.isEmpty) return tokens;
    final parts = name.split(' ');
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i].toLowerCase();
      tokens.add(part); // Add the full part
      if (i > 0) {
        tokens.add(
          parts.sublist(0, i + 1).join(' ').toLowerCase(),
        ); // Add cumulative parts
      }
    }
    return tokens;
  }
}
