import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teamhub_productivity_suite/src/models/user_model.dart';
import 'package:teamhub_productivity_suite/src/services/auth_service.dart';
import 'package:teamhub_productivity_suite/src/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _user;
  UserModel? _appUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;

  UserModel? get appUser => _appUser;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authService.auth.authStateChanges().listen((User? firebaseUser) async {
      _user = firebaseUser;
      if (_user != null) {
        _appUser = await _userService.getUser(_user!.uid);
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.registerWithEmailAndPassword(email, password, fullName);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}