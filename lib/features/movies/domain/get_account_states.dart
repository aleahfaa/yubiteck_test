import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import 'account_states.dart';
import 'movies_repository.dart';

class GetAccountStates implements UseCase<AccountStates, int> {
  final MoviesRepository repository;
  const GetAccountStates(this.repository);
  @override
  Future<Result<Failure, AccountStates>> call(int movieId) {
    return repository.getAccountStates(movieId);
  }
}
