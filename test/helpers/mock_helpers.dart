import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/services/push_notification_gateway.dart';
import 'package:yubiteck_test/core/services/session_store.dart';
import 'package:yubiteck_test/features/auth/data/auth_local_data_source.dart';
import 'package:yubiteck_test/features/auth/data/auth_remote_data_source.dart';
import 'package:yubiteck_test/features/auth/domain/auth_repository.dart';
import 'package:yubiteck_test/features/auth/domain/create_request_token.dart';
import 'package:yubiteck_test/features/auth/domain/create_session.dart';
import 'package:yubiteck_test/features/auth/domain/logout.dart';
import 'package:yubiteck_test/features/auth/domain/restore_session.dart';
import 'package:yubiteck_test/features/favorites/data/favorites_remote_data_source.dart';
import 'package:yubiteck_test/features/favorites/domain/favorites_repository.dart';
import 'package:yubiteck_test/features/favorites/domain/get_favorite_movies.dart';
import 'package:yubiteck_test/features/favorites/domain/toggle_favorite.dart';
import 'package:yubiteck_test/features/movies/data/movies_remote_data_source.dart';
import 'package:yubiteck_test/features/movies/domain/movies_repository.dart';
import 'package:yubiteck_test/features/movies/domain/get_account_states.dart';
import 'package:yubiteck_test/features/movies/domain/get_movie_detail.dart';
import 'package:yubiteck_test/features/movies/domain/get_movies.dart';
import 'package:yubiteck_test/features/ratings/data/ratings_remote_data_source.dart';
import 'package:yubiteck_test/features/ratings/domain/ratings_repository.dart';
import 'package:yubiteck_test/features/ratings/domain/delete_rating.dart';
import 'package:yubiteck_test/features/ratings/domain/rate_movie.dart';
import 'package:yubiteck_test/features/search/data/search_remote_data_source.dart';
import 'package:yubiteck_test/features/search/domain/search_repository.dart';
import 'package:yubiteck_test/features/search/domain/search_movies.dart';

// Movies
class MockMoviesRemoteDataSource extends Mock
    implements MoviesRemoteDataSource {}

class MockMoviesRepository extends Mock implements MoviesRepository {}

class MockGetMovies extends Mock implements GetMovies {}

class MockGetMovieDetail extends Mock implements GetMovieDetail {}

class MockGetAccountStates extends Mock implements GetAccountStates {}

// Search
class MockSearchRemoteDataSource extends Mock
    implements SearchRemoteDataSource {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockSearchMovies extends Mock implements SearchMovies {}

// Auth
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockCreateRequestToken extends Mock implements CreateRequestToken {}

class MockCreateSession extends Mock implements CreateSession {}

class MockRestoreSession extends Mock implements RestoreSession {}

class MockLogout extends Mock implements Logout {}

// Favorites
class MockFavoritesRemoteDataSource extends Mock
    implements FavoritesRemoteDataSource {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockGetFavoriteMovies extends Mock implements GetFavoriteMovies {}

class MockToggleFavorite extends Mock implements ToggleFavorite {}

// Ratings
class MockRatingsRemoteDataSource extends Mock
    implements RatingsRemoteDataSource {}

class MockRatingsRepository extends Mock implements RatingsRepository {}

class MockRateMovie extends Mock implements RateMovie {}

class MockDeleteRating extends Mock implements DeleteRating {}

// Notifications
class MockPushNotificationGateway extends Mock
    implements PushNotificationGateway {}

// Core
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

/// A [SessionStore] with [accountId] pre-populated, backed by a mocked
/// [FlutterSecureStorage] so no platform channel is ever touched.
Future<SessionStore> sessionStoreWithAccountId(int accountId) async {
  final storage = MockFlutterSecureStorage();
  when(
    () => storage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((_) async {});
  final sessionStore = SessionStore(storage);
  await sessionStore.saveAccountId(accountId);
  return sessionStore;
}
