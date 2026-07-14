import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../favorites/presentation/favorites_binding.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../ratings/presentation/ratings_binding.dart';
import '../../ratings/presentation/ratings_controller.dart';
import '../data/movies_remote_data_source.dart';
import '../data/movies_repository_impl.dart';
import '../domain/movies_repository.dart';
import '../domain/get_account_states.dart';
import '../domain/get_movie_detail.dart';
import 'movie_detail_controller.dart';

class MovieDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoviesRemoteDataSource>(
      () => MoviesRemoteDataSourceImpl(Get.find<DioClient>().dio),
    );
    Get.lazyPut<MoviesRepository>(
      () => MoviesRepositoryImpl(Get.find<MoviesRemoteDataSource>()),
    );
    Get.lazyPut(() => GetMovieDetail(Get.find<MoviesRepository>()));
    Get.lazyPut(() => GetAccountStates(Get.find<MoviesRepository>()));
    FavoritesBinding().dependencies();
    RatingsBinding().dependencies();
    Get.lazyPut(
      () => MovieDetailController(
        Get.find<GetMovieDetail>(),
        Get.find<GetAccountStates>(),
        Get.find<AuthController>(),
        Get.find<FavoritesController>(),
        Get.find<RatingsController>(),
      ),
    );
  }
}
