import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/services/push_notification_gateway.dart';

class NotificationsController extends GetxController {
  final PushNotificationGateway gateway;
  NotificationsController(this.gateway);
  final Rx<NotificationPermissionStatus> permissionStatus =
      Rx<NotificationPermissionStatus>(
        NotificationPermissionStatus.notDetermined,
      );
  final RxnString token = RxnString();
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  // Gateway initialization (background handler, foreground listener) runs
  // once at app startup in InitialBinding, not here, since this controller
  // is only bound lazily when the Profile page is first visited.
  Future<void> _init() async {
    try {
      token.value = await gateway.getToken();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[Notifications] getToken failed: $error');
      }
    }
  }

  Future<void> requestPermission() async {
    try {
      permissionStatus.value = await gateway.requestPermission();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[Notifications] requestPermission failed: $error');
      }
    }
  }
}
