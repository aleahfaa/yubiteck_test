import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/features/favorites/domain/get_favorite_movies.dart';
import 'package:yubiteck_test/features/favorites/domain/toggle_favorite.dart';
import 'package:yubiteck_test/features/movies/domain/paginated_movies.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  test('GetFavoriteMovies delegates to the repository with the page', () async {
    final repository = MockFavoritesRepository();
    final usecase = GetFavoriteMovies(repository);
    const page = PaginatedMovies(
      page: 2,
      results: [],
      totalPages: 3,
      totalResults: 3,
    );
    when(
      () => repository.getFavoriteMovies(page: 2),
    ).thenAnswer((_) async => const Ok(page));

    final result = await usecase(2);

    expect(result.valueOrNull, page);
  });

  test(
    'ToggleFavorite delegates to the repository with movieId/favorite',
    () async {
      final repository = MockFavoritesRepository();
      final usecase = ToggleFavorite(repository);
      when(
        () => repository.setFavorite(movieId: 42, favorite: true),
      ).thenAnswer((_) async => const Ok(true));

      final result = await usecase(
        const ToggleFavoriteParams(movieId: 42, favorite: true),
      );

      expect(result.valueOrNull, isTrue);
      verify(
        () => repository.setFavorite(movieId: 42, favorite: true),
      ).called(1);
    },
  );
}
