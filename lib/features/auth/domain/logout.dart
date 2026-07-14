import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import 'auth_repository.dart';

class Logout implements UseCase<bool, NoParams> {
  final AuthRepository repository;
  const Logout(this.repository);
  @override
  Future<Result<Failure, bool>> call(NoParams params) {
    return repository.logout();
  }
}
