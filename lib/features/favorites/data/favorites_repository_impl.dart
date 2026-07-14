import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/network/result_guard.dart';
import '../../../core/services/session_store.dart';
import '../../movies/domain/paginated_movies.dart';
import '../domain/favorites_repository.dart';
import 'favorites_remote_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remote;
  final SessionStore sessionStore;
  const FavoritesRepositoryImpl(this.remote, this.sessionStore);
  int get _requireAccountId {
    final accountId = sessionStore.accountId;
    if (accountId == null) {
      throw const AuthException('Please log in to manage favorites');
    }
    return accountId;
  }

  @override
  Future<Result<Failure, PaginatedMovies>> getFavoriteMovies({
    required int page,
  }) {
    return guardResult(
      () => remote.getFavoriteMovies(accountId: _requireAccountId, page: page),
    );
  }

  @override
  Future<Result<Failure, bool>> setFavorite({
    required int movieId,
    required bool favorite,
  }) {
    return guardResult(() async {
      await remote.setFavorite(
        accountId: _requireAccountId,
        movieId: movieId,
        favorite: favorite,
      );
      return favorite;
    });
  }
}
