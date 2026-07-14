abstract final class ApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String authenticateWebUrl =
      'https://www.themoviedb.org/authenticate';
  static const String posterSizeSmall = 'w185';
  static const String posterSizeMedium = 'w342';
  static const String posterSizeLarge = 'w500';
  static const String backdropSize = 'w780';
  static const String profileSize = 'w185';
  static const String originalSize = 'original';
  static String imageUrl(String? path, {String size = posterSizeMedium}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$size$path';
  }

  static const String authRequestToken = '/authentication/token/new';
  static const String authCreateSession = '/authentication/session/new';
  static const String authDeleteSession = '/authentication/session';
  static const String account = '/account';
  static String authorizeUrl(String requestToken) =>
      '$authenticateWebUrl/$requestToken';
  static String accountFavoriteMovies(int accountId) =>
      '/account/$accountId/favorite/movies';
  static String accountRatedMovies(int accountId) =>
      '/account/$accountId/rated/movies';
  static String accountFavorite(int accountId) =>
      '/account/$accountId/favorite';
  static const String moviePopular = '/movie/popular';
  static const String movieNowPlaying = '/movie/now_playing';
  static const String movieTopRated = '/movie/top_rated';
  static const String movieUpcoming = '/movie/upcoming';
  static String movieDetail(int id) => '/movie/$id';
  static String movieRating(int id) => '/movie/$id/rating';
  static String movieAccountStates(int id) => '/movie/$id/account_states';
  static const String searchMovie = '/search/movie';
}
