import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../data/movies_remote_data_source.dart';
import '../data/movies_repository_impl.dart';
import '../domain/movies_repository.dart';
import '../domain/get_movies.dart';
import 'movies_controller.dart';

class MoviesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoviesRemoteDataSource>(
      () => MoviesRemoteDataSourceImpl(Get.find<DioClient>().dio),
    );
    Get.lazyPut<MoviesRepository>(
      () => MoviesRepositoryImpl(Get.find<MoviesRemoteDataSource>()),
    );
    Get.lazyPut(() => GetMovies(Get.find<MoviesRepository>()));
    Get.lazyPut(() => MoviesController(Get.find<GetMovies>()));
  }
}
