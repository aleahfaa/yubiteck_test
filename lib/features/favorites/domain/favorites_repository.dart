import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../movies/domain/paginated_movies.dart';

abstract interface class FavoritesRepository {
  Future<Result<Failure, PaginatedMovies>> getFavoriteMovies({
    required int page,
  });
  Future<Result<Failure, bool>> setFavorite({
    required int movieId,
    required bool favorite,
  });
}
