import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/result.dart';
import '../../../core/usecase/usecase.dart';
import 'favorites_repository.dart';

class ToggleFavoriteParams extends Equatable {
  final int movieId;
  final bool favorite;
  const ToggleFavoriteParams({required this.movieId, required this.favorite});
  @override
  List<Object?> get props => [movieId, favorite];
}

class ToggleFavorite implements UseCase<bool, ToggleFavoriteParams> {
  final FavoritesRepository repository;
  const ToggleFavorite(this.repository);
  @override
  Future<Result<Failure, bool>> call(ToggleFavoriteParams params) {
    return repository.setFavorite(
      movieId: params.movieId,
      favorite: params.favorite,
    );
  }
}
