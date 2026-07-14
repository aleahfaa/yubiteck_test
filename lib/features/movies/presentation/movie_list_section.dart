import 'package:get/get.dart';
import '../../../core/presentation/view_state.dart';
import '../domain/movie.dart';

class MovieListSection {
  final Rx<ViewState<List<Movie>>> state = Rx<ViewState<List<Movie>>>(
    const ViewIdle(),
  );
  final RxBool isLoadingMore = false.obs;
  final List<Movie> _items = [];
  int page = 0;
  int totalPages = 1;
  bool get hasMore => page < totalPages;
  void applyFirstPage(List<Movie> results, int page, int totalPages) {
    _items
      ..clear()
      ..addAll(results);
    this.page = page;
    this.totalPages = totalPages;
    state.value = _items.isEmpty
        ? const ViewEmpty()
        : ViewLoaded<List<Movie>>(List.unmodifiable(_items));
  }

  void appendPage(List<Movie> results, int page, int totalPages) {
    _items.addAll(results);
    this.page = page;
    this.totalPages = totalPages;
    state.value = ViewLoaded<List<Movie>>(List.unmodifiable(_items));
  }
}
