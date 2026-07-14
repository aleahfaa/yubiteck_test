import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import 'auth_repository.dart';

class CreateRequestToken implements UseCase<String, NoParams> {
  final AuthRepository repository;
  const CreateRequestToken(this.repository);
  @override
  Future<Result<Failure, String>> call(NoParams params) {
    return repository.createRequestToken();
  }
}
