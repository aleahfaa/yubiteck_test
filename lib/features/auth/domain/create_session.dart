import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import 'account.dart';
import 'auth_repository.dart';

class CreateSession implements UseCase<Account, String> {
  final AuthRepository repository;
  const CreateSession(this.repository);
  @override
  Future<Result<Failure, Account>> call(String requestToken) {
    return repository.createSession(requestToken);
  }
}
