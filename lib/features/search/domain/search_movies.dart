import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../movies/domain/paginated_movies.dart';
import 'search_repository.dart';

class SearchMoviesParams extends Equatable {
  final String query;
  final int page;
  const SearchMoviesParams({required this.query, this.page = 1});
  @override
  List<Object?> get props => [query, page];
}

class SearchMovies implements UseCase<PaginatedMovies, SearchMoviesParams> {
  final SearchRepository repository;
  const SearchMovies(this.repository);
  @override
  Future<Result<Failure, PaginatedMovies>> call(SearchMoviesParams params) {
    return repository.searchMovies(query: params.query, page: params.page);
  }
}
