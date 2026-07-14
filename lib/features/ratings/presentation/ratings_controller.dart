import 'package:get/get.dart';
import '../domain/delete_rating.dart';
import '../domain/rate_movie.dart';

class RatingsController extends GetxController {
  final RateMovie rateMovieUseCase;
  final DeleteRating deleteRatingUseCase;
  RatingsController(this.rateMovieUseCase, this.deleteRatingUseCase);
  final RxMap<int, double> ratings = <int, double>{}.obs;
  final Rxn<String> actionError = Rxn<String>();
  double? ratingFor(int movieId) => ratings[movieId];
  void syncKnownState(int movieId, {double? ratedValue}) {
    if (ratedValue == null) {
      ratings.remove(movieId);
    } else {
      ratings[movieId] = ratedValue;
    }
  }

  Future<void> rate(int movieId, double value) async {
    final previous = ratings[movieId];
    ratings[movieId] = value;
    final result = await rateMovieUseCase(
      RateMovieParams(movieId: movieId, value: value),
    );
    result.fold((failure) {
      if (previous == null) {
        ratings.remove(movieId);
      } else {
        ratings[movieId] = previous;
      }
      actionError.value = failure.message;
    }, (_) {});
  }

  Future<void> deleteRating(int movieId) async {
    final previous = ratings[movieId];
    ratings.remove(movieId);
    final result = await deleteRatingUseCase(movieId);
    result.fold((failure) {
      if (previous != null) {
        ratings[movieId] = previous;
      }
      actionError.value = failure.message;
    }, (_) {});
  }
}
