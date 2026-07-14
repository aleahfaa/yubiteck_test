import 'package:get/get.dart';
import '../../../core/presentation/view_state.dart';
import '../../movies/domain/movie.dart';
import '../domain/get_favorite_movies.dart';
import '../domain/toggle_favorite.dart';

class FavoritesController extends GetxController {
  final GetFavoriteMovies getFavoriteMovies;
  final ToggleFavorite toggleFavoriteUseCase;
  FavoritesController(this.getFavoriteMovies, this.toggleFavoriteUseCase);
  final Rx<ViewState<List<Movie>>> state = Rx<ViewState<List<Movie>>>(
    const ViewIdle(),
  );
  final RxBool isLoadingMore = false.obs;
  final RxSet<int> favoriteIds = <int>{}.obs;
  final Rxn<String> actionError = Rxn<String>();
  final List<Movie> _items = [];
  int _page = 0;
  int _totalPages = 1;
  bool get hasMore => _page < _totalPages;
  bool isFavorite(int movieId) => favoriteIds.contains(movieId);
  void syncKnownState(int movieId, {required bool favorited}) {
    if (favorited) {
      favoriteIds.add(movieId);
    } else {
      favoriteIds.remove(movieId);
    }
  }

  Future<void> loadInitial() async {
    state.value = const ViewLoading();
    final result = await getFavoriteMovies(1);
    result.fold((failure) => state.value = ViewFailure(failure.message), (
      paginated,
    ) {
      _items
        ..clear()
        ..addAll(paginated.results);
      _page = paginated.page;
      _totalPages = paginated.totalPages;
      favoriteIds.addAll(_items.map((movie) => movie.id));
      state.value = _items.isEmpty
          ? const ViewEmpty(message: 'No favorite movies yet')
          : ViewLoaded<List<Movie>>(List.unmodifiable(_items));
    });
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore) return;
    isLoadingMore.value = true;
    final result = await getFavoriteMovies(_page + 1);
    isLoadingMore.value = false;
    result.fold((_) {}, (paginated) {
      _items.addAll(paginated.results);
      _page = paginated.page;
      _totalPages = paginated.totalPages;
      favoriteIds.addAll(paginated.results.map((movie) => movie.id));
      state.value = ViewLoaded<List<Movie>>(List.unmodifiable(_items));
    });
  }

  Future<void> toggleFavorite(int movieId) async {
    final wasFavorite = isFavorite(movieId);
    final next = !wasFavorite;
    syncKnownState(movieId, favorited: next);
    final result = await toggleFavoriteUseCase(
      ToggleFavoriteParams(movieId: movieId, favorite: next),
    );
    result.fold((failure) {
      syncKnownState(movieId, favorited: wasFavorite);
      actionError.value = failure.message;
    }, (_) {});
  }
}
