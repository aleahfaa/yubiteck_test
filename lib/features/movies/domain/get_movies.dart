import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import 'movie_list_type.dart';
import 'paginated_movies.dart';
import 'movies_repository.dart';

class GetMoviesParams extends Equatable {
  final MovieListType type;
  final int page;
  const GetMoviesParams({required this.type, this.page = 1});
  @override
  List<Object?> get props => [type, page];
}

class GetMovies implements UseCase<PaginatedMovies, GetMoviesParams> {
  final MoviesRepository repository;
  const GetMovies(this.repository);
  @override
  Future<Result<Failure, PaginatedMovies>> call(GetMoviesParams params) {
    return repository.getMovies(type: params.type, page: params.page);
  }
}
