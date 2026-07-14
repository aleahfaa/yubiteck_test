import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/error/exceptions.dart';
import 'package:yubiteck_test/core/error/failures.dart';
import 'package:yubiteck_test/features/movies/data/paginated_movies_model.dart';
import 'package:yubiteck_test/features/search/data/search_repository_impl.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  late MockSearchRemoteDataSource remote;
  late SearchRepositoryImpl repository;

  setUp(() {
    remote = MockSearchRemoteDataSource();
    repository = SearchRepositoryImpl(remote);
  });

  const page = PaginatedMoviesModel(
    page: 1,
    results: [],
    totalPages: 1,
    totalResults: 0,
  );

  test('returns Ok with the paginated results on success', () async {
    when(
      () => remote.searchMovies(query: 'batman', page: 1),
    ).thenAnswer((_) async => page);

    final result = await repository.searchMovies(query: 'batman', page: 1);

    expect(result.valueOrNull, page);
  });

  test('maps NetworkException to NetworkFailure', () async {
    when(
      () => remote.searchMovies(query: 'batman', page: 1),
    ).thenThrow(const NetworkException());

    final result = await repository.searchMovies(query: 'batman', page: 1);

    expect(result.failureOrNull, isA<NetworkFailure>());
  });
}
