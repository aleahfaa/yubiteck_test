import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/features/ratings/domain/delete_rating.dart';
import 'package:yubiteck_test/features/ratings/domain/rate_movie.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  test('RateMovie delegates to the repository', () async {
    final repository = MockRatingsRepository();
    final usecase = RateMovie(repository);
    when(
      () => repository.rateMovie(movieId: 42, value: 7.5),
    ).thenAnswer((_) async => const Ok(true));

    final result = await usecase(
      const RateMovieParams(movieId: 42, value: 7.5),
    );

    expect(result.valueOrNull, isTrue);
    verify(() => repository.rateMovie(movieId: 42, value: 7.5)).called(1);
  });

  test('DeleteRating delegates to the repository', () async {
    final repository = MockRatingsRepository();
    final usecase = DeleteRating(repository);
    when(
      () => repository.deleteRating(42),
    ).thenAnswer((_) async => const Ok(true));

    final result = await usecase(42);

    expect(result.valueOrNull, isTrue);
    verify(() => repository.deleteRating(42)).called(1);
  });
}
