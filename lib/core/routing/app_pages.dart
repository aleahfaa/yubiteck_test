import 'package:get/get.dart';
import '../presentation/splash_page.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/auth_gate_middleware.dart';
import '../../features/auth/presentation/auth_webview_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/favorites/presentation/favorites_binding.dart';
import '../../features/favorites/presentation/favorites_page.dart';
import '../../features/movies/presentation/movie_detail_binding.dart';
import '../../features/movies/presentation/movies_binding.dart';
import '../../features/movies/presentation/movie_detail_page.dart';
import '../../features/movies/presentation/movies_page.dart';
import '../../features/profile/presentation/profile_binding.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/search/presentation/search_binding.dart';
import '../../features/search/presentation/search_page.dart';

abstract final class AppPages {
  static const String initial = AppRoutes.splash;
  static final List<GetPage> routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(
      name: AppRoutes.movies,
      page: () => const MoviesPage(),
      binding: MoviesBinding(),
    ),
    GetPage(
      name: AppRoutes.movieDetail,
      page: () => const MovieDetailPage(),
      binding: MovieDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchPage(),
      binding: SearchBinding(),
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.authWebview, page: () => const AuthWebviewPage()),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesPage(),
      binding: FavoritesBinding(),
      middlewares: [AuthGateMiddleware()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
      middlewares: [AuthGateMiddleware()],
    ),
  ];
}
