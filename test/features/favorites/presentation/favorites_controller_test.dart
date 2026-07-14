import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/error/failures.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/core/presentation/view_state.dart';
import 'package:yubiteck_test/features/favorites/domain/toggle_favorite.dart';
import 'package:yubiteck_test/features/favorites/presentation/favorites_controller.dart';
import 'package:yubiteck_test/features/movies/domain/movie.dart';
import 'package:yubiteck_test/features/movies/domain/paginated_movies.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  late MockGetFavoriteMovies getFavoriteMovies;
  late MockToggleFavorite toggleFavorite;
  late FavoritesController controller;

  setUp(() {
    getFavoriteMovies = MockGetFavoriteMovies();
    toggleFavorite = MockToggleFavorite();
    controller = FavoritesController(getFavoriteMovies, toggleFavorite);
  });

  test('loadInitial seeds favoriteIds from the results', () async {
    when(() => getFavoriteMovies(1)).thenAnswer(
      (_) async => const Ok(
        PaginatedMovies(
          page: 1,
          results: [Movie(id: 1, title: 'A', overview: '')],
          totalPages: 1,
          totalResults: 1,
        ),
      ),
    );

    await controller.loadInitial();

    expect(controller.isFavorite(1), isTrue);
    expect(controller.state.value, isA<ViewLoaded<List<Movie>>>());
  });

  test(
    'toggleFavorite optimistically flips state before the call resolves',
    () async {
      final completer = Completer<void>();
      when(
        () => toggleFavorite(
          const ToggleFavoriteParams(movieId: 5, favorite: true),
        ),
      ).thenAnswer((_) async {
        await completer.future;
        return const Ok(true);
      });

      final future = controller.toggleFavorite(5);
      expect(
        controller.isFavorite(5),
        isTrue,
      ); // optimistic, before API resolves

      completer.complete();
      await future;

      expect(controller.isFavorite(5), isTrue);
    },
  );

  test('toggleFavorite rolls back on failure', () async {
    when(
      () => toggleFavorite(
        const ToggleFavoriteParams(movieId: 5, favorite: true),
      ),
    ).thenAnswer((_) async => const Err(ServerFailure('boom')));

    await controller.toggleFavorite(5);

    expect(controller.isFavorite(5), isFalse);
    expect(controller.actionError.value, 'boom');
  });

  test('toggling an already-favorited movie removes it', () async {
    controller.syncKnownState(5, favorited: true);
    when(
      () => toggleFavorite(
        const ToggleFavoriteParams(movieId: 5, favorite: false),
      ),
    ).thenAnswer((_) async => const Ok(false));

    await controller.toggleFavorite(5);

    expect(controller.isFavorite(5), isFalse);
  });
}
