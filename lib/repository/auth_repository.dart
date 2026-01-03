import 'dart:io';
import 'package:dio/dio.dart';
import '../Model/user_model.dart';
import '../core/dio_error_handler.dart';

class AuthRepository {
  final Dio dio;
  AuthRepository(this.dio);

  // ---------- REGISTER ----------
  Future<void> register({
    required String email,
    required String password,
    String? gender,
    int? age,
    File? profilePicture,
  }) async {
    try{
      final formData = FormData.fromMap({
        'email': email,
        'password': password,
        if (gender != null) 'gender': gender,
        if (age != null) 'age': age,
        if (profilePicture != null)
          'profile_picture': await MultipartFile.fromFile(profilePicture.path),
      });

      await dio.post('/register', data: formData);
    } on DioException catch (e) {
      throw handleDioError(e);
    }

  }

// ---------- LOGIN (JSON) ----------
  Future<(String, UserModel)> login(String email, String password) async {
    try{
      final res = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      // print('RAW RESPONSE => ${res.data}');
      // print('TYPE => ${res.data.runtimeType}');
      // print('USER_PRESENT => ${res.data['user_present']}');
      // print('USER_PRESENT TYPE => ${res.data['user_present']?.runtimeType}');

      final String token = res.data['access_token'];
      final UserModel user = UserModel.fromJson(res.data['user_present']);
      // print(token);
      // print(user.email);
      return (token, user);
    }on DioException catch (e) {
      // print("repo");
      // print(e);

      throw handleDioError(e);
    }

  }


  // // ---------- OAUTH LOGIN ----------
  // Future<String> oauthLogin(String email, String password) async {
  //   final res = await dio.post(
  //     '/token',
  //     data: {
  //       'username': email,
  //       'password': password,
  //     },
  //     options: Options(
  //       contentType: Headers.formUrlEncodedContentType,
  //     ),
  //   );
  //   return res.data['access_token'];
  // }

  // ---------- GET PROFILE ----------
  Future<UserModel> getProfile() async {
    try{
      final res = await dio.get('/get-user-profile');
      return UserModel.fromJson(res.data['user']);
    }
    on DioException catch (e) {
      throw handleDioError(e);
    }

  }

  // ---------- UPDATE USER ----------
  Future<void> updateUser({
    required String userId,
    String? gender,
    String? password,
    int? age,
    File? profilePicture,
  }) async {
    try{
      final formData = FormData.fromMap({
        'user_id': userId,
        if (gender != null) 'gender': gender,
        if (password != null) 'password': password,

        if (age != null) 'age': age,
        if (profilePicture != null)
          'profile_picture': await MultipartFile.fromFile(profilePicture.path),
      });

      await dio.put('/update-user', data: formData);
    }
    on DioException catch (e) {
      throw handleDioError(e);
    }

  }
}
