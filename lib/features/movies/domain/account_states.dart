import 'package:equatable/equatable.dart';

class AccountStates extends Equatable {
  final int movieId;
  final bool favorited;
  final double? ratedValue;
  const AccountStates({
    required this.movieId,
    this.favorited = false,
    this.ratedValue,
  });
  bool get isRated => ratedValue != null;
  @override
  List<Object?> get props => [movieId, favorited, ratedValue];
}
