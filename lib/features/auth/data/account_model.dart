import '../domain/account.dart';

class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.username,
    required super.name,
    super.tmdbAvatarPath,
    super.gravatarHash,
  });
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    final avatar = json['avatar'] as Map<String, dynamic>?;
    final tmdbAvatar = avatar?['tmdb'] as Map<String, dynamic>?;
    final gravatar = avatar?['gravatar'] as Map<String, dynamic>?;
    return AccountModel(
      id: json['id'] as int,
      username: (json['username'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      tmdbAvatarPath: tmdbAvatar?['avatar_path'] as String?,
      gravatarHash: gravatar?['hash'] as String?,
    );
  }
}
