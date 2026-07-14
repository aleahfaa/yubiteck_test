import 'cast_member.dart';
import 'genre.dart';
import 'movie.dart';

class MovieDetail extends Movie {
  final int runtime;
  final String tagline;
  final String status;
  final List<Genre> genres;
  final List<CastMember> cast;
  final String? trailerKey;
  final int budget;
  final int revenue;
  final String homepage;
  const MovieDetail({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    super.releaseDate,
    super.voteAverage,
    super.voteCount,
    super.adult,
    super.originalLanguage,
    super.popularity,
    this.runtime = 0,
    this.tagline = '',
    this.status = '',
    this.genres = const [],
    this.cast = const [],
    this.trailerKey,
    this.budget = 0,
    this.revenue = 0,
    this.homepage = '',
  });
  String? get trailerYoutubeUrl =>
      trailerKey == null ? null : 'https://www.youtube.com/watch?v=$trailerKey';
  @override
  List<Object?> get props => [
    ...super.props,
    runtime,
    genres,
    cast,
    trailerKey,
  ];
}
