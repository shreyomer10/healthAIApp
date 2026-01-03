import 'dart:io';
import 'package:flutter/material.dart';
import '../core/api_exception.dart';
import '../core/secure_storage.dart';
import '../repository/auth_repository.dart';
import '../Model/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repo;

  bool loading = false;
  bool isLoggedIn = false;
  UserModel? user;
  String? error;
  int? statusCode;
  String? message;
  AuthProvider(this.repo);

  Future<void> checkLogin() async {
    final token = await SecureStorage.getToken();
    final storedUser = await SecureStorage.getUser();

    if (token != null && storedUser != null) {
      user = storedUser;
      isLoggedIn = true;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    loading = true;
    message = null;
    statusCode = null;
    error = null;
    notifyListeners();

    try {
      final (token, user) = await repo.login(email, password);
      await SecureStorage.saveToken(token);
      await SecureStorage.saveUser(user);
      this.user = user;
      isLoggedIn = true;
      statusCode = 200;
      message = 'Login successful';

    }
    catch (e) {
      if (e is ApiException) {
        error = e.message;
        statusCode = e.statusCode;
        message = e.message;
      } else {
        statusCode = 500;
        message = 'Unexpected error';
        error = message;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? gender,
    int? age,
    File? profilePicture,
  }) async {
    loading = true;
    message = null;
    statusCode = null;
    error = null;
    notifyListeners();

    try {
      await repo.register(
        email: email,
        password: password,
        gender: gender,
        age: age,
        profilePicture: profilePicture,
      );

      statusCode = 201;
      message = 'Account created successfully';
    }
    catch (e) {
      if (e is ApiException) {
        statusCode = e.statusCode;
        message = e.message;
        error = e.message;
      } else {
        statusCode = 500;
        message = 'Unexpected error';
        error = message;
      }
    }

    finally {
      loading = false;
      notifyListeners();
    }
  }

  // ---------- FETCH PROFILE ----------
  Future<void> refreshProfile() async {
    loading = true;
    message = null;
    statusCode = null;
    notifyListeners();

    try {
      final profile = await repo.getProfile();
      user = profile;
      await SecureStorage.saveUser(profile);

      statusCode = 200;
      message = 'Profile refreshed';
    } catch (e) {
      if (e is ApiException) {
        statusCode = e.statusCode;
        message = e.message;
        error = e.message;
      } else {
        statusCode = 500;
        message = 'Unexpected error';
        error = message;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser({
    required String userId,
    String? password,
    String? gender,
    int? age,
    File? profilePicture,
  }) async {
    loading = true;
    message = null;
    statusCode = null;
    notifyListeners();

    try {
      await repo.updateUser(
        userId: userId,
        password: password,
        gender: gender,
        age: age,
        profilePicture: profilePicture,
      );

      statusCode = 200;
      message = 'Profile updated successfully';
    } catch (e) {
      if (e is ApiException) {
        statusCode = e.statusCode;
        message = e.message;
        error = e.message;
      } else {
        statusCode = 500;
        message = 'Unexpected error';
        error = message;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
    user = null;
    isLoggedIn = false;
    notifyListeners();
  }

  void clearResponse() {
    message = null;
    statusCode = null;
    error = null;
    notifyListeners();
  }

}
