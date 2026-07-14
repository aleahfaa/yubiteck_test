import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yubiteck_test/features/search/data/search_remote_data_source.dart';

ResponseBody _jsonResponseBody(Map<String, dynamic> json) {
  return ResponseBody.fromString(
    jsonEncode(json),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// Holds each request open until the test completes it, so a second call
/// can arrive while the first is still "in flight" on the network.
class _HeldRequestsAdapter implements HttpClientAdapter {
  final Map<String, Completer<ResponseBody>> completers = {};

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final query = options.queryParameters['query'] as String;
    final completer = Completer<ResponseBody>();
    completers[query] = completer;
    cancelFuture?.then((_) {
      if (!completer.isCompleted) {
        completer.completeError(
          DioException(requestOptions: options, type: DioExceptionType.cancel),
        );
      }
    });
    return completer.future;
  }
}

void main() {
  test(
    'cancels the previous in-flight search when a newer one starts',
    () async {
      final adapter = _HeldRequestsAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
        ..httpClientAdapter = adapter;
      final datasource = SearchRemoteDataSourceImpl(dio);

      final first = datasource.searchMovies(query: 'batman', page: 1);
      // Let Dio's pipeline (interceptors/transformer) reach the fake
      // adapter and register the "batman" completer.
      await pumpEventQueue();
      expect(adapter.completers.containsKey('batman'), isTrue);

      // Attach the failure expectation *before* triggering cancellation so
      // the rejection is never briefly "unhandled" in the test zone.
      final firstRejects = expectLater(first, throwsA(isA<Exception>()));

      final second = datasource.searchMovies(query: 'superman', page: 1);
      await pumpEventQueue();
      expect(adapter.completers.containsKey('superman'), isTrue);

      await firstRejects;

      adapter.completers['superman']!.complete(
        _jsonResponseBody({
          'page': 1,
          'total_pages': 1,
          'total_results': 0,
          'results': [],
        }),
      );
      final result = await second;
      expect(result.page, 1);
    },
  );
}
