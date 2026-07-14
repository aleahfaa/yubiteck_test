import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../routing/app_routes.dart';

int? movieIdFromMessage(RemoteMessage message) =>
    int.tryParse(message.data['movieId'] ?? '');
void openMovieFromMessage(RemoteMessage message) {
  final movieId = movieIdFromMessage(message);
  if (movieId == null) return;
  Get.toNamed(AppRoutes.movieDetail, parameters: {'id': '$movieId'});
}
