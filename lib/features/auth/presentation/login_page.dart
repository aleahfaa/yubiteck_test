import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/presentation/view_state.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_button_styles.dart';
import '../domain/account.dart';
import 'auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Obx(() {
        final state = controller.state.value;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.movie_creation_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign in with your TMDB account',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Required to manage favorites, ratings and your profile.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (state is ViewFailure<Account>) ...[
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                if (state is ViewLoading<Account>)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  FilledButton(
                    style: AppButtonStyles.filled(context),
                    onPressed: _startLogin,
                    child: const Text('SIGN IN WITH TMDB'),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _startLogin() async {
    final token = await controller.beginLogin();
    if (token == null) return;
    final approved = await Get.toNamed(AppRoutes.authWebview, arguments: token);
    if (approved != true) return;
    final success = await controller.completeLogin();
    if (!success) return;
    final args = Get.arguments;
    final redirectTo = args is Map ? args['redirectTo'] as String? : null;
    if (redirectTo != null) {
      Get.offNamed(redirectTo);
    } else if (Get.previousRoute.isNotEmpty) {
      Get.back(result: true);
    } else {
      Get.offAllNamed(AppRoutes.movies);
    }
  }
}
