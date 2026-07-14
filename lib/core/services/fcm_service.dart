import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'local_notification_service.dart';
import 'push_notification_gateway.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('[FCM] Background message: ${message.messageId}');
  }
}

class FcmService implements PushNotificationGateway {
  final FirebaseMessaging _messaging;
  final LocalNotificationService _localNotifications;
  FcmService({FirebaseMessaging? messaging, required this._localNotifications})
    : _messaging = messaging ?? FirebaseMessaging.instance;
  @override
  Future<void> initialize() async {
    await _localNotifications.initialize();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_localNotifications.showNotification);
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized || AuthorizationStatus.provisional =>
        NotificationPermissionStatus.authorized,
      AuthorizationStatus.denied => NotificationPermissionStatus.denied,
      AuthorizationStatus.notDetermined =>
        NotificationPermissionStatus.notDetermined,
    };
  }

  @override
  Future<String?> getToken() => _messaging.getToken();
  @override
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();
  @override
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;
  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;
}
