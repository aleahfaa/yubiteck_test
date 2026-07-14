import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import 'account_states.dart';
import 'movie_detail.dart';
import 'movie_list_type.dart';
import 'paginated_movies.dart';

abstract interface class MoviesRepository {
  Future<Result<Failure, PaginatedMovies>> getMovies({
    required MovieListType type,
    required int page,
  });
  Future<Result<Failure, MovieDetail>> getMovieDetail(int id);
  Future<Result<Failure, AccountStates>> getAccountStates(int movieId);
}
