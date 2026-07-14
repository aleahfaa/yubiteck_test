import 'package:dio/dio.dart';
import '../config/env.dart';
import '../constants/api_constants.dart';
import 'logging_interceptor.dart';
import 'tmdb_auth_interceptor.dart';

class DioClient {
  final Dio dio;
  DioClient({required String? Function() sessionIdProvider})
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Authorization': 'Bearer ${Env.tmdbReadAccessToken}',
            'Content-Type': 'application/json;charset=utf-8',
          },
        ),
      ) {
    dio.interceptors.addAll([
      TmdbAuthInterceptor(sessionIdProvider: sessionIdProvider),
      LoggingInterceptor(),
    ]);
  }
}
