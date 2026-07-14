import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/mono_network_image.dart';
import '../domain/movie.dart';
import 'rating_badge.dart';

class MoviePosterCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final String? heroTag;
  const MoviePosterCard({
    super.key,
    required this.movie,
    this.onTap,
    this.heroTag,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: heroTag ?? 'movie-poster-${movie.id}',
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MonoNetworkImage(
                    url: ApiConstants.imageUrl(
                      movie.posterPath,
                      size: ApiConstants.posterSizeMedium,
                    ),
                  ),
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: RatingBadge(voteAverage: movie.voteAverage),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (movie.releaseYear != null)
            Text('${movie.releaseYear}', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
