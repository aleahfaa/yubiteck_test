import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/presentation/view_state.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../movies/domain/movie.dart';
import '../../movies/presentation/movie_poster_card.dart';
import 'movie_search_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final MovieSearchController _controller;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _controller = Get.find<MovieSearchController>();
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
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _textController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _controller.onQueryChanged,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search movies…',
            border: InputBorder.none,
            hintStyle: TextStyle(color: scheme.outline),
          ),
        ),
        actions: [
          Obx(
            () => _controller.query.value.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _textController.clear();
                      _controller.clear();
                    },
                  ),
          ),
        ],
      ),
      body: Obx(() {
        final state = _controller.state.value;
        return switch (state) {
          ViewIdle<List<Movie>>() => const AppEmptyView(
            message: 'Search for a movie by title',
            icon: Icons.search,
          ),
          ViewLoading<List<Movie>>() => const AppLoadingView(),
          ViewFailure<List<Movie>>(:final message) => AppErrorView(
            message: message,
            onRetry: () => _controller.onQueryChanged(_controller.query.value),
          ),
          ViewEmpty<List<Movie>>(:final message) => AppEmptyView(
            message: message ?? 'No results found',
            icon: Icons.movie_filter_outlined,
          ),
          ViewLoaded<List<Movie>>(:final data) => GridView.builder(
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
        };
      }),
    );
  }
}
