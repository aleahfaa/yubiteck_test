import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/native_bridge_service.dart';
import '../../auth/presentation/auth_controller.dart';
import 'favorites_controller.dart';

class FavoriteButton extends StatelessWidget {
  final int movieId;
  const FavoriteButton({super.key, required this.movieId});
  @override
  Widget build(BuildContext context) {
    final favorites = Get.find<FavoritesController>();
    final auth = Get.find<AuthController>();
    final nativeBridge = Get.find<NativeBridgeService>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final isFavorite = favorites.isFavorite(movieId);
      return IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: scheme.onSurface,
        ),
        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        onPressed: () {
          if (!auth.isAuthenticated) {
            Get.toNamed(
              AppRoutes.login,
              arguments: {'redirectTo': AppRoutes.movieDetail},
            );
            return;
          }
          nativeBridge.triggerHapticFeedback();
          favorites.toggleFavorite(movieId);
        },
      );
    });
  }
}
