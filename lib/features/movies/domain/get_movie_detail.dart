import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import 'movie_detail.dart';
import 'movies_repository.dart';

class GetMovieDetail implements UseCase<MovieDetail, int> {
  final MoviesRepository repository;
  const GetMovieDetail(this.repository);
  @override
  Future<Result<Failure, MovieDetail>> call(int movieId) {
    return repository.getMovieDetail(movieId);
  }
}
