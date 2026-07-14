import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../movies/domain/paginated_movies.dart';
import 'favorites_repository.dart';

class GetFavoriteMovies implements UseCase<PaginatedMovies, int> {
  final FavoritesRepository repository;
  const GetFavoriteMovies(this.repository);
  @override
  Future<Result<Failure, PaginatedMovies>> call(int page) {
    return repository.getFavoriteMovies(page: page);
  }
}
