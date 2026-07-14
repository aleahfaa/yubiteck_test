import 'package:dio/dio.dart';
import '../error/exceptions.dart';

Exception mapDioException(DioException error) {
  final wrapped = error.error;
  if (wrapped is AuthException) return wrapped;
  switch (error.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkException();
    default:
      final data = error.response?.data;
      final message = data is Map && data['status_message'] is String
          ? data['status_message'] as String
          : (error.message ?? 'Something went wrong');
      return ServerException(message, statusCode: error.response?.statusCode);
  }
}
