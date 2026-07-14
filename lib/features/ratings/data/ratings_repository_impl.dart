import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/network/result_guard.dart';
import '../domain/ratings_repository.dart';
import 'ratings_remote_data_source.dart';

class RatingsRepositoryImpl implements RatingsRepository {
  final RatingsRemoteDataSource remote;
  const RatingsRepositoryImpl(this.remote);
  @override
  Future<Result<Failure, bool>> rateMovie({
    required int movieId,
    required double value,
  }) {
    return guardResult(() async {
      await remote.rateMovie(movieId: movieId, value: value);
      return true;
    });
  }

  @override
  Future<Result<Failure, bool>> deleteRating(int movieId) {
    return guardResult(() async {
      await remote.deleteRating(movieId);
      return true;
    });
  }
}
