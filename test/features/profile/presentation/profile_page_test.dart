import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/core/services/native_bridge_service.dart';
import 'package:yubiteck_test/core/services/noop_push_notification_gateway.dart';
import 'package:yubiteck_test/core/usecase/usecase.dart';
import 'package:yubiteck_test/features/auth/domain/account.dart';
import 'package:yubiteck_test/features/auth/presentation/auth_controller.dart';
import 'package:yubiteck_test/features/favorites/presentation/favorites_controller.dart';
import 'package:yubiteck_test/features/movies/domain/paginated_movies.dart';
import 'package:yubiteck_test/features/notifications/presentation/notifications_controller.dart';
import 'package:yubiteck_test/features/profile/presentation/animated_avatar_ring.dart';
import 'package:yubiteck_test/features/profile/presentation/profile_controller.dart';
import 'package:yubiteck_test/features/profile/presentation/profile_page.dart';
import 'package:yubiteck_test/features/ratings/presentation/ratings_controller.dart';
import '../../../helpers/mock_helpers.dart';

void main() {
  tearDown(Get.reset);
  const account = Account(id: 7, username: 'trinity', name: 'Trinity');
  void putSupportingControllers() {
    Get.put(FavoritesController(MockGetFavoriteMovies(), MockToggleFavorite()));
    Get.put(RatingsController(MockRateMovie(), MockDeleteRating()));
    Get.put(NotificationsController(NoopPushNotificationGateway()));
  }

  testWidgets('renders account info and animates the avatar ring on load', (
    tester,
  ) async {
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
    Get.put(authController);
    final getFavoriteMovies = MockGetFavoriteMovies();
    when(() => getFavoriteMovies(1)).thenAnswer(
      (_) async => const Ok(
        PaginatedMovies(page: 1, results: [], totalPages: 1, totalResults: 0),
      ),
    );
    Get.put(FavoritesController(getFavoriteMovies, MockToggleFavorite()));
    Get.put(RatingsController(MockRateMovie(), MockDeleteRating()));
    Get.put(NotificationsController(NoopPushNotificationGateway()));
    Get.put(
      ProfileController(
        authController,
        Get.find<FavoritesController>(),
        Get.find<RatingsController>(),
        NativeBridgeService(),
      ),
    );
    await tester.pumpWidget(const GetMaterialApp(home: ProfilePage()));
    await tester.pump(const Duration(milliseconds: 200));
    final midRing = tester.widget<AnimatedAvatarRing>(
      find.byType(AnimatedAvatarRing),
    );
    expect(midRing.progress, greaterThan(0));
    expect(midRing.progress, lessThan(1));
    await tester.pumpAndSettle();
    final settledRing = tester.widget<AnimatedAvatarRing>(
      find.byType(AnimatedAvatarRing),
    );
    expect(settledRing.progress, 1.0);
    expect(find.text('Trinity'), findsOneWidget);
    expect(find.text('@trinity'), findsOneWidget);
    expect(find.text('LOG OUT'), findsOneWidget);
  });
  testWidgets('shows a sign-in prompt when unauthenticated', (tester) async {
    final authController = AuthController(
      createRequestToken: MockCreateRequestToken(),
      createSession: MockCreateSession(),
      restoreSession: MockRestoreSession(),
      logoutUseCase: MockLogout(),
    );
    Get.put(authController);
    putSupportingControllers();
    Get.put(
      ProfileController(
        authController,
        Get.find<FavoritesController>(),
        Get.find<RatingsController>(),
        NativeBridgeService(),
      ),
    );
    await tester.pumpWidget(const GetMaterialApp(home: ProfilePage()));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to see your profile'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.byType(AnimatedAvatarRing), findsNothing);
  });
}
