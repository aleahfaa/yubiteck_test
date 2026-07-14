import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/session_store.dart';
import '../data/favorites_remote_data_source.dart';
import '../data/favorites_repository_impl.dart';
import '../domain/favorites_repository.dart';
import '../domain/get_favorite_movies.dart';
import '../domain/toggle_favorite.dart';
import 'favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesRemoteDataSource>(
      () => FavoritesRemoteDataSourceImpl(Get.find<DioClient>().dio),
    );
    Get.lazyPut<FavoritesRepository>(
      () => FavoritesRepositoryImpl(
        Get.find<FavoritesRemoteDataSource>(),
        Get.find<SessionStore>(),
      ),
    );
    Get.lazyPut(() => GetFavoriteMovies(Get.find<FavoritesRepository>()));
    Get.lazyPut(() => ToggleFavorite(Get.find<FavoritesRepository>()));
    Get.lazyPut(
      () => FavoritesController(
        Get.find<GetFavoriteMovies>(),
        Get.find<ToggleFavorite>(),
      ),
      fenix: true,
    );
  }
}
