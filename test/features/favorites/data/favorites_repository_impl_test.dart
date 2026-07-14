import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/error/failures.dart';
import 'package:yubiteck_test/core/services/session_store.dart';
import 'package:yubiteck_test/features/favorites/data/favorites_repository_impl.dart';
import 'package:yubiteck_test/features/movies/data/paginated_movies_model.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  late MockFavoritesRemoteDataSource remote;

  setUp(() {
    remote = MockFavoritesRemoteDataSource();
  });

  const emptyPage = PaginatedMoviesModel(
    page: 1,
    results: [],
    totalPages: 1,
    totalResults: 0,
  );

  test('getFavoriteMovies uses the account id from SessionStore', () async {
    final sessionStore = await sessionStoreWithAccountId(7);
    final repository = FavoritesRepositoryImpl(remote, sessionStore);
    when(
      () => remote.getFavoriteMovies(accountId: 7, page: 1),
    ).thenAnswer((_) async => emptyPage);

    final result = await repository.getFavoriteMovies(page: 1);

    expect(result.valueOrNull, emptyPage);
  });

  test('fails with AuthFailure when there is no account id', () async {
    final sessionStore = SessionStore(MockFlutterSecureStorage());
    final repository = FavoritesRepositoryImpl(remote, sessionStore);

    final result = await repository.getFavoriteMovies(page: 1);

    expect(result.failureOrNull, isA<AuthFailure>());
    verifyNever(
      () => remote.getFavoriteMovies(
        accountId: any(named: 'accountId'),
        page: any(named: 'page'),
      ),
    );
  });

  test('setFavorite returns the new favorite value on success', () async {
    final sessionStore = await sessionStoreWithAccountId(7);
    final repository = FavoritesRepositoryImpl(remote, sessionStore);
    when(
      () => remote.setFavorite(accountId: 7, movieId: 42, favorite: true),
    ).thenAnswer((_) async {});

    final result = await repository.setFavorite(movieId: 42, favorite: true);

    expect(result.valueOrNull, isTrue);
  });
}
