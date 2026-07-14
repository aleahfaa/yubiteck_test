import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/push_notification_gateway.dart';
import 'notifications_controller.dart';

class NotificationPermissionBanner extends StatelessWidget {
  const NotificationPermissionBanner({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();
    final theme = Theme.of(context);
    return Obx(() {
      if (controller.permissionStatus.value !=
          NotificationPermissionStatus.notDetermined) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_none, color: theme.colorScheme.onSurface),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Enable push notifications for movie updates',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
              ),
              onPressed: controller.requestPermission,
              child: const Text('ENABLE'),
            ),
          ],
        ),
      );
    });
  }
}
