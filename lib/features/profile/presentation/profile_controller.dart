import 'package:get/get.dart';
import '../../../core/services/native_bridge_service.dart';
import '../../auth/domain/account.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../ratings/presentation/ratings_controller.dart';

class ProfileController extends GetxController {
  final AuthController authController;
  final FavoritesController favoritesController;
  final RatingsController ratingsController;
  final NativeBridgeService nativeBridgeService;
  ProfileController(
    this.authController,
    this.favoritesController,
    this.ratingsController,
    this.nativeBridgeService,
  );
  final Rxn<NativeDeviceInfo> deviceInfo = Rxn<NativeDeviceInfo>();
  Account? get account => authController.account;
  int get favoritesCount => favoritesController.favoriteIds.length;
  int get ratedCount => ratingsController.ratings.length;
  @override
  void onInit() {
    super.onInit();
    if (authController.isAuthenticated) {
      favoritesController.loadInitial();
    }
    nativeBridgeService.getDeviceInfo().then((info) => deviceInfo.value = info);
  }

  Future<void> logout() => authController.logout();
}
