import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/features/movies/domain/movie_detail.dart';
import 'package:yubiteck_test/features/movies/domain/get_movie_detail.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  test('delegates to the repository with the given movie id', () async {
    final repository = MockMoviesRepository();
    final usecase = GetMovieDetail(repository);
    const detail = MovieDetail(id: 27205, title: 'Inception', overview: '');
    when(
      () => repository.getMovieDetail(27205),
    ).thenAnswer((_) async => const Ok(detail));

    final result = await usecase(27205);

    expect(result.valueOrNull, detail);
    verify(() => repository.getMovieDetail(27205)).called(1);
  });
}
