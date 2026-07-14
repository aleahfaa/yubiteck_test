import 'package:dio/dio.dart';
import '../error/exceptions.dart';

class TmdbAuthInterceptor extends Interceptor {
  final String? Function() sessionIdProvider;
  TmdbAuthInterceptor({required this.sessionIdProvider});
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['requiresSession'] == true) {
      final sessionId = sessionIdProvider();
      if (sessionId == null || sessionId.isEmpty) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: const AuthException('No active TMDB session'),
          ),
        );
        return;
      }
      options.queryParameters['session_id'] = sessionId;
    }
    handler.next(options);
  }
}
