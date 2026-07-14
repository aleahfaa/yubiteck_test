import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  static const _sessionKey = 'tmdb_session_id';
  static const _accountIdKey = 'tmdb_account_id';
  final FlutterSecureStorage _storage;
  String? _cachedSessionId;
  int? _cachedAccountId;
  SessionStore(this._storage);
  String? get sessionId => _cachedSessionId;
  int? get accountId => _cachedAccountId;
  Future<String?> restore() async {
    _cachedSessionId = await _storage.read(key: _sessionKey);
    final rawAccountId = await _storage.read(key: _accountIdKey);
    _cachedAccountId = rawAccountId == null ? null : int.tryParse(rawAccountId);
    return _cachedSessionId;
  }

  Future<void> save(String sessionId) async {
    _cachedSessionId = sessionId;
    await _storage.write(key: _sessionKey, value: sessionId);
  }

  Future<void> saveAccountId(int accountId) async {
    _cachedAccountId = accountId;
    await _storage.write(key: _accountIdKey, value: '$accountId');
  }

  Future<void> clear() async {
    _cachedSessionId = null;
    _cachedAccountId = null;
    await Future.wait([
      _storage.delete(key: _sessionKey),
      _storage.delete(key: _accountIdKey),
    ]);
  }
}
