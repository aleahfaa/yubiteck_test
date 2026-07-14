import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_exception_mapper.dart';
import '../../movies/data/paginated_movies_model.dart';

abstract interface class SearchRemoteDataSource {
  Future<PaginatedMoviesModel> searchMovies({
    required String query,
    required int page,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio dio;
  SearchRemoteDataSourceImpl(this.dio);
  CancelToken? _activeCancelToken;
  @override
  Future<PaginatedMoviesModel> searchMovies({
    required String query,
    required int page,
  }) async {
    _activeCancelToken?.cancel('superseded by a newer search');
    final cancelToken = CancelToken();
    _activeCancelToken = cancelToken;
    try {
      final response = await dio.get(
        ApiConstants.searchMovie,
        queryParameters: {'query': query, 'page': page},
        cancelToken: cancelToken,
      );
      return PaginatedMoviesModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
