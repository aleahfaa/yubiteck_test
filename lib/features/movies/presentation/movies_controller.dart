import 'package:get/get.dart';
import '../../../core/presentation/view_state.dart';
import '../domain/movie_list_type.dart';
import '../domain/get_movies.dart';
import 'movie_list_section.dart';

class MoviesController extends GetxController {
  final GetMovies getMovies;
  MoviesController(this.getMovies);
  final Map<MovieListType, MovieListSection> sections = {
    for (final type in MovieListType.values) type: MovieListSection(),
  };
  @override
  void onInit() {
    super.onInit();
    for (final type in MovieListType.values) {
      loadInitial(type);
    }
  }

  MovieListSection sectionFor(MovieListType type) => sections[type]!;
  Future<void> loadInitial(MovieListType type) async {
    final section = sections[type]!;
    section.state.value = const ViewLoading();
    final result = await getMovies(GetMoviesParams(type: type, page: 1));
    result.fold(
      (failure) => section.state.value = ViewFailure(failure.message),
      (paginated) => section.applyFirstPage(
        paginated.results,
        paginated.page,
        paginated.totalPages,
      ),
    );
  }

  Future<void> loadMore(MovieListType type) async {
    final section = sections[type]!;
    if (section.isLoadingMore.value || !section.hasMore) return;
    section.isLoadingMore.value = true;
    final result = await getMovies(
      GetMoviesParams(type: type, page: section.page + 1),
    );
    section.isLoadingMore.value = false;
    result.fold(
      (_) {},
      (paginated) => section.appendPage(
        paginated.results,
        paginated.page,
        paginated.totalPages,
      ),
    );
  }

  Future<void> refreshCategory(MovieListType type) => loadInitial(type);
}
