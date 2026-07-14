import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final bool adult;
  final String originalLanguage;
  final double popularity;
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage = 0,
    this.voteCount = 0,
    this.genreIds = const [],
    this.adult = false,
    this.originalLanguage = '',
    this.popularity = 0,
  });
  int? get releaseYear {
    if (releaseDate == null || releaseDate!.length < 4) return null;
    return int.tryParse(releaseDate!.substring(0, 4));
  }

  @override
  List<Object?> get props => [
    id,
    title,
    overview,
    posterPath,
    releaseDate,
    voteAverage,
  ];
}
