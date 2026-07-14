import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/network/result_guard.dart';
import '../domain/account.dart';
import '../domain/auth_repository.dart';
import 'auth_local_data_source.dart';
import 'auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;
  const AuthRepositoryImpl(this.remote, this.local);
  @override
  Future<Result<Failure, String>> createRequestToken() {
    return guardResult(() => remote.createRequestToken());
  }

  @override
  Future<Result<Failure, Account>> createSession(String requestToken) {
    return guardResult(() async {
      final sessionId = await remote.createSession(requestToken);
      await local.saveSession(sessionId);
      final account = await remote.getAccountDetails();
      await local.saveAccountId(account.id);
      return account;
    });
  }

  @override
  Future<Result<Failure, Account>> restoreSession() {
    return guardResult(() async {
      final sessionId = await local.getSessionId();
      if (sessionId == null || sessionId.isEmpty) {
        throw const AuthException('No cached TMDB session');
      }
      final account = await remote.getAccountDetails();
      await local.saveAccountId(account.id);
      return account;
    });
  }

  @override
  Future<Result<Failure, bool>> logout() {
    return guardResult(() async {
      final sessionId = await local.getSessionId();
      if (sessionId != null && sessionId.isNotEmpty) {
        await remote.deleteSession(sessionId);
      }
      await local.clearSession();
      return true;
    });
  }
}
