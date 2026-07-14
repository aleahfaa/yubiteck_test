import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/error/failures.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/core/presentation/view_state.dart';
import 'package:yubiteck_test/features/movies/domain/movie.dart';
import 'package:yubiteck_test/features/movies/domain/movie_list_type.dart';
import 'package:yubiteck_test/features/movies/domain/paginated_movies.dart';
import 'package:yubiteck_test/features/movies/domain/get_movies.dart';
import 'package:yubiteck_test/features/movies/presentation/movies_controller.dart';

import '../../../helpers/mock_helpers.dart';

Movie _movie(int id) => Movie(id: id, title: 'Movie $id', overview: '');

void main() {
  late MockGetMovies getMovies;
  late MoviesController controller;

  tearDown(Get.reset);

  setUp(() {
    getMovies = MockGetMovies();
    // onInit() eagerly loads all four categories — stub every one up front.
    for (final type in MovieListType.values) {
      when(() => getMovies(GetMoviesParams(type: type, page: 1))).thenAnswer(
        (_) async => Ok(
          PaginatedMovies(
            page: 1,
            results: [_movie(1)],
            totalPages: 2,
            totalResults: 2,
          ),
        ),
      );
    }
    controller = MoviesController(getMovies);
    Get.put(controller);
  });

  test('onInit loads the first page for every category', () async {
    // Constructor already triggered onInit via GetxController lifecycle
    // once put(); allow the pending futures to resolve.
    await Future<void>.delayed(Duration.zero);

    for (final type in MovieListType.values) {
      final state = controller.sectionFor(type).state.value;
      expect(state, isA<ViewLoaded<List<Movie>>>());
      expect((state as ViewLoaded<List<Movie>>).data, hasLength(1));
    }
  });

  test('loadMore appends results and advances the page', () async {
    await Future<void>.delayed(Duration.zero);

    when(
      () => getMovies(
        const GetMoviesParams(type: MovieListType.popular, page: 2),
      ),
    ).thenAnswer(
      (_) async => Ok(
        PaginatedMovies(
          page: 2,
          results: [_movie(2)],
          totalPages: 2,
          totalResults: 2,
        ),
      ),
    );

    await controller.loadMore(MovieListType.popular);

    final state =
        controller.sectionFor(MovieListType.popular).state.value
            as ViewLoaded<List<Movie>>;
    expect(state.data, hasLength(2));
    expect(controller.sectionFor(MovieListType.popular).hasMore, isFalse);
  });

  test('loadMore is a no-op once hasMore is false', () async {
    await Future<void>.delayed(Duration.zero);
    when(
      () => getMovies(
        const GetMoviesParams(type: MovieListType.popular, page: 2),
      ),
    ).thenAnswer(
      (_) async => Ok(
        PaginatedMovies(
          page: 2,
          results: [_movie(2)],
          totalPages: 2,
          totalResults: 2,
        ),
      ),
    );
    await controller.loadMore(MovieListType.popular);

    await controller.loadMore(MovieListType.popular);

    verify(
      () => getMovies(
        const GetMoviesParams(type: MovieListType.popular, page: 2),
      ),
    ).called(1);
  });

  test('a failed loadInitial surfaces ViewFailure', () async {
    when(
      () => getMovies(
        const GetMoviesParams(type: MovieListType.upcoming, page: 1),
      ),
    ).thenAnswer((_) async => const Err(ServerFailure('boom')));

    await controller.loadInitial(MovieListType.upcoming);

    expect(
      controller.sectionFor(MovieListType.upcoming).state.value,
      isA<ViewFailure<List<Movie>>>(),
    );
  });
}
