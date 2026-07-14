import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../features/auth/data/auth_local_data_source.dart';
import '../../features/auth/data/auth_remote_data_source.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/create_request_token.dart';
import '../../features/auth/domain/create_session.dart';
import '../../features/auth/domain/logout.dart';
import '../../features/auth/domain/restore_session.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../network/dio_client.dart';
import '../services/native_bridge_service.dart';
import '../services/fcm_service.dart';
import '../services/local_notification_service.dart';
import '../services/noop_push_notification_gateway.dart';
import '../services/notification_router.dart';
import '../services/push_notification_gateway.dart';
import '../services/session_store.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    const storage = FlutterSecureStorage();
    Get.put<FlutterSecureStorage>(storage, permanent: true);
    final sessionStore = SessionStore(storage);
    Get.put<SessionStore>(sessionStore, permanent: true);
    final dioClient = DioClient(
      sessionIdProvider: () => sessionStore.sessionId,
    );
    Get.put<DioClient>(dioClient, permanent: true);
    final authRemote = AuthRemoteDataSourceImpl(dioClient.dio);
    final authLocal = AuthLocalDataSourceImpl(sessionStore);
    final authRepository = AuthRepositoryImpl(authRemote, authLocal);
    Get.put<AuthController>(
      AuthController(
        createRequestToken: CreateRequestToken(authRepository),
        createSession: CreateSession(authRepository),
        restoreSession: RestoreSession(authRepository),
        logoutUseCase: Logout(authRepository),
      ),
      permanent: true,
    );
    Get.put<NativeBridgeService>(NativeBridgeService(), permanent: true);
    final supportsFcm = kIsWeb || !(Platform.isWindows || Platform.isLinux);
    final PushNotificationGateway pushGateway = supportsFcm
        ? FcmService(localNotifications: LocalNotificationService())
        : NoopPushNotificationGateway();
    Get.put<PushNotificationGateway>(pushGateway, permanent: true);
    unawaited(_initializePushGateway(pushGateway));
  }

  Future<void> _initializePushGateway(PushNotificationGateway gateway) async {
    try {
      await gateway.initialize();
    } catch (error) {
      if (kDebugMode) debugPrint('[FCM] initialize failed: $error');
      return;
    }
    gateway.onMessageOpenedApp.listen(openMovieFromMessage);
    try {
      final initialMessage = await gateway.getInitialMessage();
      if (initialMessage != null) openMovieFromMessage(initialMessage);
    } catch (error) {
      if (kDebugMode) debugPrint('[FCM] getInitialMessage failed: $error');
    }
  }
}
