import 'dart:io';
import 'package:dio/dio.dart';
import '../Model/scan_model.dart';
import '../Model/upload_response_model.dart';
import '../Model/user_model.dart';
import '../core/dio_error_handler.dart';

class AuthRepository {
  final Dio dio;
  AuthRepository(this.dio);

  // ---------- REGISTER ----------
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? gender,
    int? age,
    File? profilePicture,
  }) async {
    try{
      final formData = FormData.fromMap({
        'name':name,
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
    String? aiPersonalization,
    String? name,
  }) async {
    try{
      final formData = FormData.fromMap({
        'user_id': userId,
        if (gender != null) 'gender': gender,
        if (password != null) 'password': password,
        if (aiPersonalization != null) 'ai_prefernce': aiPersonalization,
        if (name != null) 'name': name,

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
  // ---------- GET USER PROFILE ----------
  Future<List<ScanModel>> getUserProfile() async {
    final res = await dio.get('/get-user-profile');

    final rawScans = res.data['scans'] as List;

    final scans = <ScanModel>[];

    for (final e in rawScans) {
      try {
        scans.add(ScanModel.fromJson(e));
      } catch (err) {
        // skip broken scan, don't kill the whole list
        //debugPrint('SKIPPED BAD SCAN => $err');
      }
    }

    return scans;
  }

  // ---------- GET CHAT ----------
  Future<ScanDetailModel> getChat(String chatId) async {
    final res = await dio.get(
      '/get-chat',
      queryParameters: {'chat_id': chatId},
    );

    return ScanDetailModel.fromJson(res.data);
  }

  Future<Map<String, dynamic>> loginWithGoogleRepo(String idToken) async {
    final res = await dio.post(
      '/login-with-google',
      data: {
        'id_token_str': idToken,
      },
    );

    // backend already returns a JSON-compatible map
    return res.data as Map<String, dynamic>;
  }

  // ---------- UPLOAD IMAGE / TEXT ----------
  Future<UploadResponse> uploadScan({
    File? image,
    String? text,
    String? language,
  }) async {
    final formData = FormData.fromMap({
      if (image != null)
        'file': await MultipartFile.fromFile(image.path),
      if (text != null) 'text': text,
      if (language!=null)'language':language
    });

    final res = await dio.post('/upload-image', data: formData);
    return UploadResponse.fromJson(res.data);
  }
  Future<UploadResponse> refineScan({


    required String scanId,
    required String text,
  }) async {
    final res = await dio.post(
      '/refine-scan',
      queryParameters: {
        'scan_id': scanId,
        'text': text,
      },
    );


    return UploadResponse(
      scanId: scanId,
      output: res.data['output'],
    );
  }

}
