import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../data/ratings_remote_data_source.dart';
import '../data/ratings_repository_impl.dart';
import '../domain/ratings_repository.dart';
import '../domain/delete_rating.dart';
import '../domain/rate_movie.dart';
import 'ratings_controller.dart';

class RatingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RatingsRemoteDataSource>(
      () => RatingsRemoteDataSourceImpl(Get.find<DioClient>().dio),
    );
    Get.lazyPut<RatingsRepository>(
      () => RatingsRepositoryImpl(Get.find<RatingsRemoteDataSource>()),
    );
    Get.lazyPut(() => RateMovie(Get.find<RatingsRepository>()));
    Get.lazyPut(() => DeleteRating(Get.find<RatingsRepository>()));
    Get.lazyPut(
      () => RatingsController(Get.find<RateMovie>(), Get.find<DeleteRating>()),
      fenix: true,
    );
  }
}
