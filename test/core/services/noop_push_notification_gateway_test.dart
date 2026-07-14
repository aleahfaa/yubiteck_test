import 'package:flutter_test/flutter_test.dart';
import 'package:yubiteck_test/core/services/noop_push_notification_gateway.dart';
import 'package:yubiteck_test/core/services/push_notification_gateway.dart';

void main() {
  test('every call is a harmless no-op', () async {
    final gateway = NoopPushNotificationGateway();

    await gateway.initialize();
    final status = await gateway.requestPermission();
    final token = await gateway.getToken();
    final initialMessage = await gateway.getInitialMessage();

    expect(status, NotificationPermissionStatus.denied);
    expect(token, isNull);
    expect(initialMessage, isNull);
    expect(gateway.onForegroundMessage, emitsDone);
    expect(gateway.onMessageOpenedApp, emitsDone);
  });
}
