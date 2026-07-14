import 'package:firebase_messaging/firebase_messaging.dart';
import 'push_notification_gateway.dart';

class NoopPushNotificationGateway implements PushNotificationGateway {
  @override
  Future<void> initialize() async {}
  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      NotificationPermissionStatus.denied;
  @override
  Future<String?> getToken() async => null;
  @override
  Future<RemoteMessage?> getInitialMessage() async => null;
  @override
  Stream<RemoteMessage> get onForegroundMessage => const Stream.empty();
  @override
  Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();
}
