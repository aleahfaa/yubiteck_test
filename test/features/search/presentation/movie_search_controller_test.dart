import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/core/presentation/view_state.dart';
import 'package:yubiteck_test/features/movies/domain/movie.dart';
import 'package:yubiteck_test/features/movies/domain/paginated_movies.dart';
import 'package:yubiteck_test/features/search/domain/search_movies.dart';
import 'package:yubiteck_test/features/search/presentation/movie_search_controller.dart';

import '../../../helpers/mock_helpers.dart';

PaginatedMovies _pageOf(String title) => PaginatedMovies(
  page: 1,
  results: [Movie(id: 1, title: title, overview: '')],
  totalPages: 1,
  totalResults: 1,
);

void main() {
  setUpAll(() {
    registerFallbackValue(const SearchMoviesParams(query: ''));
  });

  test('does not search until the debounce delay has fully elapsed', () {
    fakeAsync((async) {
      final searchMovies = MockSearchMovies();
      when(
        () => searchMovies(const SearchMoviesParams(query: 'a', page: 1)),
      ).thenAnswer((_) async => Ok(_pageOf('A')));
      final controller = MovieSearchController(searchMovies);

      controller.onQueryChanged('a');
      async.elapse(const Duration(milliseconds: 200));

      verifyNever(() => searchMovies(any()));
    });
  });

  test('resets the debounce timer on every keystroke, firing once', () {
    fakeAsync((async) {
      final searchMovies = MockSearchMovies();
      when(
        () => searchMovies(const SearchMoviesParams(query: 'ab', page: 1)),
      ).thenAnswer((_) async => Ok(_pageOf('AB')));
      final controller = MovieSearchController(searchMovies);

      controller.onQueryChanged('a');
      async.elapse(const Duration(milliseconds: 300));
      controller.onQueryChanged('ab');
      async.elapse(const Duration(milliseconds: 300));
      // Total elapsed since 'a' is 600ms > 450ms debounce, but the timer
      // was reset by 'ab' at the 300ms mark, so it fires 450ms after that.
      verifyNever(() => searchMovies(any()));

      async.elapse(const Duration(milliseconds: 200));

      verify(
        () => searchMovies(const SearchMoviesParams(query: 'ab', page: 1)),
      ).called(1);
    });
  });

  test('a slow stale response never overwrites a faster newer one', () {
    fakeAsync((async) {
      final searchMovies = MockSearchMovies();
      when(
        () => searchMovies(const SearchMoviesParams(query: 'a', page: 1)),
      ).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 2),
          () => Ok(_pageOf('Stale')),
        ),
      );
      when(
        () => searchMovies(const SearchMoviesParams(query: 'ab', page: 1)),
      ).thenAnswer((_) async => Ok(_pageOf('Fresh')));
      final controller = MovieSearchController(searchMovies);

      controller.onQueryChanged('a');
      async.elapse(const Duration(milliseconds: 450)); // fires slow 'a' search

      controller.onQueryChanged('ab');
      async.elapse(
        const Duration(milliseconds: 450),
      ); // fires fast 'ab' search, resolves immediately

      final freshState = controller.state.value as ViewLoaded<List<Movie>>;
      expect(freshState.data.single.title, 'Fresh');

      async.elapse(const Duration(seconds: 2)); // stale 'a' now resolves

      final finalState = controller.state.value as ViewLoaded<List<Movie>>;
      expect(finalState.data.single.title, 'Fresh');
    });
  });

  test('clearing the query cancels the pending debounce and resets state', () {
    fakeAsync((async) {
      final searchMovies = MockSearchMovies();
      final controller = MovieSearchController(searchMovies);

      controller.onQueryChanged('batman');
      controller.onQueryChanged('');
      async.elapse(const Duration(seconds: 1));

      verifyNever(() => searchMovies(any()));
      expect(controller.state.value, isA<ViewIdle<List<Movie>>>());
    });
  });

  test('loadMore appends the next page and stops once exhausted', () async {
    final searchMovies = MockSearchMovies();
    when(
      () => searchMovies(const SearchMoviesParams(query: 'batman', page: 1)),
    ).thenAnswer(
      (_) async => const Ok(
        PaginatedMovies(
          page: 1,
          results: [Movie(id: 1, title: 'Batman Begins', overview: '')],
          totalPages: 2,
          totalResults: 2,
        ),
      ),
    );
    when(
      () => searchMovies(const SearchMoviesParams(query: 'batman', page: 2)),
    ).thenAnswer(
      (_) async => const Ok(
        PaginatedMovies(
          page: 2,
          results: [Movie(id: 2, title: 'The Dark Knight', overview: '')],
          totalPages: 2,
          totalResults: 2,
        ),
      ),
    );
    // Use a zero-delay debouncer so this test doesn't need fakeAsync.
    final fast = MovieSearchController(
      searchMovies,
      debounceDuration: Duration.zero,
    );
    fast.onQueryChanged('batman');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    await fast.loadMore();

    final state = fast.state.value as ViewLoaded<List<Movie>>;
    expect(state.data.map((m) => m.title), [
      'Batman Begins',
      'The Dark Knight',
    ]);
    expect(fast.hasMore, isFalse);
  });
}
