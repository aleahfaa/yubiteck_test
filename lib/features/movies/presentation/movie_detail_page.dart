import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/presentation/view_state.dart';
import '../../../core/widgets/app_button_styles.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/mono_network_image.dart';
import '../../favorites/presentation/favorite_button.dart';
import '../../ratings/presentation/rating_dial_button.dart';
import '../domain/movie.dart';
import '../domain/movie_detail.dart';
import 'movie_detail_controller.dart';
import 'cast_list.dart';
import 'genre_chip.dart';
import 'rating_badge.dart';

class MovieDetailPage extends GetView<MovieDetailController> {
  const MovieDetailPage({super.key});
  Movie? get _shell => Get.arguments is Movie ? Get.arguments as Movie : null;
  int? get _movieId {
    final fromRoute = int.tryParse(Get.parameters['id'] ?? '');
    return fromRoute ?? _shell?.id;
  }

  String get _heroTag => Get.parameters['heroTag'] ?? 'movie-poster-$_movieId';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final state = controller.state.value;
        return switch (state) {
          ViewLoading<MovieDetail>() => _LoadingShell(shell: _shell),
          ViewFailure<MovieDetail>(:final message) => SafeArea(
            child: AppErrorView(
              message: message,
              onRetry: () {
                final id = _movieId;
                if (id != null) controller.load(id);
              },
            ),
          ),
          ViewLoaded<MovieDetail>(:final data) => _DetailContent(
            detail: data,
            heroTag: _heroTag,
          ),
          ViewIdle<MovieDetail>() ||
          ViewEmpty<MovieDetail>() => const AppLoadingView(),
        };
      }),
    );
  }
}

class _LoadingShell extends StatelessWidget {
  final Movie? shell;
  const _LoadingShell({required this.shell});
  @override
  Widget build(BuildContext context) {
    if (shell == null) return const AppLoadingView();
    return CustomScrollView(
      slivers: [
        SliverAppBar(pinned: true, title: Text(shell!.title)),
        const SliverFillRemaining(child: AppLoadingView()),
      ],
    );
  }
}

class _DetailContent extends StatelessWidget {
  final MovieDetail detail;
  final String heroTag;
  const _DetailContent({required this.detail, required this.heroTag});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          actions: [FavoriteButton(movieId: detail.id)],
          flexibleSpace: FlexibleSpaceBar(
            background: MonoNetworkImage(
              url: ApiConstants.imageUrl(
                detail.backdropPath,
                size: ApiConstants.backdropSize,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: heroTag,
                      child: ClipRect(
                        child: SizedBox(
                          width: 96,
                          height: 144,
                          child: MonoNetworkImage(
                            url: ApiConstants.imageUrl(
                              detail.posterPath,
                              size: ApiConstants.posterSizeMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  detail.title,
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                              RatingDialButton(movieId: detail.id, size: 48),
                            ],
                          ),
                          if (detail.tagline.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              detail.tagline,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              RatingBadge(voteAverage: detail.voteAverage),
                              const SizedBox(width: 8),
                              if (detail.runtime > 0)
                                Text(
                                  '${detail.runtime} min',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              if (detail.releaseYear != null) ...[
                                const Text(' · '),
                                Text(
                                  '${detail.releaseYear}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (detail.genres.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final genre in detail.genres)
                        GenreChip(label: genre.name),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Text('Overview', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  detail.overview.isEmpty
                      ? 'No overview available.'
                      : detail.overview,
                  style: theme.textTheme.bodyLarge,
                ),
                if (detail.trailerYoutubeUrl != null) ...[
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    style: AppButtonStyles.outlined(context),
                    onPressed: () => launchUrl(
                      Uri.parse(detail.trailerYoutubeUrl!),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('WATCH TRAILER'),
                  ),
                ],
                if (detail.cast.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Cast', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  CastList(cast: detail.cast),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
