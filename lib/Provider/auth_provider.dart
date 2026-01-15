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

  bool isLoggedIn = false;
  UserModel? user;

  AuthProvider(this.repo);

  List<ScanModel> scans = [];

  ScanResult? lastUpload;
  Future<void> checkLogin() async {
    final token = await SecureStorage.getToken();
    final storedUser = await SecureStorage.getUser();

    if (token != null && storedUser != null) {
      user = storedUser;
      isLoggedIn = true;
    }
    notifyListeners();
  }




  Future<Map<String, dynamic>> login(String email, String password) async {
    print('[AUTH] LOGIN_START: $email');

    try {
      final (token, user) = await repo.login(email, password);

      await SecureStorage.saveToken(token);
      await SecureStorage.saveUser(user);

      this.user = user;
      isLoggedIn = true;

      print('[AUTH] LOGIN_SUCCESS => userId=${user.id}');

      return {
        'success': true,
        'message': 'Login successful',
        'error': null,
        'code': 200,
      };
    } catch (e) {
      print('[AUTH] LOGIN_ERROR => $e');

      if (e is ApiException) {
        return {
          'success': false,
          'message': e.message,
          'error': e.message,
          'code': e.statusCode,
        };
      }

      return {
        'success': false,
        'message': 'Unexpected error',
        'error': 'Unexpected error',
        'code': 500,
      };
    }
  }
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? gender,
    int? age,
    File? profilePicture,
  }) async {
    print('[AUTH] REGISTER_START => $email $name');

    try {
      await repo.register(
        name: name,
        email: email,
        password: password,
        gender: gender,
        age: age,
        profilePicture: profilePicture,
      );

      print('[AUTH] REGISTER_SUCCESS');

      return {
        'success': true,
        'message': 'Account created successfully',
        'error': null,
        'code': 201,
      };
    } catch (e) {
      print('[AUTH] REGISTER_ERROR => $e');

      if (e is ApiException) {
        return {
          'success': false,
          'message': e.message,
          'error': e.message,
          'code': e.statusCode,
        };
      }

      return {
        'success': false,
        'message': 'Unexpected error',
        'error': 'Unexpected error',
        'code': 500,
      };
    }
  }


  Future<Map<String, dynamic>> refreshProfile() async {
    print('[AUTH] REFRESH_PROFILE_START');

    try {
      final profile = await repo.getProfile();

      user = profile;
      await SecureStorage.saveUser(profile);
      notifyListeners(); // valid here

      print('[AUTH] REFRESH_PROFILE_SUCCESS');

      return {
        'success': true,
        'message': 'Profile refreshed',
        'error': null,
        'code': 200,
      };
    } catch (e) {
      print('[AUTH] REFRESH_PROFILE_ERROR => $e');

      if (e is ApiException) {
        return {
          'success': false,
          'message': e.message,
          'error': e.message,
          'code': e.statusCode,
        };
      }

      return {
        'success': false,
        'message': 'Unexpected error',
        'error': 'Unexpected error',
        'code': 500,
      };
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    String? name,
    String? password,
    String? gender,
    int? age,
    String? aiPersonalization,
    File? profilePicture,
  }) async {
    print('[AUTH] UPDATE_USER_START => $userId');

    try {
      await repo.updateUser(
        userId: userId,
        name: name,
        password: password,
        gender: gender,
        age: age,
        aiPersonalization: aiPersonalization,
        profilePicture: profilePicture,
      );

      print('[AUTH] UPDATE_USER_SUCCESS');

      user = user!.copyWith(
        name: name ?? user!.name,
        gender: gender ?? user!.gender,
        age: age ?? user!.age,
        aiPersonalization: aiPersonalization?? user!.aiPersonalization
      );
      await SecureStorage.saveUser(user!);
      notifyListeners();



      return {
        'success': true,
        'message': 'Profile updated successfully',
        'error': null,
        'code': 200,
      };
    } catch (e) {
      print('[AUTH] UPDATE_USER_ERROR => $e');

      if (e is ApiException) {
        return {
          'success': false,
          'message': e.message,
          'error': e.message,
          'code': e.statusCode,
        };
      }

      return {
        'success': false,
        'message': 'Unexpected error',
        'error': 'Unexpected error',
        'code': 500,
      };
    }
  }


  Future<void> logout() async {
    await SecureStorage.clearAll();
    user = null;
    isLoggedIn = false;
    notifyListeners();
  }


  final googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: "521219836634-lqvvqrpt3406u79vv83agj5q8q4lgovd.apps.googleusercontent.com",
  );

  Future<Map<String, dynamic>> loginWithGoogle() async {
    print('[AUTH] GOOGLE_LOGIN_START');

    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        return {
          'success': false,
          'code': 400,
          'error': 'Login cancelled'
        };
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        await googleSignIn.signOut();
        return {
          'success': false,
          'code': 500,
          'error': 'Missing idToken'
        };
      }

      final email = account.email;
      final name = account.displayName;
      final photo = account.photoUrl;
      final googleId = account.id;

      // hit backend
      final backendResp = await repo.loginWithGoogleRepo(idToken);

      // backend failed → clear google session so user picks new account
      if (backendResp == null || backendResp['access_token'] == null) {
        await googleSignIn.signOut();
        return {
          'success': false,
          'code': 401,
          'error': 'Google backend validation failed'
        };
      }

      print('[AUTH] GOOGLE_LOGIN_SUCCESS => email=$email');

      final token = backendResp['access_token'];
      final backendUser = backendResp['user'];

      // persist like login(email,password)
      await SecureStorage.saveToken(token);
      await SecureStorage.saveUser(UserModel.fromJson(backendUser));

      this.user = UserModel.fromJson(backendUser);
      isLoggedIn = true;

      return {
        'success': true,
        'code': 200,
        'message': 'Login successful',
        'error': null,
        'data': {
          'email': email,
          'name': name,
          'photo': photo,
          'googleId': googleId,
        }
      };

    } catch (e) {
      print('[AUTH] GOOGLE_LOGIN_ERROR => $e');

      // ensure switch account works even if exception
      await googleSignIn.signOut();

      return {
        'success': false,
        'code': 500,
        'error': e.toString()
      };
    }
  }

  // ---------- LOAD PROFILE ----------
  Future<Map<String, dynamic>> loadProfile() async {
    print('[AUTH] LOAD_PROFILE_START');

    try {
      final  scans = await repo.getUserProfile(); // adjust signature

      this.scans = scans;

      print('[AUTH] LOAD_PROFILE_SUCCESS => scans=${scans.length}');

      return {
        'success': true,
        'message': 'Profile loaded',
        'error': null,
        'code': 200,
        'scans': scans,
      };

    } catch (e) {
      print('[AUTH] LOAD_PROFILE_ERROR => $e');

      if (e is ApiException) {
        return {
          'success': false,
          'message': e.message,
          'error': e.message,
          'code': e.statusCode,
        };
      }

      return {
        'success': false,
        'message': 'Unexpected error',
        'error': 'Unexpected error',
        'code': 500,
      };
    }
  }

  Future<Map<String, dynamic>> loadChat(String chatId) async {
    print('[AUTH] LOAD_CHAT_START => $chatId');

    try {
      final scan = await repo.getChat(chatId);

      print('[AUTH] LOAD_CHAT_SUCCESS');

      return {
        'success': true,
        'chat': scan,
        'error': null,
        'code': 200,
      };

    } catch (e) {
      print('[AUTH] LOAD_CHAT_ERROR => $e');

      if (e is ApiException) {
        return {
          'success': false,
          'chat': null,
          'error': e.message,
          'message': e.message,
          'code': e.statusCode,
        };
      }

      return {
        'success': false,
        'chat': null,
        'error': 'Unexpected error',
        'message': 'Unexpected error',
        'code': 500,
      };
    }
  }


  Future<Map<String, dynamic>> upload({
    File? image,
    String? text,
    String? language,
  }) async {
    print('[SCAN] UPLOAD_START');

    try {
      final res = await repo.uploadScan(
        image: image,
        text: text,
        language: language,
      );

      final scan = ScanResult.fromUpload(res, language: language);

      // store if needed for refine chain
      lastUpload = scan;

      print('[SCAN] UPLOAD_SUCCESS');

      return {
        'success': true,
        'scan': scan,
        'error': null,
        'code': 201,
        'message': 'Scan Completed',
      };

    } catch (e) {
      print('[SCAN] UPLOAD_ERROR => $e');

      if (e is ApiException) {
        return {
          'success': false,
          'scan': null,
          'error': e.message,
          'code': e.statusCode,
          'message': e.message,
        };
      }

      return {
        'success': false,
        'scan': null,
        'error': 'Unexpected error',
        'code': 500,
        'message': 'Unexpected error',
      };
    }
  }


  Future<Map<String, dynamic>> refineScan({
    required String scanId,
    required String text,
  }) async {
    print('[SCAN] REFINE_START => $scanId');

    try {
      await repo.refineScan(
        scanId: scanId,
        text: text,
      );

      print('[SCAN] REFINE_SUCCESS');

      return {
        'success': true,
        'message': 'Refining Completed',
      };
    } catch (e) {
      print('[SCAN] REFINE_ERROR => $e');

      if (e is ApiException) {
        return {
          'success': false,
          'message': e.message,
        };
      }

      return {
        'success': false,
        'message': 'Unexpected error',
      };
    }
  }


}
