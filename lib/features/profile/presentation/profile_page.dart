import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_button_styles.dart';
import '../../notifications/presentation/notification_permission_banner.dart';
import 'profile_controller.dart';
import 'animated_avatar_ring.dart';
import 'stat_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late final ProfileController _controller;
  late final AnimationController _ringController;
  late final AnimationController _statsController;
  late final List<Animation<double>> _statReveals;
  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _statReveals = List.generate(3, (index) {
      final start = index * 0.12;
      return CurvedAnimation(
        parent: _statsController,
        curve: Interval(start, start + 0.6, curve: Curves.easeOutCubic),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _statsController.forward(),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final account = _controller.account;
        if (account == null) {
          return _SignedOutView(onSignIn: () => Get.toNamed(AppRoutes.login));
        }
        final theme = Theme.of(context);
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const NotificationPermissionBanner(),
            Center(
              child: AnimatedBuilder(
                animation: _ringController,
                builder: (context, _) => AnimatedAvatarRing(
                  avatarUrl: account.avatarUrl,
                  progress: _ringController.value,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                account.displayName,
                style: theme.textTheme.titleLarge,
              ),
            ),
            Center(
              child: Text(
                '@${account.username}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'FAVORITES',
                    value: '${_controller.favoritesCount}',
                    reveal: _statReveals[0],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'RATED',
                    value: '${_controller.ratedCount}',
                    reveal: _statReveals[1],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'ACCOUNT ID',
                    value: '${account.id}',
                    reveal: _statReveals[2],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _DeviceInfoRow(controller: _controller),
            const SizedBox(height: 28),
            OutlinedButton(
              style: AppButtonStyles.outlined(context),
              onPressed: _controller.logout,
              child: const Text('LOG OUT'),
            ),
          ],
        );
      }),
    );
  }
}

class _DeviceInfoRow extends StatelessWidget {
  final ProfileController controller;
  const _DeviceInfoRow({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final info = controller.deviceInfo.value;
      if (info == null) return const SizedBox.shrink();
      final theme = Theme.of(context);
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(
              Icons.phone_iphone,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${info.platform} · ${info.model} · ${info.osVersion}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SignedOutView extends StatelessWidget {
  final VoidCallback onSignIn;
  const _SignedOutView({required this.onSignIn});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 48,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to see your profile',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: AppButtonStyles.filled(context),
              onPressed: onSignIn,
              child: const Text('SIGN IN'),
            ),
          ],
        ),
      ),
    );
  }
}
