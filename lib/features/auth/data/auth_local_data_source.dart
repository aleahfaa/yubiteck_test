import '../../../core/services/session_store.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveSession(String sessionId);
  Future<String?> getSessionId();
  Future<void> saveAccountId(int accountId);
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SessionStore sessionStore;
  const AuthLocalDataSourceImpl(this.sessionStore);
  @override
  Future<void> saveSession(String sessionId) => sessionStore.save(sessionId);
  @override
  Future<String?> getSessionId() async =>
      sessionStore.sessionId ?? await sessionStore.restore();
  @override
  Future<void> saveAccountId(int accountId) =>
      sessionStore.saveAccountId(accountId);
  @override
  Future<void> clearSession() => sessionStore.clear();
}
