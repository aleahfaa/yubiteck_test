import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_exception_mapper.dart';
import 'account_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<String> createRequestToken();
  Future<String> createSession(String requestToken);
  Future<AccountModel> getAccountDetails();
  Future<void> deleteSession(String sessionId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  const AuthRemoteDataSourceImpl(this.dio);
  @override
  Future<String> createRequestToken() async {
    try {
      final response = await dio.get(ApiConstants.authRequestToken);
      final token = response.data['request_token'] as String?;
      if (token == null || token.isEmpty) {
        throw const ServerException('TMDB did not return a request token');
      }
      return token;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<String> createSession(String requestToken) async {
    try {
      final response = await dio.post(
        ApiConstants.authCreateSession,
        data: {'request_token': requestToken},
      );
      final sessionId = response.data['session_id'] as String?;
      if (sessionId == null || sessionId.isEmpty) {
        throw const AuthException(
          'TMDB rejected the request token — please try logging in again',
        );
      }
      return sessionId;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<AccountModel> getAccountDetails() async {
    try {
      final response = await dio.get(
        ApiConstants.account,
        options: Options(extra: {'requiresSession': true}),
      );
      return AccountModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await dio.delete(
        ApiConstants.authDeleteSession,
        data: {'session_id': sessionId},
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
