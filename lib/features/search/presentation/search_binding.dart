import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../data/search_remote_data_source.dart';
import '../data/search_repository_impl.dart';
import '../domain/search_repository.dart';
import '../domain/search_movies.dart';
import 'movie_search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchRemoteDataSource>(
      () => SearchRemoteDataSourceImpl(Get.find<DioClient>().dio),
    );
    Get.lazyPut<SearchRepository>(
      () => SearchRepositoryImpl(Get.find<SearchRemoteDataSource>()),
    );
    Get.lazyPut(() => SearchMovies(Get.find<SearchRepository>()));
    Get.lazyPut(() => MovieSearchController(Get.find<SearchMovies>()));
  }
}
