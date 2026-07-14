import 'package:flutter_test/flutter_test.dart';
import 'package:yubiteck_test/features/auth/data/account_model.dart';

void main() {
  test('parses id/username/name and the tmdb avatar path', () {
    final account = AccountModel.fromJson({
      'id': 42,
      'username': 'neo',
      'name': 'Thomas Anderson',
      'avatar': {
        'tmdb': {'avatar_path': '/avatar.jpg'},
        'gravatar': {'hash': 'abc123'},
      },
    });

    expect(account.id, 42);
    expect(account.username, 'neo');
    expect(account.name, 'Thomas Anderson');
    expect(account.tmdbAvatarPath, '/avatar.jpg');
    expect(account.gravatarHash, 'abc123');
    expect(account.avatarUrl, contains('/avatar.jpg'));
    expect(account.displayName, 'Thomas Anderson');
  });

  test('falls back to gravatar when there is no tmdb avatar', () {
    final account = AccountModel.fromJson({
      'id': 1,
      'username': 'anon',
      'name': '',
      'avatar': {
        'tmdb': {'avatar_path': null},
        'gravatar': {'hash': 'deadbeef'},
      },
    });

    expect(account.avatarUrl, 'https://www.gravatar.com/avatar/deadbeef');
    expect(account.displayName, 'anon');
  });

  test('handles a missing avatar block entirely', () {
    final account = AccountModel.fromJson({'id': 1, 'username': 'anon'});

    expect(account.avatarUrl, isNull);
  });
}
