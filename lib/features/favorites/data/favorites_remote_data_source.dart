import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_exception_mapper.dart';
import '../../movies/data/paginated_movies_model.dart';

abstract interface class FavoritesRemoteDataSource {
  Future<PaginatedMoviesModel> getFavoriteMovies({
    required int accountId,
    required int page,
  });
  Future<void> setFavorite({
    required int accountId,
    required int movieId,
    required bool favorite,
  });
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final Dio dio;
  const FavoritesRemoteDataSourceImpl(this.dio);
  @override
  Future<PaginatedMoviesModel> getFavoriteMovies({
    required int accountId,
    required int page,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.accountFavoriteMovies(accountId),
        queryParameters: {'page': page},
        options: Options(extra: {'requiresSession': true}),
      );
      return PaginatedMoviesModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> setFavorite({
    required int accountId,
    required int movieId,
    required bool favorite,
  }) async {
    try {
      await dio.post(
        ApiConstants.accountFavorite(accountId),
        data: {
          'media_type': 'movie',
          'media_id': movieId,
          'favorite': favorite,
        },
        options: Options(extra: {'requiresSession': true}),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
