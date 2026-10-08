# Learning Dashboard (Flutter · BLoC)

Login → Course Dashboard → Course Details (mark lessons complete), with offline support.
**Demo login:** `student@example.com` / `password123`

```bash
flutter pub get
flutter run --flavor development -t lib/main_development.dart
flutter test                                    # 24 tests: domain, repository (real SQLite), blocs
flutter build apk --release --flavor production -t lib/main_production.dart
```

```
lib/
  core/        error types, network check, SQLite setup, secure token storage
  features/
    auth/      domain (validator, repo interface) · data (mock API, repo) · presentation (LoginBloc + page)
    courses/   domain (Course, Lesson, repo interface) · data (mock API, SQLite cache, repo) · presentation (CoursesBloc, CourseDetailBloc + pages)
  app/         MaterialApp + GoRouter      bootstrap.dart = composition root (wires all dependencies)
```

## 1. Architecture
Feature-first **Clean Architecture + BLoC**: `UI → Bloc → Repository (interface) → API + Local DB`.
- Blocs hold no I/O; they depend on repository *interfaces*, so they are tested with mocks.
- The domain layer is pure Dart. `Course.progressPercent` is **derived from lessons**, never stored, so dashboard and details can't disagree.
- One sealed `AppException` hierarchy crosses layers; the UI maps it to localized text with an exhaustive `switch`.
- Dependencies are injected via constructors from one composition root (`bootstrap.dart`) and exposed with `RepositoryProvider` — no hidden globals.
- Event transformers handle real-world concurrency: `droppable()` for refresh (no duplicate calls), `sequential()` for lesson taps (no lost updates).

## 2. Offline Support
- **SQLite (`sqflite`)** with `courses` and `lessons` tables; the whole list is replaced in one transaction.
- `fetchCourses()` is **network-first, cache-fallback**: on success it caches; on failure it returns the cache with `isFromCache = true` (UI shows an offline banner). It only errors if the cache is empty too.
- Lesson completion is **local-first** (instant, works offline), then sent to the server best-effort.
- Merge rule: completion only goes false → true, so on refresh `completed = server OR local`. A lesson finished offline isn't undone by the next sync, and no conflict resolution is needed.
- The mock API checks real connectivity (DNS lookup), so turning the internet off really does exercise the cache path.

## 3. Security
Auth tokens go in **Keychain (iOS) / Android Keystore** via `flutter_secure_storage` (already used here), never in SharedPreferences, SQLite or logs. In production I would also use a short-lived access token plus a rotating refresh token, keep tokens in memory for an interceptor, use certificate pinning, and clear storage on logout. Root/jailbreak checks and screenshot protection would depend on the app's risk level.

## 4. Scale (1M users, hundreds of courses)
1. **Pagination + lazy loading**: paginated `/courses` and separate `/courses/{id}/lessons`; a `ListView.builder` already renders only visible items.
2. **Sync queue**: persist pending completions in an outbox table and retry them with WorkManager / BGTaskScheduler using idempotent requests. Fetch only changes with ETag / `updated_since` instead of whole payloads.
3. **Networking**: Dio with auth/refresh-token, retry/backoff and logging interceptors, plus HTTP caching. Serve assets from a CDN.
4. **Observability**: Crashlytics/Sentry (hook already in `bootstrap`), analytics, performance traces and remote feature flags for staged rollouts.
5. **Codebase scale**: split features into packages (melos/pub workspaces), use code-gen models (`freezed`/`json_serializable`), and add widget, golden and integration tests in CI.

## 5. Second Platform
This Flutter codebase already runs on **Android and iOS**. Only platform config differs: Keychain vs Keystore (handled by the plugin), iOS `NSAppTransportSecurity` / Android network-security config, background sync (BGTaskScheduler vs WorkManager) and store signing. If a **native** version were required, the same layers map directly:
- **Android:** Compose UI → `ViewModel` + `StateFlow<UiState>` → Repository → Retrofit + **Room** (a `Flow` DAO updates the dashboard automatically), Hilt for DI, WorkManager for the sync queue.
- **iOS:** SwiftUI → `@Observable` ViewModel (async/await) → Repository protocol → `URLSession` + **SwiftData/Core Data**, Keychain for tokens.

The domain rules (derived progress, OR-merge) port almost line for line.
