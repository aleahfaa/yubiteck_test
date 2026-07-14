import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/error/exceptions.dart';
import 'package:yubiteck_test/core/error/failures.dart';
import 'package:yubiteck_test/features/auth/data/account_model.dart';
import 'package:yubiteck_test/features/auth/data/auth_repository_impl.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(remote, local);
  });

  const account = AccountModel(id: 1, username: 'neo', name: 'Thomas');

  group('createSession', () {
    test(
      'exchanges the token for a session, persists it, and returns the account',
      () async {
        when(
          () => remote.createSession('req-token'),
        ).thenAnswer((_) async => 'session-123');
        when(() => local.saveSession('session-123')).thenAnswer((_) async {});
        when(() => local.saveAccountId(1)).thenAnswer((_) async {});
        when(() => remote.getAccountDetails()).thenAnswer((_) async => account);

        final result = await repository.createSession('req-token');

        expect(result.valueOrNull, account);
        verify(() => local.saveSession('session-123')).called(1);
        verify(() => local.saveAccountId(1)).called(1);
      },
    );

    test('maps a rejected token to AuthFailure', () async {
      when(
        () => remote.createSession('bad-token'),
      ).thenThrow(const AuthException('rejected'));

      final result = await repository.createSession('bad-token');

      expect(result.failureOrNull, isA<AuthFailure>());
    });
  });

  group('restoreSession', () {
    test('fails with AuthFailure when there is no cached session', () async {
      when(() => local.getSessionId()).thenAnswer((_) async => null);

      final result = await repository.restoreSession();

      expect(result.failureOrNull, isA<AuthFailure>());
      verifyNever(() => remote.getAccountDetails());
    });

    test('re-validates a cached session against /account', () async {
      when(() => local.getSessionId()).thenAnswer((_) async => 'session-123');
      when(() => remote.getAccountDetails()).thenAnswer((_) async => account);
      when(() => local.saveAccountId(1)).thenAnswer((_) async {});

      final result = await repository.restoreSession();

      expect(result.valueOrNull, account);
    });
  });

  group('logout', () {
    test('deletes the remote session and clears local state', () async {
      when(() => local.getSessionId()).thenAnswer((_) async => 'session-123');
      when(() => remote.deleteSession('session-123')).thenAnswer((_) async {});
      when(() => local.clearSession()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.valueOrNull, isTrue);
      verify(() => remote.deleteSession('session-123')).called(1);
      verify(() => local.clearSession()).called(1);
    });

    test('still clears local state when there was no remote session', () async {
      when(() => local.getSessionId()).thenAnswer((_) async => null);
      when(() => local.clearSession()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.valueOrNull, isTrue);
      verifyNever(() => remote.deleteSession(any()));
      verify(() => local.clearSession()).called(1);
    });
  });
}
