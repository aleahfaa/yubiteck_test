import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/presentation/auth_controller.dart';
import 'ratings_controller.dart';
import 'animated_rating_dial.dart';
import 'rating_input_sheet.dart';

class RatingDialButton extends StatelessWidget {
  final int movieId;
  final double size;
  const RatingDialButton({super.key, required this.movieId, this.size = 56});
  @override
  Widget build(BuildContext context) {
    final ratings = Get.find<RatingsController>();
    final auth = Get.find<AuthController>();
    return Obx(
      () => AnimatedRatingDial(
        value: ratings.ratingFor(movieId),
        size: size,
        onTap: () {
          if (!auth.isAuthenticated) {
            Get.toNamed(
              AppRoutes.login,
              arguments: {'redirectTo': AppRoutes.movieDetail},
            );
            return;
          }
          showRatingInputSheet(context, movieId: movieId);
        },
      ),
    );
  }
}
