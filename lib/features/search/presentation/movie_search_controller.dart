import 'package:get/get.dart';
import '../../../core/presentation/view_state.dart';
import '../../../core/utils/debouncer.dart';
import '../../movies/domain/movie.dart';
import '../domain/search_movies.dart';

class MovieSearchController extends GetxController {
  final SearchMovies searchMovies;
  final Debouncer _debouncer;
  MovieSearchController(
    this.searchMovies, {
    Duration debounceDuration = const Duration(milliseconds: 450),
  }) : _debouncer = Debouncer(delay: debounceDuration);
  final RxString query = ''.obs;
  final Rx<ViewState<List<Movie>>> state = Rx<ViewState<List<Movie>>>(
    const ViewIdle(),
  );
  final RxBool isLoadingMore = false.obs;
  final List<Movie> _items = [];
  int _page = 0;
  int _totalPages = 1;
  int _requestGeneration = 0;
  String _activeQuery = '';
  bool get hasMore => _page < _totalPages;
  void onQueryChanged(String text) {
    query.value = text;
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _debouncer.cancel();
      _requestGeneration++;
      _items.clear();
      state.value = const ViewIdle();
      return;
    }
    _debouncer.run(() => _search(trimmed));
  }

  Future<void> _search(String trimmedQuery) async {
    final generation = ++_requestGeneration;
    _activeQuery = trimmedQuery;
    state.value = const ViewLoading();
    final result = await searchMovies(
      SearchMoviesParams(query: trimmedQuery, page: 1),
    );
    if (generation != _requestGeneration) return;
    result.fold((failure) => state.value = ViewFailure(failure.message), (
      paginated,
    ) {
      _items
        ..clear()
        ..addAll(paginated.results);
      _page = paginated.page;
      _totalPages = paginated.totalPages;
      state.value = _items.isEmpty
          ? ViewEmpty(message: 'No results for "$trimmedQuery"')
          : ViewLoaded<List<Movie>>(List.unmodifiable(_items));
    });
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore || _activeQuery.isEmpty) return;
    isLoadingMore.value = true;
    final generation = _requestGeneration;
    final result = await searchMovies(
      SearchMoviesParams(query: _activeQuery, page: _page + 1),
    );
    isLoadingMore.value = false;
    if (generation != _requestGeneration) return;
    result.fold((_) {}, (paginated) {
      _items.addAll(paginated.results);
      _page = paginated.page;
      _totalPages = paginated.totalPages;
      state.value = ViewLoaded<List<Movie>>(List.unmodifiable(_items));
    });
  }

  void clear() {
    query.value = '';
    _debouncer.cancel();
    _requestGeneration++;
    _items.clear();
    _activeQuery = '';
    state.value = const ViewIdle();
  }

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }
}
