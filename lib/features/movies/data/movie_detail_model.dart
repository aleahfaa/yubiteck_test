import '../domain/movie_detail.dart';
import 'cast_member_model.dart';
import 'genre_model.dart';

class MovieDetailModel extends MovieDetail {
  const MovieDetailModel({
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
    super.runtime,
    super.tagline,
    super.status,
    super.genres,
    super.cast,
    super.trailerKey,
    super.budget,
    super.revenue,
    super.homepage,
  });
  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    final releaseDate = json['release_date'] as String?;
    final credits = json['credits'] as Map<String, dynamic>?;
    final cast = (credits?['cast'] as List<dynamic>? ?? const [])
        .take(12)
        .map((e) => CastMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final videos = json['videos'] as Map<String, dynamic>?;
    final videoResults = (videos?['results'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final trailer = videoResults.firstWhere(
      (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
      orElse: () => const {},
    );
    return MovieDetailModel(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: (releaseDate == null || releaseDate.isEmpty)
          ? null
          : releaseDate,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      adult: json['adult'] as bool? ?? false,
      originalLanguage: (json['original_language'] ?? '') as String,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
      runtime: (json['runtime'] as num?)?.toInt() ?? 0,
      tagline: (json['tagline'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      genres: (json['genres'] as List<dynamic>? ?? const [])
          .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      cast: cast,
      trailerKey: trailer['key'] as String?,
      budget: (json['budget'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toInt() ?? 0,
      homepage: (json['homepage'] ?? '') as String,
    );
  }
}
