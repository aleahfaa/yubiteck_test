import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/error/exceptions.dart';
import 'package:yubiteck_test/core/error/failures.dart';
import 'package:yubiteck_test/features/ratings/data/ratings_repository_impl.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  late MockRatingsRemoteDataSource remote;
  late RatingsRepositoryImpl repository;

  setUp(() {
    remote = MockRatingsRemoteDataSource();
    repository = RatingsRepositoryImpl(remote);
  });

  test('rateMovie returns Ok(true) on success', () async {
    when(
      () => remote.rateMovie(movieId: 42, value: 8.5),
    ).thenAnswer((_) async {});

    final result = await repository.rateMovie(movieId: 42, value: 8.5);

    expect(result.valueOrNull, isTrue);
  });

  test('rateMovie maps AuthException to AuthFailure', () async {
    when(
      () => remote.rateMovie(movieId: 42, value: 8.5),
    ).thenThrow(const AuthException('no session'));

    final result = await repository.rateMovie(movieId: 42, value: 8.5);

    expect(result.failureOrNull, isA<AuthFailure>());
  });

  test('deleteRating returns Ok(true) on success', () async {
    when(() => remote.deleteRating(42)).thenAnswer((_) async {});

    final result = await repository.deleteRating(42);

    expect(result.valueOrNull, isTrue);
  });
}
