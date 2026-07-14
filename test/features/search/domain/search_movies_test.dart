import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/features/movies/domain/paginated_movies.dart';
import 'package:yubiteck_test/features/search/domain/search_movies.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  test('delegates to the repository with the given query and page', () async {
    final repository = MockSearchRepository();
    final usecase = SearchMovies(repository);
    const page = PaginatedMovies(
      page: 2,
      results: [],
      totalPages: 5,
      totalResults: 100,
    );
    when(
      () => repository.searchMovies(query: 'batman', page: 2),
    ).thenAnswer((_) async => const Ok(page));

    final result = await usecase(
      const SearchMoviesParams(query: 'batman', page: 2),
    );

    expect(result.valueOrNull, page);
    verify(() => repository.searchMovies(query: 'batman', page: 2)).called(1);
  });
}
