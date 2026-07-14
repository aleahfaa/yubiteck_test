import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/network/result_guard.dart';
import '../domain/account_states.dart';
import '../domain/movie_detail.dart';
import '../domain/movie_list_type.dart';
import '../domain/paginated_movies.dart';
import '../domain/movies_repository.dart';
import 'movies_remote_data_source.dart';

class MoviesRepositoryImpl implements MoviesRepository {
  final MoviesRemoteDataSource remote;
  const MoviesRepositoryImpl(this.remote);
  @override
  Future<Result<Failure, PaginatedMovies>> getMovies({
    required MovieListType type,
    required int page,
  }) {
    return guardResult(() => remote.getMovies(type: type, page: page));
  }

  @override
  Future<Result<Failure, MovieDetail>> getMovieDetail(int id) {
    return guardResult(() => remote.getMovieDetail(id));
  }

  @override
  Future<Result<Failure, AccountStates>> getAccountStates(int movieId) {
    return guardResult(() => remote.getAccountStates(movieId));
  }
}
