import 'package:get/get.dart';
import '../../../core/presentation/view_state.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../ratings/presentation/ratings_controller.dart';
import '../domain/movie_detail.dart';
import '../domain/get_account_states.dart';
import '../domain/get_movie_detail.dart';

class MovieDetailController extends GetxController {
  final GetMovieDetail getMovieDetail;
  final GetAccountStates getAccountStates;
  final AuthController authController;
  final FavoritesController favoritesController;
  final RatingsController ratingsController;
  MovieDetailController(
    this.getMovieDetail,
    this.getAccountStates,
    this.authController,
    this.favoritesController,
    this.ratingsController,
  );
  final Rx<ViewState<MovieDetail>> state = Rx<ViewState<MovieDetail>>(
    const ViewLoading(),
  );
  @override
  void onInit() {
    super.onInit();
    final id = int.tryParse(Get.parameters['id'] ?? '');
    if (id != null) load(id);
  }

  Future<void> load(int movieId) async {
    state.value = const ViewLoading();
    final result = await getMovieDetail(movieId);
    result.fold(
      (failure) => state.value = ViewFailure(failure.message),
      (detail) => state.value = ViewLoaded(detail),
    );
    if (authController.isAuthenticated) {
      final statesResult = await getAccountStates(movieId);
      statesResult.fold((_) {}, (states) {
        favoritesController.syncKnownState(
          movieId,
          favorited: states.favorited,
        );
        ratingsController.syncKnownState(
          movieId,
          ratedValue: states.ratedValue,
        );
      });
    }
  }
}
