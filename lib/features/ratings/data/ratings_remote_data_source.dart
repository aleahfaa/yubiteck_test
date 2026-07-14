import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_exception_mapper.dart';

abstract interface class RatingsRemoteDataSource {
  Future<void> rateMovie({required int movieId, required double value});
  Future<void> deleteRating(int movieId);
}

class RatingsRemoteDataSourceImpl implements RatingsRemoteDataSource {
  final Dio dio;
  const RatingsRemoteDataSourceImpl(this.dio);
  @override
  Future<void> rateMovie({required int movieId, required double value}) async {
    try {
      await dio.post(
        ApiConstants.movieRating(movieId),
        data: {'value': value},
        options: Options(extra: {'requiresSession': true}),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> deleteRating(int movieId) async {
    try {
      await dio.delete(
        ApiConstants.movieRating(movieId),
        options: Options(extra: {'requiresSession': true}),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
