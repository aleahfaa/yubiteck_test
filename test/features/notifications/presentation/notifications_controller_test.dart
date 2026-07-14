import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/services/push_notification_gateway.dart';
import 'package:yubiteck_test/features/notifications/presentation/notifications_controller.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  tearDown(Get.reset);

  late MockPushNotificationGateway gateway;

  setUp(() {
    gateway = MockPushNotificationGateway();
  });

  test('onInit stores the token fetched from the gateway', () async {
    when(() => gateway.getToken()).thenAnswer((_) async => 'token-123');

    final controller = Get.put(NotificationsController(gateway));
    await Future<void>.delayed(Duration.zero);

    expect(controller.token.value, 'token-123');
    verify(() => gateway.getToken()).called(1);
    verifyNever(() => gateway.initialize());
  });

  test('a failed getToken() does not crash the controller', () async {
    when(() => gateway.getToken()).thenThrow(Exception('no firebase app'));

    final controller = Get.put(NotificationsController(gateway));
    await Future<void>.delayed(Duration.zero);

    expect(controller.token.value, isNull);
    expect(
      controller.permissionStatus.value,
      NotificationPermissionStatus.notDetermined,
    );
  });

  test('requestPermission updates permissionStatus', () async {
    when(() => gateway.initialize()).thenAnswer((_) async {});
    when(() => gateway.getToken()).thenAnswer((_) async => null);
    when(
      () => gateway.requestPermission(),
    ).thenAnswer((_) async => NotificationPermissionStatus.authorized);
    final controller = NotificationsController(gateway);

    await controller.requestPermission();

    expect(
      controller.permissionStatus.value,
      NotificationPermissionStatus.authorized,
    );
  });

  test('a failed requestPermission() does not crash the controller', () async {
    when(() => gateway.requestPermission()).thenThrow(Exception('denied'));
    final controller = NotificationsController(gateway);

    await controller.requestPermission();

    expect(
      controller.permissionStatus.value,
      NotificationPermissionStatus.notDetermined,
    );
  });
}
