import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import 'account.dart';
import 'auth_repository.dart';

class RestoreSession implements UseCase<Account, NoParams> {
  final AuthRepository repository;
  const RestoreSession(this.repository);
  @override
  Future<Result<Failure, Account>> call(NoParams params) {
    return repository.restoreSession();
  }
}
