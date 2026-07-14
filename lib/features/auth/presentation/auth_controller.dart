import 'package:get/get.dart';
import '../../../core/presentation/view_state.dart';
import '../../../core/usecase/usecase.dart';
import '../domain/account.dart';
import '../domain/create_request_token.dart';
import '../domain/create_session.dart';
import '../domain/logout.dart';
import '../domain/restore_session.dart';

class AuthController extends GetxController {
  final CreateRequestToken createRequestToken;
  final CreateSession createSession;
  final RestoreSession restoreSession;
  final Logout logoutUseCase;
  AuthController({
    required this.createRequestToken,
    required this.createSession,
    required this.restoreSession,
    required this.logoutUseCase,
  });
  final Rx<ViewState<Account>> state = Rx<ViewState<Account>>(const ViewIdle());
  final RxnString pendingRequestToken = RxnString();
  bool get isAuthenticated => state.value is ViewLoaded<Account>;
  Account? get account {
    final current = state.value;
    return current is ViewLoaded<Account> ? current.data : null;
  }

  Future<void> restore() async {
    final result = await restoreSession(const NoParams());
    result.fold(
      (_) => state.value = const ViewIdle(),
      (account) => state.value = ViewLoaded(account),
    );
  }

  Future<String?> beginLogin() async {
    state.value = const ViewLoading();
    final result = await createRequestToken(const NoParams());
    return result.fold(
      (failure) {
        state.value = ViewFailure(failure.message);
        return null;
      },
      (token) {
        pendingRequestToken.value = token;
        return token;
      },
    );
  }

  Future<bool> completeLogin() async {
    final token = pendingRequestToken.value;
    if (token == null) {
      state.value = const ViewFailure('Login was not started');
      return false;
    }
    state.value = const ViewLoading();
    final result = await createSession(token);
    pendingRequestToken.value = null;
    return result.fold(
      (failure) {
        state.value = ViewFailure(failure.message);
        return false;
      },
      (account) {
        state.value = ViewLoaded(account);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await logoutUseCase(const NoParams());
    state.value = const ViewIdle();
  }
}
