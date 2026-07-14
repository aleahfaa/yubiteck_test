import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/error/failures.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/core/presentation/splash_page.dart';
import 'package:yubiteck_test/core/routing/app_routes.dart';
import 'package:yubiteck_test/core/usecase/usecase.dart';
import 'package:yubiteck_test/features/auth/presentation/auth_controller.dart';

import 'helpers/mock_helpers.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('SplashPage restores the session then redirects to movies', (
    WidgetTester tester,
  ) async {
    final restoreSession = MockRestoreSession();
    when(
      () => restoreSession(const NoParams()),
    ).thenAnswer((_) async => const Err(AuthFailure('no cached session')));
    Get.put<AuthController>(
      AuthController(
        createRequestToken: MockCreateRequestToken(),
        createSession: MockCreateSession(),
        restoreSession: restoreSession,
        logoutUseCase: MockLogout(),
      ),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.splash,
        getPages: [
          GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
          GetPage(
            name: AppRoutes.movies,
            page: () => const Text('movies-page-placeholder'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('movies-page-placeholder'), findsOneWidget);
    expect(find.byType(SplashPage), findsNothing);
    verify(() => restoreSession(const NoParams())).called(1);
  });
}
