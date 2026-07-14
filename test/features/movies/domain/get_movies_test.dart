import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/features/movies/domain/movie_list_type.dart';
import 'package:yubiteck_test/features/movies/domain/paginated_movies.dart';
import 'package:yubiteck_test/features/movies/domain/get_movies.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  late MockMoviesRepository repository;
  late GetMovies usecase;

  setUp(() {
    repository = MockMoviesRepository();
    usecase = GetMovies(repository);
  });

  const page = PaginatedMovies(
    page: 1,
    results: [],
    totalPages: 1,
    totalResults: 0,
  );

  test('delegates to the repository with the given type and page', () async {
    when(
      () => repository.getMovies(type: MovieListType.topRated, page: 3),
    ).thenAnswer((_) async => const Ok(page));

    final result = await usecase(
      const GetMoviesParams(type: MovieListType.topRated, page: 3),
    );

    expect(result.valueOrNull, page);
    verify(
      () => repository.getMovies(type: MovieListType.topRated, page: 3),
    ).called(1);
  });

  test('defaults to page 1 when not specified', () async {
    when(
      () => repository.getMovies(type: MovieListType.popular, page: 1),
    ).thenAnswer((_) async => const Ok(page));

    await usecase(const GetMoviesParams(type: MovieListType.popular));

    verify(
      () => repository.getMovies(type: MovieListType.popular, page: 1),
    ).called(1);
  });
}
