import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yubiteck_test/core/error/exceptions.dart';
import 'package:yubiteck_test/core/network/tmdb_auth_interceptor.dart';

/// Fails the test loudly if a request ever reaches the network — every
/// case below should be resolved entirely within the interceptor chain.
class _UnreachableAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw StateError('Request unexpectedly reached the network adapter');
  }
}

Dio _buildDio(TmdbAuthInterceptor interceptor) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
  dio.httpClientAdapter = _UnreachableAdapter();
  dio.interceptors.add(interceptor);
  return dio;
}

void main() {
  test('attaches session_id when a session is available', () async {
    late RequestOptions captured;
    final dio = _buildDio(
      TmdbAuthInterceptor(sessionIdProvider: () => 'abc123'),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
            ),
          );
        },
      ),
    );

    await expectLater(
      dio.get(
        '/account/1/favorite',
        options: Options(extra: {'requiresSession': true}),
      ),
      throwsA(isA<DioException>()),
    );
    expect(captured.queryParameters['session_id'], 'abc123');
  });

  test('rejects with AuthException when no session is available', () async {
    final dio = _buildDio(TmdbAuthInterceptor(sessionIdProvider: () => null));

    await expectLater(
      dio.get(
        '/account/1/favorite',
        options: Options(extra: {'requiresSession': true}),
      ),
      throwsA(
        isA<DioException>().having(
          (e) => e.error,
          'error',
          isA<AuthException>(),
        ),
      ),
    );
  });

  test('leaves requests without requiresSession untouched', () async {
    late RequestOptions captured;
    final dio = _buildDio(TmdbAuthInterceptor(sessionIdProvider: () => null));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
            ),
          );
        },
      ),
    );

    await expectLater(dio.get('/movie/popular'), throwsA(isA<DioException>()));
    expect(captured.queryParameters.containsKey('session_id'), isFalse);
  });
}
