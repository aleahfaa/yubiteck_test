import 'package:get/get.dart';
import '../../../core/services/native_bridge_service.dart';
import '../../../core/services/push_notification_gateway.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../favorites/presentation/favorites_binding.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../notifications/presentation/notifications_controller.dart';
import '../../ratings/presentation/ratings_binding.dart';
import '../../ratings/presentation/ratings_controller.dart';
import 'profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    FavoritesBinding().dependencies();
    RatingsBinding().dependencies();
    Get.lazyPut(
      () => ProfileController(
        Get.find<AuthController>(),
        Get.find<FavoritesController>(),
        Get.find<RatingsController>(),
        Get.find<NativeBridgeService>(),
      ),
    );
    Get.lazyPut(
      () => NotificationsController(Get.find<PushNotificationGateway>()),
    );
  }
}
