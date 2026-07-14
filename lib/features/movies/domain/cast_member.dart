import 'package:equatable/equatable.dart';

class CastMember extends Equatable {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });
  @override
  List<Object?> get props => [id, name, character, profilePath];
}
