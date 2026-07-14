import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';

abstract interface class RatingsRepository {
  Future<Result<Failure, bool>> rateMovie({
    required int movieId,
    required double value,
  });
  Future<Result<Failure, bool>> deleteRating(int movieId);
}
