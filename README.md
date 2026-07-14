# TMDB Movie Explorer

Aplikasi Flutter berbasis [TMDB API](https://www.themoviedb.org/) — jelajah/cari film, login TMDB, kelola favorit & rating, profil dengan animasi. Dibangun dengan **GetX** dan **Clean Architecture**.

[Demo video (screen record)](https://drive.google.com/file/d/12HHdbTPuaPE7OBiyMnpIMwRYznKW6TVm/view?usp=sharing) <br>
Link langsung: https://drive.google.com/file/d/12HHdbTPuaPE7OBiyMnpIMwRYznKW6TVm/view?usp=sharing

## 1. Cara Menjalankan

```bash
flutter pub get
cp env.json.example env.json   # isi TMDB_API_KEY & TMDB_READ_ACCESS_TOKEN (dari themoviedb.org/settings/api)
flutter run --dart-define-from-file=env.json
```

Contoh isi `env.json` (key yang dipakai untuk submission ini):

```json
{
  "TMDB_API_KEY": "375602eb16745497ff24a45fda79af72",
  "TMDB_READ_ACCESS_TOKEN": "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzNzU2MDJlYjE2NzQ1NDk3ZmYyNGE0NWZkYTc5YWY3MiIsIm5iZiI6MTc4MzY5NTYxMy41NTYsInN1YiI6IjZhNTEwOGZkNmRkMGNhOTIxMzY2YzA3NCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.EqI0Iz5q-sTfimVbLgSaNMH5k0Z2UsmFTEEjHXMrPPQ"
}
```

- Tanpa API key, aplikasi tetap jalan tapi request TMDB gagal (muncul error state di layar terkait).
- Target: Android, iOS, Web, Windows/Linux/macOS. Login pakai in-app WebView di Android/iOS/macOS, dan browser sistem di Windows/Linux/Web.
- **FCM (opsional)**: `firebase_options.dart` sudah punya config Android asli (`yubitecktest`), tapi iOS/web/macOS masih placeholder — jalankan `flutterfire configure` untuk mengisinya. Tanpa itu, seluruh app tetap jalan normal, hanya push notification yang tidak aktif.
- Test & analisis: `flutter analyze` && `flutter test` (87 test).

## 2. Arsitektur

Clean Architecture per-fitur, di `lib/features/<nama>/`: `presentation → domain → data`, tiap layer hanya bergantung ke layer di dalamnya.

- **domain/** — tanpa dependensi framework (murni Dart): entity (`Movie`, `Account`, …), interface repository, usecase satu-tanggung-jawab (`GetMovies`, `ToggleFavorite`, …).
- **data/** — implementasi nyata: model `fromJson`, `*RemoteDataSource` (Dio), `*RepositoryImpl` yang mengubah exception → `Failure` domain.
- **presentation/** — GetX: controller per layar, `Bindings` per rute, halaman/widget. Struktur tiap fitur sengaja flat (tanpa subfolder `pages/`/`controllers/`/`widgets/`) karena tiap fitur kecil.

Struktur folder `lib/core/` penting:
- `network/` — `DioClient` + interceptor (`TmdbAuthInterceptor` nempel `session_id`, `LoggingInterceptor`), `Result<Failure,T>` + `result_guard.dart` (satu helper try/catch→Failure dipakai semua repository, tidak diduplikasi).
- `presentation/view_state.dart` — `ViewState<T>` sealed class, dipakai semua controller (lihat §3).
- `di/initial_binding.dart` — singleton permanen (DioClient, SessionStore, AuthController, dll) via `Get.put(permanent: true)`.
- `services/` — SessionStore, NativeBridgeService, FcmService, dll.

## 3. State Management: GetX — dan Alasannya

**Kenapa GetX?** Aplikasi ini butuh 3 hal sekaligus: reactive state, dependency injection, dan named routing per-rute. GetX satu-satunya paket yang mencakup ketiganya dengan API kecil & konsisten (`.obs`/`Obx`, `Get.put`/`Get.find`, `GetPage`), dibanding merangkai 3 paket berbeda (mis. Bloc + get_it + go_router) dengan 3 mental model berbeda. Bonus: reactive primitive-nya gampang di-unit-test tanpa `WidgetTester` — controller cukup diinstansiasi langsung lalu baca `.value`.

**Pola state seragam** — bukan boolean ad-hoc atau `RxStatus` bawaan GetX (tidak punya slot data bertipe):

```dart
sealed class ViewState<T> {}
class ViewIdle<T> extends ViewState<T> {}
class ViewLoading<T> extends ViewState<T> {}
class ViewLoaded<T> extends ViewState<T> { final T data; }
class ViewEmpty<T> extends ViewState<T> { final String? message; }
class ViewFailure<T> extends ViewState<T> { final String message; }
```

Controller pegang `Rx<ViewState<T>>`, halaman render lewat `Obx(() => switch (state) {...})` — `switch` exhaustive Dart 3 bikin compiler menolak kalau ada state yang lupa ditangani.

**Optimistic update** — `FavoritesController` & `RatingsController` mengubah state lokal duluan sebelum request selesai, baru rollback kalau gagal (biar tap heart/rating terasa instan). Diuji di `favorites_controller_test.dart` & `ratings_controller_test.dart`.

## 4. Jawaban Studi Kasus

| Requirement | Implementasi |
|---|---|
| List + detail film dari REST API | `features/movies/` — infinite scroll (Popular/Now Playing/Top Rated/Upcoming), detail + cast + genre |
| Search + debounce + state management | `features/search/` — `Debouncer` custom 450ms (bukan `Worker` GetX, agar bisa diuji dengan `fake_async` tanpa nunggu asli) + counter "request generation" agar respons lambat yang basi tidak menimpa hasil baru; `CancelToken` Dio membatalkan request lama |
| Login via request token | `features/auth/` — `GET token/new` → approve di themoviedb.org (WebView mobile / browser desktop) → `POST session/new` → `session_id` disimpan di `flutter_secure_storage`; `AuthGateMiddleware` menjaga rute `/favorites` & `/profile` |
| Tambah/hapus favorit | `features/favorites/` — optimistic update + rollback |
| Beri/hapus rating | `features/ratings/` — optimistic update + rollback |
| Halaman profil, custom UI + animasi | `features/profile/` — Hero avatar transition, ring animasi custom-painted, staggered reveal untuk stat |
| Firebase Cloud Messaging | `core/services/fcm_service.dart` (abstraksi `PushNotificationGateway`, no-op otomatis di Windows/Linux) |
| Bonus: native module | Platform channel `com.yubiteck.test/native_bridge` (Kotlin/Swift) — haptic feedback + device info, dipakai di tombol favorit & halaman profil |
| Bonus: unit test | 87 test (`mocktail`, tiap layer mock layer di bawahnya) |

## 5. Keterbatasan

- Sudah dijalankan & diverifikasi di device Android asli. Belum pernah dijalankan di iOS/device Apple — WebView login, animasi, dan build Swift-nya baru diverifikasi lewat `flutter analyze` + `flutter test`, perlu dicek manual di perangkat iOS.
- Push notification: config Firebase Android sudah asli dan berjalan, tapi iOS/web/macOS masih placeholder (`flutterfire configure` belum dijalankan untuk platform tsb).
- Jumlah favorit/rating di halaman profil bersifat perkiraan (dari data yang sudah "terlihat" selama sesi berjalan), karena TMDB tidak menyediakan endpoint listing rating lengkap.
