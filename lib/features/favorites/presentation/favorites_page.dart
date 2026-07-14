import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/presentation/view_state.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../movies/domain/movie.dart';
import '../../movies/presentation/movie_poster_card.dart';
import 'favorites_controller.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final FavoritesController _controller;
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _controller = Get.find<FavoritesController>();
    _controller.loadInitial();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 400;
    if (_scrollController.position.pixels >= threshold) {
      _controller.loadMore();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Obx(() {
        final state = _controller.state.value;
        return switch (state) {
          ViewIdle<List<Movie>>() ||
          ViewLoading<List<Movie>>() => const AppLoadingView(),
          ViewFailure<List<Movie>>(:final message) => AppErrorView(
            message: message,
            onRetry: _controller.loadInitial,
          ),
          ViewEmpty<List<Movie>>(:final message) => AppEmptyView(
            message: message ?? 'No favorite movies yet',
            icon: Icons.favorite_border,
          ),
          ViewLoaded<List<Movie>>(:final data) => RefreshIndicator(
            onRefresh: _controller.loadInitial,
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 10,
                childAspectRatio: 0.52,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
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
      }),
    );
  }
}
