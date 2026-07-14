import '../domain/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    super.releaseDate,
    super.voteAverage,
    super.voteCount,
    super.genreIds,
    super.adult,
    super.originalLanguage,
    super.popularity,
  });
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final releaseDate = json['release_date'] as String?;
    return MovieModel(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: (releaseDate == null || releaseDate.isEmpty)
          ? null
          : releaseDate,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      genreIds:
          (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      adult: json['adult'] as bool? ?? false,
      originalLanguage: (json['original_language'] ?? '') as String,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
    );
  }
}
