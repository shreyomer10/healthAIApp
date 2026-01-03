import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Model/user_model.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';

  // ---------- TOKEN ----------
  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() =>
      _storage.read(key: _tokenKey);

  static Future<void> clearToken() =>
      _storage.delete(key: _tokenKey);

  // ---------- USER ----------
  static Future<void> saveUser(UserModel user) =>
      _storage.write(
        key: _userKey,
        value: jsonEncode(user.toJson()),
      );

  static Future<UserModel?> getUser() async {
    final data = await _storage.read(key: _userKey);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  // ---------- CLEAR ALL ----------
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
