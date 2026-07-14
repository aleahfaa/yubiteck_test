import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/presentation/view_state.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../domain/movie.dart';
import '../domain/movie_list_type.dart';
import 'movie_list_section.dart';
import 'movies_controller.dart';
import 'movie_poster_card.dart';

class MovieCategoryGrid extends StatefulWidget {
  final MovieListType type;
  const MovieCategoryGrid({super.key, required this.type});
  @override
  State<MovieCategoryGrid> createState() => _MovieCategoryGridState();
}

class _MovieCategoryGridState extends State<MovieCategoryGrid>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  late final MoviesController _controller;
  late final MovieListSection _section;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _controller = Get.find<MoviesController>();
    _section = _controller.sectionFor(widget.type);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 400;
    if (_scrollController.position.pixels >= threshold) {
      _controller.loadMore(widget.type);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      final state = _section.state.value;
      return switch (state) {
        ViewIdle<List<Movie>>() ||
        ViewLoading<List<Movie>>() => const AppLoadingView(),
        ViewFailure<List<Movie>>(:final message) => AppErrorView(
          message: message,
          onRetry: () => _controller.loadInitial(widget.type),
        ),
        ViewEmpty<List<Movie>>() => const AppEmptyView(
          message: 'No movies found',
          icon: Icons.movie_filter_outlined,
        ),
        ViewLoaded<List<Movie>>(:final data) => RefreshIndicator(
          onRefresh: () => _controller.refreshCategory(widget.type),
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 10,
              childAspectRatio: 0.52,
            ),
            itemCount: data.length + (_section.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= data.length) {
                return const AppLoadingView();
              }
              final movie = data[index];
              return MoviePosterCard(
                movie: movie,
                onTap: () => Get.toNamed(
                  AppRoutes.movieDetail,
                  arguments: movie,
                  parameters: {'id': '${movie.id}'},
                ),
              );
            },
          ),
        ),
      };
    });
  }
}
