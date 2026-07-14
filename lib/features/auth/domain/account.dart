import 'package:equatable/equatable.dart';
import '../../../core/constants/api_constants.dart';

class Account extends Equatable {
  final int id;
  final String username;
  final String name;
  final String? tmdbAvatarPath;
  final String? gravatarHash;
  const Account({
    required this.id,
    required this.username,
    required this.name,
    this.tmdbAvatarPath,
    this.gravatarHash,
  });
  String? get avatarUrl {
    if (tmdbAvatarPath != null && tmdbAvatarPath!.isNotEmpty) {
      return ApiConstants.imageUrl(
        tmdbAvatarPath,
        size: ApiConstants.profileSize,
      );
    }
    if (gravatarHash != null && gravatarHash!.isNotEmpty) {
      return 'https://www.gravatar.com/avatar/$gravatarHash';
    }
    return null;
  }

  String get displayName => name.isNotEmpty ? name : username;
  @override
  List<Object?> get props => [id, username, name, tmdbAvatarPath, gravatarHash];
}
