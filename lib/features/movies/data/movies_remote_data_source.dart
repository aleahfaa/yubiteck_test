import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_exception_mapper.dart';
import '../domain/movie_list_type.dart';
import 'account_states_model.dart';
import 'movie_detail_model.dart';
import 'paginated_movies_model.dart';

abstract interface class MoviesRemoteDataSource {
  Future<PaginatedMoviesModel> getMovies({
    required MovieListType type,
    required int page,
  });
  Future<MovieDetailModel> getMovieDetail(int id);
  Future<AccountStatesModel> getAccountStates(int movieId);
}

class MoviesRemoteDataSourceImpl implements MoviesRemoteDataSource {
  final Dio dio;
  const MoviesRemoteDataSourceImpl(this.dio);
  static const Map<MovieListType, String> _endpoints = {
    MovieListType.popular: ApiConstants.moviePopular,
    MovieListType.nowPlaying: ApiConstants.movieNowPlaying,
    MovieListType.topRated: ApiConstants.movieTopRated,
    MovieListType.upcoming: ApiConstants.movieUpcoming,
  };
  @override
  Future<PaginatedMoviesModel> getMovies({
    required MovieListType type,
    required int page,
  }) async {
    try {
      final response = await dio.get(
        _endpoints[type]!,
        queryParameters: {'page': page},
      );
      return PaginatedMoviesModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<MovieDetailModel> getMovieDetail(int id) async {
    try {
      final response = await dio.get(
        ApiConstants.movieDetail(id),
        queryParameters: {'append_to_response': 'credits,videos'},
      );
      return MovieDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<AccountStatesModel> getAccountStates(int movieId) async {
    try {
      final response = await dio.get(
        ApiConstants.movieAccountStates(movieId),
        options: Options(extra: {'requiresSession': true}),
      );
      return AccountStatesModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
