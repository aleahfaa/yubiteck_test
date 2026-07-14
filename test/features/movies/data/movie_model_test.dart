import 'package:flutter_test/flutter_test.dart';
import 'package:yubiteck_test/features/movies/data/movie_model.dart';
import 'package:yubiteck_test/features/movies/data/paginated_movies_model.dart';

void main() {
  final movieJson = {
    'id': 27205,
    'title': 'Inception',
    'overview': 'A thief who steals corporate secrets...',
    'poster_path': '/poster.jpg',
    'backdrop_path': '/backdrop.jpg',
    'release_date': '2010-07-15',
    'vote_average': 8.4,
    'vote_count': 34000,
    'genre_ids': [28, 878],
    'adult': false,
    'original_language': 'en',
    'popularity': 123.45,
  };

  group('MovieModel.fromJson', () {
    test('parses a full TMDB movie payload', () {
      final movie = MovieModel.fromJson(movieJson);

      expect(movie.id, 27205);
      expect(movie.title, 'Inception');
      expect(movie.posterPath, '/poster.jpg');
      expect(movie.releaseDate, '2010-07-15');
      expect(movie.releaseYear, 2010);
      expect(movie.voteAverage, 8.4);
      expect(movie.genreIds, [28, 878]);
    });

    test('defaults missing/empty optional fields safely', () {
      final movie = MovieModel.fromJson({
        'id': 1,
        'title': 'Minimal',
        'release_date': '',
      });

      expect(movie.overview, '');
      expect(movie.posterPath, isNull);
      expect(movie.releaseDate, isNull);
      expect(movie.releaseYear, isNull);
      expect(movie.voteAverage, 0);
      expect(movie.genreIds, isEmpty);
    });
  });

  group('PaginatedMoviesModel.fromJson', () {
    test('parses page metadata and nested results', () {
      final page = PaginatedMoviesModel.fromJson({
        'page': 2,
        'total_pages': 10,
        'total_results': 200,
        'results': [movieJson],
      });

      expect(page.page, 2);
      expect(page.totalPages, 10);
      expect(page.totalResults, 200);
      expect(page.results, hasLength(1));
      expect(page.results.first.title, 'Inception');
      expect(page.hasMore, isTrue);
    });
  });
}
