import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import 'account.dart';

abstract interface class AuthRepository {
  Future<Result<Failure, String>> createRequestToken();
  Future<Result<Failure, Account>> createSession(String requestToken);
  Future<Result<Failure, Account>> restoreSession();
  Future<Result<Failure, bool>> logout();
}
