import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/error/failures.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/features/ratings/domain/rate_movie.dart';
import 'package:yubiteck_test/features/ratings/presentation/ratings_controller.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  late MockRateMovie rateMovie;
  late MockDeleteRating deleteRating;
  late RatingsController controller;

  setUp(() {
    rateMovie = MockRateMovie();
    deleteRating = MockDeleteRating();
    controller = RatingsController(rateMovie, deleteRating);
  });

  test(
    'rate() optimistically sets the value, then keeps it on success',
    () async {
      when(
        () => rateMovie(const RateMovieParams(movieId: 1, value: 9)),
      ).thenAnswer((_) async => const Ok(true));

      final future = controller.rate(1, 9);
      expect(controller.ratingFor(1), 9); // optimistic, before API resolves
      await future;

      expect(controller.ratingFor(1), 9);
    },
  );

  test('rate() rolls back to the previous value on failure', () async {
    controller.syncKnownState(1, ratedValue: 6);
    when(
      () => rateMovie(const RateMovieParams(movieId: 1, value: 9)),
    ).thenAnswer((_) async => const Err(ServerFailure('boom')));

    await controller.rate(1, 9);

    expect(controller.ratingFor(1), 6);
    expect(controller.actionError.value, 'boom');
  });

  test(
    'rate() rolls back to unrated (null) on failure with no prior value',
    () async {
      when(
        () => rateMovie(const RateMovieParams(movieId: 1, value: 9)),
      ).thenAnswer((_) async => const Err(ServerFailure('boom')));

      await controller.rate(1, 9);

      expect(controller.ratingFor(1), isNull);
    },
  );

  test(
    'deleteRating() removes the value and keeps it removed on success',
    () async {
      controller.syncKnownState(1, ratedValue: 6);
      when(() => deleteRating(1)).thenAnswer((_) async => const Ok(true));

      await controller.deleteRating(1);

      expect(controller.ratingFor(1), isNull);
    },
  );

  test('deleteRating() restores the previous value on failure', () async {
    controller.syncKnownState(1, ratedValue: 6);
    when(
      () => deleteRating(1),
    ).thenAnswer((_) async => const Err(ServerFailure('boom')));

    await controller.deleteRating(1);

    expect(controller.ratingFor(1), 6);
  });
}
