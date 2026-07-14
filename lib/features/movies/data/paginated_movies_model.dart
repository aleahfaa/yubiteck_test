import '../domain/paginated_movies.dart';
import 'movie_model.dart';

class PaginatedMoviesModel extends PaginatedMovies {
  const PaginatedMoviesModel({
    required super.page,
    required super.results,
    required super.totalPages,
    required super.totalResults,
  });
  factory PaginatedMoviesModel.fromJson(Map<String, dynamic> json) {
    return PaginatedMoviesModel(
      page: (json['page'] as num?)?.toInt() ?? 1,
      results: (json['results'] as List<dynamic>? ?? const [])
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      totalResults: (json['total_results'] as num?)?.toInt() ?? 0,
    );
  }
}
