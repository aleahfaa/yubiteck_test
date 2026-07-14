import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import 'ratings_repository.dart';

class DeleteRating implements UseCase<bool, int> {
  final RatingsRepository repository;
  const DeleteRating(this.repository);
  @override
  Future<Result<Failure, bool>> call(int movieId) {
    return repository.deleteRating(movieId);
  }
}
