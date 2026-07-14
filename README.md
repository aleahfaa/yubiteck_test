# TMDB Movie Explorer

A Flutter case-study app built on [The Movie Database (TMDB)](https://www.themoviedb.org/) API — browse and search movies, sign in with a TMDB account, manage favorites and ratings, and view a custom-animated profile. Built with **GetX** and a **feature-first Clean Architecture**, in a strict **monochrome** (black/white/grey) UI.

## Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
- [Architecture](#architecture)
- [State Management Deep Dive](#state-management-deep-dive)
- [Authentication Flow](#authentication-flow)
- [Search & Debounce](#search--debounce)
- [Native Platform Channel (Bonus)](#native-platform-channel-bonus)
- [Push Notifications (FCM)](#push-notifications-fcm)
- [Testing (Bonus)](#testing-bonus)
- [Case Study Requirements Mapping](#case-study-requirements-mapping)
- [Known Limitations & Manual Verification Needed](#known-limitations--manual-verification-needed)
- [Design Decisions](#design-decisions)

## Overview

- Browse Popular / Now Playing / Top Rated / Upcoming movies, with infinite scroll.
- Movie detail with cast, trailer link, genres, and account-aware favorite/rating controls.
- Debounced search across the TMDB catalog.
- TMDB session-based login (request token → approve on themoviedb.org → session).
- Add/remove favorites and give/remove a 0.5–10 rating, both with optimistic UI.
- A custom-animated Profile page (Hero avatar transition, animated ring, staggered stat reveal).
- Firebase Cloud Messaging scaffold for push notifications.
- Bonus: a native Android/iOS platform channel (haptics + device info), and a unit test suite (82 tests).

## Getting Started

### Prerequisites

- Flutter 3.44+ / Dart 3.12+ (stable channel).
- A [TMDB account](https://www.themoviedb.org/signup) and API key.
- (Optional, for push notifications) A Firebase project and the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli).

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure your TMDB API key

No key is hardcoded anywhere in this repo. Supply it at build/run time via `--dart-define`, or (more convenient for local dev) via `--dart-define-from-file`:

```bash
cp env.json.example env.json
# then edit env.json with your real TMDB key + v4 read access token
```

`env.json` is git-ignored. Then run with:

```bash
flutter run --dart-define-from-file=env.json
```

Or inline, without a file:

```bash
flutter run \
  --dart-define=TMDB_API_KEY=your-key \
  --dart-define=TMDB_READ_ACCESS_TOKEN=your-v4-read-token
```

Get both values from [themoviedb.org/settings/api](https://www.themoviedb.org/settings/api). This app authenticates every request with the **v4 read access token** as a `Bearer` header (see `lib/core/network/dio_client.dart`); `TMDB_API_KEY` is kept available for any v3 `api_key`-style usage but isn't required for the endpoints this app calls.

Without a key, the app still launches, but every TMDB request will fail with an auth error surfaced in the relevant screen's error state.

### 3. (Optional) Configure Firebase / FCM

`lib/firebase_options.dart` in this repo is a **placeholder** — Firebase initialization is wrapped in a try/catch in `main.dart`, so the app runs fine without it (movies/search/auth/favorites/ratings/profile all work; only push notifications stay inert). To wire up real push notifications:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This regenerates `lib/firebase_options.dart` and drops `google-services.json` / `GoogleService-Info.plist` into the platform folders (both are git-ignored). Additional manual steps:

- **iOS**: in Xcode, enable the "Push Notifications" and "Background Modes → Remote notifications" capabilities for the `Runner` target.
- **Android**: no extra manual step beyond `flutterfire configure`; the app requests the Android 13+ `POST_NOTIFICATIONS` runtime permission via the in-app "Enable" banner on the Profile page.
- **Windows/Linux**: FCM has no official desktop support — the app detects this and uses a no-op notification gateway there instead of crashing.

### 4. Run

```bash
flutter run --dart-define-from-file=env.json
```

Targets Android, iOS, and Web/Desktop (Windows/Linux/macOS) — all six `flutter create` platform folders are present. Login uses an in-app WebView on Android/iOS/macOS, and falls back to the system browser on Windows/Linux/Web (see [Authentication Flow](#authentication-flow)).

### 5. Run tests / static analysis

```bash
flutter analyze
flutter test
```

## Architecture

**Clean Architecture, feature-first.** Every feature under `lib/features/<name>/` is split into three layers, each depending only inward:

```
presentation  →  domain  →  data
(GetX controllers,   (entities,        (models, datasources,
 bindings, pages,     repository        repository implementations —
 widgets)             interfaces,       Dio/Firebase/secure-storage
                       usecases)         live here, and only here)
```

- **`domain/`** has zero framework dependencies — no Dio, no GetX, no Flutter widgets. It's plain Dart: entities (`Movie`, `Account`, `AccountStates`, …), repository *interfaces*, and single-purpose usecases (`GetMovies`, `CreateSession`, `ToggleFavorite`, …).
- **`data/`** implements those interfaces: JSON models (`MovieModel extends Movie`) with `fromJson`, `*RemoteDataSource` classes that own the actual `Dio` calls, and `*RepositoryImpl` classes that translate data-layer exceptions into domain-layer `Failure`s.
- **`presentation/`** is GetX: one controller per screen/concern, a `Bindings` subclass per route wiring the dependency graph, and the pages/widgets themselves.

```
lib/
  main.dart, app.dart, firebase_options.dart (placeholder)
  core/
    config/env.dart                 — --dart-define reads
    constants/api_constants.dart    — TMDB endpoints, image URLs
    network/                        — DioClient, interceptors, Result<F,T>, error mapping
    error/                          — Failure (domain) / Exception (data) hierarchies
    theme/                          — monochrome ColorScheme/ThemeData, light + dark
    routing/                        — AppRoutes, AppPages (GetPage table)
    usecase/usecase.dart            — abstract UseCase<R, Params>
    presentation/view_state.dart    — sealed ViewState<T>, shared by every controller
    services/                       — SessionStore, NativeBridgeService, notifications/*
    di/initial_binding.dart         — app-wide permanent singletons
    widgets/                        — MonoNetworkImage, AppLoadingView/ErrorView/EmptyView, button styles
  features/
    movies/        — lists (popular/now playing/top rated/upcoming), detail, account_states
    search/        — debounced search (reuses movies' Movie entity)
    auth/          — TMDB request_token → session flow, AuthController, AuthGateMiddleware
    favorites/     — add/remove favorite, optimistic FavoritesController
    ratings/       — rate/delete rating, AnimatedRatingDial, optimistic RatingsController
    profile/       — custom UI, Hero + ring + staggered-reveal animations
    notifications/ — NotificationsController wrapping PushNotificationGateway
test/
  core/, features/<name>/{data,domain,presentation}/  — mirrors lib/, mocktail-mocked at each layer boundary
  helpers/mock_helpers.dart  — shared Mock classes + SessionStore test helper
```

**Networking.** A single `Dio` instance (`core/network/dio_client.dart`) is shared by every datasource, with two interceptors: `TmdbAuthInterceptor` attaches the current `session_id` to any request tagged `extra: {'requiresSession': true}` (favorites, ratings, `/account`), and `LoggingInterceptor` logs requests in debug builds only. `core/network/dio_exception_mapper.dart` turns any `DioException` into one of this app's own exception types (`NetworkException`, `ServerException`, `AuthException`, …); `core/network/result_guard.dart` then turns those into a `Result<Failure, T>` inside every repository — this one small helper is the entire try/catch-to-Failure translation layer, reused by all six repositories instead of being duplicated six times.

**DI.** GetX bindings only — no `get_it`. A single container avoids running two competing DI lifecycles side by side, and GetX bindings already tie naturally into route lifecycle (`Get.lazyPut` disposes with the route; `fenix: true` is used for the small number of controllers — `FavoritesController`, `RatingsController` — that need to survive navigation because they hold an app-wide optimistic cache). Truly global singletons (`DioClient`, `SessionStore`, `AuthController`, `NativeBridgeService`, `PushNotificationGateway`) are `Get.put(permanent: true)` in `InitialBinding`, attached to `GetMaterialApp(initialBinding:)`.

**Why GetX (state management choice).** This app needs reactive state, dependency injection, and named routing with per-route bindings — GetX is the one package that covers all three with a small, consistent API (`.obs` / `Rx<T>` / `Obx`, `Get.put`/`Get.find`, `GetPage`/`Get.toNamed`), instead of stitching together three separate packages (e.g. Bloc + get_it + go_router) with three different mental models. Its reactive primitives are also trivial to unit-test without pumping a widget tree — every controller in this repo is tested by constructing it directly and reading `.value`/`.stream`, no `WidgetTester` required except for the couple of true widget-level smoke tests.

## State Management Deep Dive

Every screen-level controller exposes state through one shared, hand-rolled type instead of ad-hoc booleans or GetX's built-in `RxStatus` (which has no typed payload slot):

```dart
// lib/core/presentation/view_state.dart
sealed class ViewState<T> {}
final class ViewIdle<T> extends ViewState<T> {}
final class ViewLoading<T> extends ViewState<T> {}
final class ViewLoaded<T> extends ViewState<T> { final T data; }
final class ViewEmpty<T> extends ViewState<T> { final String? message; }
final class ViewFailure<T> extends ViewState<T> { final String message; }
```

Controllers hold `Rx<ViewState<T>>`; pages render with `Obx(() => switch (controller.state.value) { ... })` — Dart 3's exhaustive `switch` on a sealed type means the compiler flags a missing case, so a page can never accidentally forget to handle e.g. the error state. `MoviesController`, `MovieDetailController`, `MovieSearchController`, `FavoritesController`, `AuthController` (keyed on `Account`) all use this same pattern.

**Optimistic updates.** `FavoritesController` and `RatingsController` both flip their local state *before* the network call resolves, then roll back only if the call fails — this is what makes tapping the heart/rating icon feel instant. Both are covered by dedicated tests (`favorites_controller_test.dart`, `ratings_controller_test.dart`) asserting the optimistic value is visible immediately and the rollback happens correctly on failure.

## Authentication Flow

TMDB's [session-based auth](https://developer.themoviedb.org/docs/authentication-user-issued-requests) (`lib/features/auth/`):

1. `GET /authentication/token/new` → a short-lived `request_token` (`CreateRequestToken` usecase).
2. The user approves that token on themoviedb.org:
   - **Android / iOS / macOS**: opened in an in-app `webview_flutter` view (`AuthorizeWebview`), with a persistent "I've approved" bar underneath (TMDB doesn't redirect back into the app, so this is a manual confirmation, not an automatic handshake).
   - **Windows / Linux / Web**: opened in the system browser via `url_launcher` instead, since `webview_flutter` has no first-party support there — same "I've approved / Cancel" bar, just over an explanatory screen instead of an embedded view.
3. `POST /authentication/session/new {request_token}` → `session_id` (`CreateSession` usecase), persisted via `flutter_secure_storage` (wrapped by `SessionStore`, see below).
4. `GET /account?session_id=...` → the account (id, username, avatar), also persisting `account_id` (needed by the favorites/ratings endpoints).
5. On every app start, `AuthController.restore()` (called from `SplashPage`) re-validates any cached session against `/account` — a missing/expired session is treated as "not logged in yet," not an error.
6. `AuthGateMiddleware` (`GetMiddleware.redirect`) guards the `/favorites` and `/profile` routes, redirecting to `/login` when `AuthController.isAuthenticated` is false. Movie browsing and search are **not** gated — TMDB's read endpoints don't need a session, and requiring login just to look at a movie would be bad UX. The favorite button and rating dial (which *do* need a session, but live on the public detail page) each check `AuthController.isAuthenticated` themselves and redirect to `/login` on tap if needed, since a route-level middleware can't gate a single button on an otherwise-public page.
7. `TmdbAuthInterceptor` (in `core/network/`) attaches `session_id` to any Dio request whose `RequestOptions.extra['requiresSession']` is `true` — the session lives in `SessionStore`, read synchronously so the interceptor never awaits storage I/O per request.
8. Logout: `DELETE /authentication/session`, then clear `SessionStore`.

## Search & Debounce

`lib/features/search/presentation/controllers/movie_search_controller.dart` (named `MovieSearchController` — Flutter's own Material library already defines `SearchController`):

- A small hand-rolled `core/utils/debouncer.dart` (`Timer`-based, 450ms) is used instead of GetX's built-in `debounce()` `Worker`, specifically because a raw `Timer` is deterministically fake-able with `package:fake_async` — the debounce tests (`movie_search_controller_test.dart`) run entirely inside a `fakeAsync` zone with zero real waiting.
- Every keystroke resets the timer; the debounced call only fires once the user pauses.
- A monotonically-increasing "request generation" counter discards any response that resolves *after* a newer search has already started — this is what stops a slow, stale response from ever overwriting a faster, fresher one (also unit-tested, simulating a 2-second-slow first query superseded by an instant second one).
- Actual request cancellation happens one layer down, in `SearchRemoteDataSourceImpl`: it owns a `CancelToken` and cancels the previous in-flight HTTP request whenever a new one starts, so a superseded query doesn't even finish downloading. This keeps `dio`'s `CancelToken` (a data-layer/Dio concept) out of the domain layer — the usecase signature is just `(query, page) → Result<Failure, PaginatedMovies>`.

## Native Platform Channel (Bonus)

Channel `com.yubiteck.test/native_bridge`, two methods:

| Method | Android (Kotlin) | iOS (Swift) |
|---|---|---|
| `triggerHapticFeedback` | `View.performHapticFeedback(VIRTUAL_KEY)` | `UIImpactFeedbackGenerator(style: .light)` |
| `getDeviceInfo` | `Build.MANUFACTURER/MODEL/VERSION.RELEASE` | `UIDevice.current.model/systemVersion` |

- `android/app/src/main/kotlin/com/example/yubiteck_test/MainActivity.kt` — registers the `MethodChannel` in `configureFlutterEngine`.
- `ios/Runner/AppDelegate.swift` — registers it in `didInitializeImplicitFlutterEngine` (this template's newer implicit-engine lifecycle).
- `lib/core/services/native/native_bridge_service.dart` — the Dart wrapper, guarded so it silently no-ops on `kIsWeb`/Windows/Linux (no native counterpart there) and catches `PlatformException`/`MissingPluginException` rather than crashing the caller.
- **Used from**: the favorite button (`features/favorites/presentation/widgets/favorite_button.dart`) triggers a haptic pulse on every toggle; the Profile page shows a small device-info row (`platform · model · osVersion`) fed by `getDeviceInfo`.
- Dart-side logic is unit-tested (`test/core/services/native/native_bridge_service_test.dart`) via Flutter's `TestDefaultBinaryMessengerBinding` mock channel handler — the Kotlin/Swift itself can't be compiled or executed in this repo's build environment; see [Known Limitations](#known-limitations--manual-verification-needed).

## Push Notifications (FCM)

Scaffolded per [Getting Started → step 3](#3-optional-configure-firebase--fcm) above:

- `core/services/notifications/push_notification_gateway.dart` — an abstract `PushNotificationGateway` interface (`initialize`, `requestPermission`, `getToken`, `onForegroundMessage`/`onMessageOpenedApp` streams). Everything downstream (`NotificationsController`) depends on this interface, not on Firebase directly, so it's fully unit-testable with a mock gateway.
- `core/services/notifications/fcm_service.dart` — the real implementation, plus the required top-level `firebaseMessagingBackgroundHandler` (Firebase requires this to be a top-level/static function, since it runs in a separate isolate).
- `core/services/notifications/local_notification_service.dart` — shows a visible system notification for *foreground* messages via `flutter_local_notifications` (Android doesn't auto-display a notification for a message that arrives while the app is open, unlike background/terminated delivery).
- `core/services/notifications/noop_push_notification_gateway.dart` — used automatically on Windows/Linux (no FCM support) so the rest of the app never has to branch on platform.
- `features/notifications/` — `NotificationsController` + a `NotificationPermissionBanner` shown on the Profile page when permission hasn't been granted yet.
- Every call into the real gateway is wrapped in try/catch — a placeholder `firebase_options.dart` (i.e. `flutterfire configure` not yet run) must never crash the Profile page or app startup.

## Testing (Bonus)

```bash
flutter test
```

82 tests, mirroring `lib/`'s structure under `test/`. Each layer is tested against a mock of the layer directly beneath it (repository tests mock datasources; usecase tests mock repositories; controller tests mock usecases), using `mocktail` — no code generation, so there's no `build_runner` step in the test loop.

Highlights:
- **Debounce/staleness** (`movie_search_controller_test.dart`) — driven entirely by `fakeAsync`; asserts the exact number of underlying calls fired across a sequence of keystrokes, and that a slow stale response never overwrites a fresh one.
- **Optimistic update + rollback** (`favorites_controller_test.dart`, `ratings_controller_test.dart`) — asserts the UI-visible state flips immediately and rolls back correctly on a failed API call.
- **Auth state machine** (`auth_controller_test.dart`, `auth_repository_impl_test.dart`) — request_token → session → account sequence, secure-storage persistence, logout.
- **Native channel** (`native_bridge_service_test.dart`) — mocked `MethodChannel` via `TestDefaultBinaryMessengerBinding`, plus a platform-override test proving it no-ops on Windows.
- **Notifications gateway** (`notifications_controller_test.dart`) — mocked `PushNotificationGateway`; asserts a thrown exception from Firebase never propagates out of the controller.
- Every controller test calls `Get.reset()` in `tearDown()` to avoid singleton bleed between tests.

## Case Study Requirements Mapping

| Requirement | Where |
|---|---|
| Movie list + detail from REST API | `features/movies/` (`data/datasources/movies_remote_data_source.dart`, `presentation/pages/movies_page.dart`, `movie_detail_page.dart`) |
| Search with debounce + state management | `features/search/` (see [Search & Debounce](#search--debounce)) |
| Login via request token | `features/auth/` (see [Authentication Flow](#authentication-flow)) |
| Add/remove favorites | `features/favorites/` |
| Give/remove rating | `features/ratings/` |
| Profile page, custom UI + animation | `features/profile/presentation/pages/profile_page.dart`, `widgets/animated_avatar_ring.dart` (Hero + custom-painted ring sweep), `widgets/stat_tile.dart` (staggered slide/fade reveal) |
| Firebase Cloud Messaging | [Push Notifications (FCM)](#push-notifications-fcm) |
| Bonus: native module | [Native Platform Channel](#native-platform-channel-bonus) |
| Bonus: unit tests | [Testing](#testing-bonus) |
| README: run instructions, architecture, state-management rationale, case-study answers | this file |

## Known Limitations & Manual Verification Needed

This app was built without a running Android/iOS emulator or a real Firebase project — `flutter analyze` and `flutter test` were the verification tools available. The following need manual confirmation on a real device/build once you have one:

- **WebView login UX** (`AuthorizeWebview`) — never rendered on a device; verify the embedded page loads and the "I've approved" flow completes correctly on Android/iOS.
- **Animation smoothness** — the Profile page's Hero transition, custom-painted ring, and staggered stat reveal build without error and their `AnimationController`s dispose correctly, but true visual polish needs eyes on a device.
- **Real push notification delivery** — requires `flutterfire configure` against a real Firebase project, then sending a test message from the Firebase console.
- **Native Kotlin/Swift code** (`MainActivity.kt`, `AppDelegate.swift`) — written carefully against each platform's plugin API, but not compiled here (no Android/Xcode toolchain in this environment). Build once on each platform to confirm.
- **Favorites/rated counts on the Profile page** are approximate — they reflect what the app has *seen* this session (the loaded favorites page's `total_results`, plus anything synced from a detail-page visit), since this app doesn't implement a full "list all rated movies" screen (TMDB's rating feature only requires rate/unrate, not a listing UI).

## Design Decisions

A couple of choices worth calling out, in case you'd make them differently:

- **Auth UX split by platform** — in-app WebView on mobile, system browser on desktop/web — trades one extra dependency (`webview_flutter`) for a more native-feeling mobile login. The simpler alternative (system browser everywhere) was considered and would remove that dependency entirely.
- **Hand-rolled `Result<F, T>` and `Debouncer`** instead of `fpdart`/`dartz` and GetX's `Worker` — both are ~20-line types that avoid adding a dependency (`Result`) or add real testability (`Debouncer`, testable with `fake_async`) that the built-in alternative doesn't offer as cleanly.
- **No `freezed`/`json_serializable`** — models are hand-written. TMDB's response shapes are small and stable, and skipping codegen means `flutter test`/`flutter analyze` never need a `build_runner` step.
