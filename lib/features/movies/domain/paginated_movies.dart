import 'package:equatable/equatable.dart';
import 'movie.dart';

class PaginatedMovies extends Equatable {
  final int page;
  final List<Movie> results;
  final int totalPages;
  final int totalResults;
  const PaginatedMovies({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });
  bool get hasMore => page < totalPages;
  @override
  List<Object?> get props => [page, results, totalPages, totalResults];
}
