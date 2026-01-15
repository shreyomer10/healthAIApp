import 'package:dio/dio.dart';
import 'appConstants.dart';
import 'auth_interceptor.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(minutes: 3),
    receiveTimeout: const Duration(minutes: 3),
    headers: {'Content-Type': 'application/json'},
  ),
)..interceptors.add(AuthInterceptor());
