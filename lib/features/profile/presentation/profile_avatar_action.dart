import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/mono_network_image.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileAvatarAction extends StatelessWidget {
  const ProfileAvatarAction({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: 'Profile',
      onPressed: () => Get.toNamed(AppRoutes.profile),
      icon: Obx(() {
        final avatarUrl = auth.account?.avatarUrl;
        return Hero(
          tag: 'profile-avatar',
          child: ClipOval(
            child: SizedBox(
              width: 28,
              height: 28,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? Icon(Icons.person_outline, color: scheme.onSurface)
                  : MonoNetworkImage(
                      url: avatarUrl.startsWith('http')
                          ? avatarUrl
                          : ApiConstants.imageUrl(avatarUrl),
                    ),
            ),
          ),
        );
      }),
    );
  }
}
