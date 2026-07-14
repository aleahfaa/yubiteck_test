abstract final class Env {
  static const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');
  static const String tmdbReadAccessToken = String.fromEnvironment(
    'TMDB_READ_ACCESS_TOKEN',
  );
  static bool get isConfigured => tmdbReadAccessToken.isNotEmpty;
}
