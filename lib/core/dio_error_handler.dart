import 'package:dio/dio.dart';
import 'api_exception.dart';

ApiException handleDioError(DioException e) {
  if (e.response != null) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    // FastAPI validation error
    if (status == 422 && data is Map && data['detail'] != null) {
      return ApiException(
        data['detail'][0]['msg'] ?? 'Validation error',
        statusCode: status,
      );
    }

    // Custom FastAPI HTTPException
    if (data is Map && data['detail'] != null) {
      return ApiException(
        data['detail'].toString(),
        statusCode: status,
      );
    }

    return ApiException(
      'Request failed ($status)',
      statusCode: status,
    );
  }

  // Network / timeout
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return ApiException('Network timeout');
  }

  return ApiException('Something went wrong');
}
