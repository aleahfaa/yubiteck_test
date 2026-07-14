import 'package:flutter_test/flutter_test.dart';
import 'package:yubiteck_test/features/movies/data/movie_detail_model.dart';

void main() {
  test('parses genres, credits.cast and the YouTube trailer', () {
    final detail = MovieDetailModel.fromJson({
      'id': 27205,
      'title': 'Inception',
      'overview': 'A thief...',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'release_date': '2010-07-15',
      'vote_average': 8.4,
      'vote_count': 34000,
      'runtime': 148,
      'tagline': 'Your mind is the scene of the crime.',
      'status': 'Released',
      'budget': 160000000,
      'revenue': 825532764,
      'homepage': 'https://inception.example',
      'genres': [
        {'id': 28, 'name': 'Action'},
        {'id': 878, 'name': 'Science Fiction'},
      ],
      'credits': {
        'cast': [
          {
            'id': 6193,
            'name': 'Leonardo DiCaprio',
            'character': 'Cobb',
            'profile_path': '/dicaprio.jpg',
          },
        ],
      },
      'videos': {
        'results': [
          {'site': 'Vimeo', 'type': 'Trailer', 'key': 'wrong-site'},
          {'site': 'YouTube', 'type': 'Featurette', 'key': 'wrong-type'},
          {'site': 'YouTube', 'type': 'Trailer', 'key': 'YoHD9XEInc0'},
        ],
      },
    });

    expect(detail.title, 'Inception');
    expect(detail.runtime, 148);
    expect(detail.genres.map((g) => g.name), ['Action', 'Science Fiction']);
    expect(detail.cast, hasLength(1));
    expect(detail.cast.first.character, 'Cobb');
    expect(detail.trailerKey, 'YoHD9XEInc0');
    expect(
      detail.trailerYoutubeUrl,
      'https://www.youtube.com/watch?v=YoHD9XEInc0',
    );
  });

  test('handles a response with no genres/cast/videos', () {
    final detail = MovieDetailModel.fromJson({
      'id': 1,
      'title': 'Minimal',
      'overview': '',
    });

    expect(detail.genres, isEmpty);
    expect(detail.cast, isEmpty);
    expect(detail.trailerKey, isNull);
    expect(detail.trailerYoutubeUrl, isNull);
  });
}
