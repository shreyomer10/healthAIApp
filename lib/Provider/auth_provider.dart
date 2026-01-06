import 'dart:developer' as AppLogger;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Model/scan_model.dart';
import '../Model/upload_response_model.dart';
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

  List<ScanModel> scans = [];

  UploadResponse? lastUpload;
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
    required String name,
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
        name:name,
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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  Future<void> loginWithGoogle() async {
    loading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      // Force account picker every time
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account =
      await _googleSignIn.signIn();

      if (account == null) {
        throw Exception("Login cancelled");
      }

      // THIS is all you’re getting
      final email = account.email;
      final name = account.displayName;
      final photo = account.photoUrl;

      // Fake-login locally
      user = UserModel(
        id:"id",
        email: email,
        name: name ?? '',
        profilePicture: photo,
      );

      isLoggedIn = true;

      // Optional: persist locally
      await SecureStorage.saveUser(user!);

    } catch (e) {
      error = e.toString();
      message = error;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ---------- LOAD PROFILE ----------
  Future<void> loadProfile() async {
    loading = true;
    error = null;
    message = null;
    statusCode = null;
    scans=[];
    notifyListeners();

    try {
      final result = await repo.getUserProfile();
    //  user = result.$1;
      scans = result;

      print('PROVIDER SCANS COUNT => ${scans.length}');

      await SecureStorage.saveUser(user!);

      statusCode = 200;
      message = 'Profile loaded';
    } catch (e) {
      print('LOAD PROFILE ERROR => $e');

      if (e is ApiException) {
        error = e.message;
        statusCode = e.statusCode;
        message = e.message;
      } else {
        error = 'Unexpected error';
        statusCode = 500;
        message = error;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<ScanDetailModel?> loadChat(String chatId) async {
    loading = true;
    message = null;
    statusCode = null;
    notifyListeners();

    try {
      final scan = await repo.getChat(chatId);
      return scan;
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

  Future<void> upload({
    File? image,
    String? text,
    String? language,
  }) async {
    loading = true;
    error = null;
    message = null;
    statusCode = null;
    notifyListeners();

    try {
      lastUpload = await repo.uploadScan(image: image, text: text,language: language);

      print('PROVIDER OUTPUT => ${lastUpload?.output}');

      statusCode = 201;
      message = 'Scan Completed';
    } catch (e) {
      if (e is ApiException) {
        error = e.message;
        statusCode = e.statusCode;
        message = e.message;
      } else {
        error = 'Unexpected error';
        print(e);

        statusCode = 500;
        message = error;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refineScan({
    required String scanId,
    required String text,
  }) async {
    loading=true;
    error = null;
    message = null;
    statusCode = null;
    notifyListeners();

    try {
      final res = await repo.refineScan(
        scanId: scanId,
        text: text,
      );

      // 🔥 overwrite only output
      lastUpload = UploadResponse(
        scanId: scanId,
        output: res.output,
        filename: lastUpload?.filename,
        imageUrl: lastUpload?.imageUrl,
      );
      statusCode = 200;
      message = 'Refining Completed';
    } catch (e) {
      if (e is ApiException) {
        error = e.message;
        statusCode = e.statusCode;
        message = e.message;
      } else {
        error = 'Unexpected error';
        print(e);
        statusCode = 500;
        message = error;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }



}
