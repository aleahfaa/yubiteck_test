import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/error/failures.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/core/presentation/view_state.dart';
import 'package:yubiteck_test/core/usecase/usecase.dart';
import 'package:yubiteck_test/features/auth/domain/account.dart';
import 'package:yubiteck_test/features/auth/presentation/auth_controller.dart';
import 'package:yubiteck_test/features/favorites/presentation/favorites_controller.dart';
import 'package:yubiteck_test/features/movies/domain/account_states.dart';
import 'package:yubiteck_test/features/movies/domain/movie_detail.dart';
import 'package:yubiteck_test/features/movies/presentation/movie_detail_controller.dart';
import 'package:yubiteck_test/features/ratings/presentation/ratings_controller.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  late MockGetMovieDetail getMovieDetail;
  late MockGetAccountStates getAccountStates;
  late AuthController authController;
  late FavoritesController favoritesController;
  late RatingsController ratingsController;
  late MovieDetailController controller;

  tearDown(Get.reset);

  setUp(() {
    getMovieDetail = MockGetMovieDetail();
    getAccountStates = MockGetAccountStates();
    authController = AuthController(
      createRequestToken: MockCreateRequestToken(),
      createSession: MockCreateSession(),
      restoreSession: MockRestoreSession(),
      logoutUseCase: MockLogout(),
    );
    favoritesController = FavoritesController(
      MockGetFavoriteMovies(),
      MockToggleFavorite(),
    );
    ratingsController = RatingsController(MockRateMovie(), MockDeleteRating());
    controller = MovieDetailController(
      getMovieDetail,
      getAccountStates,
      authController,
      favoritesController,
      ratingsController,
    );
  });

  const detail = MovieDetail(id: 27205, title: 'Inception', overview: '');

  test('load() transitions Loading -> Loaded on success', () async {
    when(() => getMovieDetail(27205)).thenAnswer((_) async => const Ok(detail));

    final future = controller.load(27205);
    expect(controller.state.value, isA<ViewLoading<MovieDetail>>());
    await future;

    expect(controller.state.value, isA<ViewLoaded<MovieDetail>>());
    expect((controller.state.value as ViewLoaded<MovieDetail>).data, detail);
  });

  test('load() transitions Loading -> Failure on error', () async {
    when(
      () => getMovieDetail(27205),
    ).thenAnswer((_) async => const Err(ServerFailure('boom')));

    await controller.load(27205);

    expect(controller.state.value, isA<ViewFailure<MovieDetail>>());
  });

  test('does not fetch account_states when unauthenticated', () async {
    when(() => getMovieDetail(27205)).thenAnswer((_) async => const Ok(detail));

    await controller.load(27205);

    verifyNever(() => getAccountStates(any()));
  });

  test(
    'seeds Favorites/Ratings controllers from account_states when authenticated',
    () async {
      when(
        () => getMovieDetail(27205),
      ).thenAnswer((_) async => const Ok(detail));
      when(() => getAccountStates(27205)).thenAnswer(
        (_) async => const Ok(
          AccountStates(movieId: 27205, favorited: true, ratedValue: 8.5),
        ),
      );
      final restoreSession = MockRestoreSession();
      when(() => restoreSession(const NoParams())).thenAnswer(
        (_) async => const Ok(Account(id: 1, username: 'neo', name: 'Thomas')),
      );
      authController = AuthController(
        createRequestToken: MockCreateRequestToken(),
        createSession: MockCreateSession(),
        restoreSession: restoreSession,
        logoutUseCase: MockLogout(),
      );
      await authController.restore();
      controller = MovieDetailController(
        getMovieDetail,
        getAccountStates,
        authController,
        favoritesController,
        ratingsController,
      );

      await controller.load(27205);

      expect(favoritesController.isFavorite(27205), isTrue);
      expect(ratingsController.ratingFor(27205), 8.5);
    },
  );
}
