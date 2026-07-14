import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/routing/app_routes.dart';
import 'auth_controller.dart';

class AuthGateMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final isAuthenticated = Get.find<AuthController>().isAuthenticated;
    if (isAuthenticated) return null;
    return RouteSettings(
      name: AppRoutes.login,
      arguments: {'redirectTo': route},
    );
  }
}
