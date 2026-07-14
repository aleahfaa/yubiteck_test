import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../movies/domain/paginated_movies.dart';

abstract interface class SearchRepository {
  Future<Result<Failure, PaginatedMovies>> searchMovies({
    required String query,
    required int page,
  });
}
