import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/network/result_guard.dart';
import '../../movies/domain/paginated_movies.dart';
import '../domain/search_repository.dart';
import 'search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remote;
  const SearchRepositoryImpl(this.remote);
  @override
  Future<Result<Failure, PaginatedMovies>> searchMovies({
    required String query,
    required int page,
  }) {
    return guardResult(() => remote.searchMovies(query: query, page: page));
  }
}
