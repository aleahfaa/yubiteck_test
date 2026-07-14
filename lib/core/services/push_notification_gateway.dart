import 'package:firebase_messaging/firebase_messaging.dart';

enum NotificationPermissionStatus { authorized, denied, notDetermined }

abstract interface class PushNotificationGateway {
  Future<void> initialize();
  Future<NotificationPermissionStatus> requestPermission();
  Future<String?> getToken();
  Future<RemoteMessage?> getInitialMessage();
  Stream<RemoteMessage> get onForegroundMessage;
  Stream<RemoteMessage> get onMessageOpenedApp;
}
