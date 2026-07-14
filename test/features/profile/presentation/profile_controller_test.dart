import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/core/services/native_bridge_service.dart';
import 'package:yubiteck_test/core/usecase/usecase.dart';
import 'package:yubiteck_test/features/auth/domain/account.dart';
import 'package:yubiteck_test/features/auth/presentation/auth_controller.dart';
import 'package:yubiteck_test/features/favorites/presentation/favorites_controller.dart';
import 'package:yubiteck_test/features/movies/domain/movie.dart';
import 'package:yubiteck_test/features/movies/domain/paginated_movies.dart';
import 'package:yubiteck_test/features/profile/presentation/profile_controller.dart';
import 'package:yubiteck_test/features/ratings/presentation/ratings_controller.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  tearDown(Get.reset);

  const account = Account(id: 1, username: 'neo', name: 'Thomas');

  test('account is null and favorites are not loaded when unauthenticated', () {
    final authController = AuthController(
      createRequestToken: MockCreateRequestToken(),
      createSession: MockCreateSession(),
      restoreSession: MockRestoreSession(),
      logoutUseCase: MockLogout(),
    );
    final getFavoriteMovies = MockGetFavoriteMovies();
    final favoritesController = FavoritesController(
      getFavoriteMovies,
      MockToggleFavorite(),
    );
    final ratingsController = RatingsController(
      MockRateMovie(),
      MockDeleteRating(),
    );

    final controller = ProfileController(
      authController,
      favoritesController,
      ratingsController,
      NativeBridgeService(),
    );

    expect(controller.account, isNull);
    verifyNever(() => getFavoriteMovies(any()));
  });

  test('loads favorites and exposes counts when authenticated', () async {
    final restoreSession = MockRestoreSession();
    when(
      () => restoreSession(const NoParams()),
    ).thenAnswer((_) async => const Ok(account));
    final authController = AuthController(
      createRequestToken: MockCreateRequestToken(),
      createSession: MockCreateSession(),
      restoreSession: restoreSession,
      logoutUseCase: MockLogout(),
    );
    await authController.restore();

    final getFavoriteMovies = MockGetFavoriteMovies();
    when(() => getFavoriteMovies(1)).thenAnswer(
      (_) async => const Ok(
        PaginatedMovies(
          page: 1,
          results: [Movie(id: 1, title: 'A', overview: '')],
          totalPages: 1,
          totalResults: 1,
        ),
      ),
    );
    final favoritesController = FavoritesController(
      getFavoriteMovies,
      MockToggleFavorite(),
    );
    final ratingsController = RatingsController(
      MockRateMovie(),
      MockDeleteRating(),
    );
    ratingsController.syncKnownState(1, ratedValue: 8);

    final controller = Get.put(
      ProfileController(
        authController,
        favoritesController,
        ratingsController,
        NativeBridgeService(),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.account, account);
    expect(controller.favoritesCount, 1);
    expect(controller.ratedCount, 1);
  });

  test('logout() delegates to AuthController', () async {
    final logout = MockLogout();
    when(
      () => logout(const NoParams()),
    ).thenAnswer((_) async => const Ok(true));
    final authController = AuthController(
      createRequestToken: MockCreateRequestToken(),
      createSession: MockCreateSession(),
      restoreSession: MockRestoreSession(),
      logoutUseCase: logout,
    );
    final controller = ProfileController(
      authController,
      FavoritesController(MockGetFavoriteMovies(), MockToggleFavorite()),
      RatingsController(MockRateMovie(), MockDeleteRating()),
      NativeBridgeService(),
    );

    await controller.logout();

    verify(() => logout(const NoParams())).called(1);
  });
}
