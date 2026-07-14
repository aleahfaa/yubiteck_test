import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/error/failures.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/core/presentation/view_state.dart';
import 'package:yubiteck_test/core/usecase/usecase.dart';
import 'package:yubiteck_test/features/auth/domain/account.dart';
import 'package:yubiteck_test/features/auth/presentation/auth_controller.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  late MockCreateRequestToken createRequestToken;
  late MockCreateSession createSession;
  late MockRestoreSession restoreSession;
  late MockLogout logout;
  late AuthController controller;

  const account = Account(id: 1, username: 'neo', name: 'Thomas');

  setUp(() {
    createRequestToken = MockCreateRequestToken();
    createSession = MockCreateSession();
    restoreSession = MockRestoreSession();
    logout = MockLogout();
    controller = AuthController(
      createRequestToken: createRequestToken,
      createSession: createSession,
      restoreSession: restoreSession,
      logoutUseCase: logout,
    );
  });

  test('restore() with a valid cached session becomes authenticated', () async {
    when(
      () => restoreSession(const NoParams()),
    ).thenAnswer((_) async => const Ok(account));

    await controller.restore();

    expect(controller.isAuthenticated, isTrue);
    expect(controller.account, account);
  });

  test(
    'restore() with no cached session stays unauthenticated (not an error)',
    () async {
      when(
        () => restoreSession(const NoParams()),
      ).thenAnswer((_) async => const Err(AuthFailure('no session')));

      await controller.restore();

      expect(controller.isAuthenticated, isFalse);
      expect(controller.state.value, isA<ViewIdle<Account>>());
    },
  );

  test('beginLogin() stores the pending request token on success', () async {
    when(
      () => createRequestToken(const NoParams()),
    ).thenAnswer((_) async => const Ok('req-token'));

    final token = await controller.beginLogin();

    expect(token, 'req-token');
    expect(controller.pendingRequestToken.value, 'req-token');
  });

  test('beginLogin() surfaces a failure and clears loading state', () async {
    when(
      () => createRequestToken(const NoParams()),
    ).thenAnswer((_) async => const Err(ServerFailure('down')));

    final token = await controller.beginLogin();

    expect(token, isNull);
    expect(controller.state.value, isA<ViewFailure<Account>>());
  });

  test('completeLogin() without a pending token fails fast', () async {
    final success = await controller.completeLogin();

    expect(success, isFalse);
    verifyNever(() => createSession(any()));
  });

  test(
    'completeLogin() exchanges the pending token and authenticates',
    () async {
      when(
        () => createRequestToken(const NoParams()),
      ).thenAnswer((_) async => const Ok('req-token'));
      when(
        () => createSession('req-token'),
      ).thenAnswer((_) async => const Ok(account));
      await controller.beginLogin();

      final success = await controller.completeLogin();

      expect(success, isTrue);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.pendingRequestToken.value, isNull);
    },
  );

  test('logout() resets state to idle', () async {
    when(
      () => restoreSession(const NoParams()),
    ).thenAnswer((_) async => const Ok(account));
    await controller.restore();
    when(
      () => logout(const NoParams()),
    ).thenAnswer((_) async => const Ok(true));

    await controller.logout();

    expect(controller.isAuthenticated, isFalse);
    expect(controller.state.value, isA<ViewIdle<Account>>());
  });
}
