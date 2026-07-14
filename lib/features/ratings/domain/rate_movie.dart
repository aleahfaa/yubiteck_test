import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import 'ratings_repository.dart';

class RateMovieParams extends Equatable {
  final int movieId;
  final double value;
  const RateMovieParams({required this.movieId, required this.value});
  @override
  List<Object?> get props => [movieId, value];
}

class RateMovie implements UseCase<bool, RateMovieParams> {
  final RatingsRepository repository;
  const RateMovie(this.repository);
  @override
  Future<Result<Failure, bool>> call(RateMovieParams params) {
    return repository.rateMovie(movieId: params.movieId, value: params.value);
  }
}
