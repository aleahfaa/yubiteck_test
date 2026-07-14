import '../domain/account_states.dart';

class AccountStatesModel extends AccountStates {
  const AccountStatesModel({
    required super.movieId,
    super.favorited,
    super.ratedValue,
  });
  factory AccountStatesModel.fromJson(Map<String, dynamic> json) {
    final rated = json['rated'];
    double? ratedValue;
    if (rated is Map<String, dynamic>) {
      ratedValue = (rated['value'] as num?)?.toDouble();
    }
    return AccountStatesModel(
      movieId: json['id'] as int,
      favorited: json['favorite'] as bool? ?? false,
      ratedValue: ratedValue,
    );
  }
}
