# iOS Adaptation + Platform Isolation — Design Spec

> **Status:** DRAFT (brainstorming approved; implementation deferred)
> **Created:** 2026-07-03
> **Author:** Claude (brainstorming session with FrankSWP)
> **Baseline:** `1b2093c` (v0.1.0, before refactor)

## Motivation

md_preview v0.1.0 ships a working Android app and a mostly-stubbed iOS shell (Info.plist declares the Markdown UTI but `AppDelegate.application(_:open:options:)` is a no-op; no Share Extension target exists). Two related concerns motivate this spec:

1. **iOS file opening is not wired up end-to-end.** A user tapping a `.md` file in the iOS Files app gets a "no app can open this" experience (or worse, a system share sheet that ignores our app).
2. **The codebase mixes cross-platform logic, Android-specific implementation, and iOS work-in-progress in the same `lib/` tree.** v2 (editor), v3 (export PDF/image) will multiply this pressure. We need a structural seam so future features don't have to fight the existing organization.

The user has explicitly requested:

- iOS and Android code should be **as separate as possible**
- iOS changes must **not break Android builds**
- The project must accommodate a **v2 (editor) + v3 (export PDF, export image)** roadmap with a mobile-Typora aspiration
- **No HarmonyOS / OpenHarmony work** in this cycle (Flutter OHOS is not GA, all our plugins lack OHOS implementations)

## Goals (in scope)

1. End-to-end iOS file opening: tap `.md` in Files app → `AppDelegate` → `receive_sharing_intent` → Dart `FileIntentReceiver` → `MarkdownView`
2. iOS Share Extension target for the "share text/file into md_preview" flow
3. Cupertino styling for `PreviewScreen`, `SettingsScreen`, dialogs
4. iPad adaptation: multi-window + master-detail at wide widths
5. Project restructured into `core / platform / platform_android / platform_ios / features / app` so iOS-only changes cannot reach Android-only code
6. Cross-language MethodChannel contract test suite (Dart ↔ Swift)
7. Static walkthrough of every Swift file in `ios/`

## Non-goals (out of scope this cycle)

- HarmonyOS / OpenHarmony — deferred until Flutter OHOS graduates
- v2 (editor) — `features/editor/` reserved as an empty placeholder
- v3 (export PDF / export image) — `features/export_pdf/` and `features/export_image/` reserved as empty placeholders
- iOS Universal Links (deep linking from web)
- iOS Live Activities / Widgets / App Intents
- macOS Catalyst / desktop builds
- Cloud sync, push notifications, account integration

---

## Architecture: Clean Architecture / Hexagonal in Flutter

### Top-level constraints (binding)

| # | Constraint | Mechanism |
|---|---|---|
| C1 | Android functionality must be unchanged in observable behavior | All current code moves locations; no semantic changes to Android paths |
| C2 | iOS and Android Dart code are physically separated | Separate entry points + `platform_android/` + `platform_ios/` directories |
| C3 | An iOS-only change cannot break an Android build | Android entry imports `platform_android/*` only; iOS files are unreachable from the Android entry, so the Dart compiler does not include them |
| C4 | New features can be added without touching existing modules | `features/<name>/` is a self-contained module; no cross-feature dependencies |
| C5 | All platform-specific logic goes through a port interface | `lib/platform/*.dart` defines abstract interfaces; concrete impls live under `platform_android/` or `platform_ios/` |
| C6 | Core logic has no I/O, no Flutter widget tree, no platform channels | `lib/core/` is pure Dart, fully unit-testable without `flutter_test` |

### Layer responsibilities

```
core/               Pure Dart. Markdown parsing, document model, storage
                   interfaces, Result<T,E> types, no I/O.

platform/           Port interfaces only. FileIntentReceiver,
                   LocalHttpServer, SettingsRepository contract
                   definitions. No implementations.

platform_android/   Android-only Dart. Implements port interfaces using
                   receive_sharing_intent, dart:io HttpServer,
                   SharedPreferences, content:// resolution.
                   Reachable from lib/main.dart only.

platform_ios/       iOS-only Dart. Implements port interfaces using
                   receive_sharing_intent + App Group + Share Extension,
                   dart:io HttpServer, NSUserDefaults.
                   Reachable from lib/main_ios.dart only.

features/           Vertical feature modules. Each is self-contained.
  reader/           Current preview functionality (MarkdownView,
                   WebViewBlock, CodeBlock, PreviewScreen).
  home/             HomeScreen (with iPad master-detail variant).
  settings/         SettingsScreen (with Cupertino variant).
  editor/           v2 placeholder. Empty directory + .gitkeep.
  export_pdf/       v3 placeholder. Empty directory + .gitkeep.
  export_image/     v3 placeholder. Empty directory + .gitkeep.

shared/             Reusable widgets with no feature-specific behavior
                   (Cupertino/Cupertino + shared typography helpers,
                   future: shared error/loading views).

app/                Composition root. Wires ports + features + theme
                   + routing into a runApp() target.
```

### Entry-point split (the critical isolation mechanism)

```bash
# Android: default entry
flutter build apk --release                       # uses lib/main.dart
flutter run -d <android-device>

# iOS: explicit entry
flutter build ios --release -t lib/main_ios.dart
flutter run -d <ios-device> -t lib/main_ios.dart
```

**`lib/main.dart`** (Android entry):

```dart
import 'package:flutter/widgets.dart';
import 'platform_android/file_intent_android.dart';
import 'platform_android/http_server_android.dart';
import 'platform_android/settings_repository_android.dart';
import 'app/app_android.dart';

void main() {
  runApp(AndroidApp(
    fileIntent: AndroidFileIntentReceiver(),
    httpServer: AndroidLocalHttpServer(),
    settings: AndroidSettingsRepository(),
  ));
}
```

**`lib/main_ios.dart`** (iOS entry):

```dart
import 'package:flutter/widgets.dart';
import 'platform_ios/file_intent_ios.dart';
import 'platform_ios/http_server_ios.dart';
import 'platform_ios/settings_repository_ios.dart';
import 'app/app_ios.dart';

void main() {
  runApp(IOSApp(
    fileIntent: IOSFileIntentReceiver(),
    httpServer: IOSLocalHttpServer(),
    settings: IOSSettingsRepository(),
  ));
}
```

Because Android entry imports `platform_android/*` only, the Dart compiler
**never reaches** `platform_ios/*`. A typo or build error in an iOS file
cannot break an Android build. The reverse also holds.

### Port interface example

```dart
// lib/platform/file_intent.dart
abstract class FileIntentReceiver {
  /// Emits the URI/path of every Markdown file the platform routes
  /// to this app (cold-start + warm-sharing).
  Stream<String> get fileOpenRequests;

  /// Hooks up platform channels / observers. Idempotent.
  Future<void> initialize();

  /// Cancels subscriptions and closes the stream.
  Future<void> dispose();
}
```

```dart
// lib/platform_android/file_intent_android.dart
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:md_preview/platform/file_intent.dart';

class AndroidFileIntentReceiver implements FileIntentReceiver {
  // wraps receive_sharing_intent's getMediaStream + getInitialMedia
}
```

```dart
// lib/platform_ios/file_intent_ios.dart
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:md_preview/platform/file_intent.dart';

class IOSFileIntentReceiver implements FileIntentReceiver {
  // same package, but the iOS-side Swift handles URL routing
  // through App Group + Share Extension
}
```

### Feature module shape

Each feature has the same internal layout (Clean Architecture within a feature):

```
features/reader/
  domain/             Pure Dart. Use-cases, value objects, view models.
  data/               Repository implementations (uses platform ports).
  presentation/
    screens/          Widget screens (Material + _ios.dart Cupertino).
    widgets/          Reusable presentation widgets.
```

**Cross-feature rules** (enforced by code review, not by tooling):

- Feature A may import from `core/`, `platform/`, `shared/`, and its own directory.
- Feature A **may not** import from another feature's directory. If shared
  code is needed, it belongs in `shared/` or `core/`.
- Features are not required to depend on each other.

### iOS file-open flow (end to end)

```
User taps .md in Files app
        ↓
iOS resolves UTType net.daringfireball.markdown
        ↓
iOS launches Runner with the file URL
        ↓
AppDelegate.application(_:open:options:)
        ↓
forward URL to receive_sharing_intent plugin
(plugin stores the file in App Group "group.com.frank.mdpreview")
        ↓
Dart side:
  IOSFileIntentReceiver.initialize()
    → ReceiveSharingIntent.getInitialMedia()  // reads App Group
    → emits URI on fileOpenRequests stream
  IOSFileIntentReceiver.stream subscription
    → ReceiveSharingIntent.getMediaStream()   // warm-sharing
        ↓
FileRepository.read(uri)   (core/storage interface impl)
        ↓
PreviewScreen receives MarkdownDocument
        ↓
MarkdownView renders blocks (Mermaid/KaTeX go to WebViewBlock)
```

The "Share into md_preview" flow:

```
User in another app → Share sheet → md_preview
        ↓
iOS presents Share Extension (RunnerShareExt)
        ↓
ShareViewController.swift writes file(s) to App Group
        ↓
iOS dismisses extension, brings Runner to foreground
        ↓
receive_sharing_intent's iOS channel fires
        ↓
Dart side: same as above
```

### Cupertino / iPad scope (YAGNI-respecting)

Components touched:

| Component | Android | iOS | Why |
|---|---|---|---|
| App root | `MaterialApp` | `CupertinoApp` | iOS users expect iOS chrome |
| App bar | `AppBar` | `CupertinoNavigationBar` | Visual + behavior parity with iOS |
| Settings | `ListView` + `SwitchListTile` | `CupertinoFormSection.insetGrouped` + `CupertinoSwitch` | iOS Settings app aesthetic |
| Dialogs (about, error) | `AlertDialog` | `CupertinoAlertDialog` | iOS convention |
| Home (phone) | `Scaffold` (existing) | `CupertinoPageScaffold` | Mild consistency, low cost |
| Home (iPad ≥ 700 px) | `Scaffold` | Master-detail via `Row` + `Expanded` | Native iPad behavior |
| `MarkdownView`, `WebViewBlock`, `CodeBlock` | unchanged | unchanged | No iOS-specific value |
| `file_picker`, `webview_flutter` | unchanged | unchanged | Already platform-aware |

iPad multi-window is enabled by `Info.plist` (`UIApplicationSceneManifest`,
`UIApplicationSupportsMultipleScenes=true`). Flutter's `WidgetsBinding`
already supports multi-window on iPadOS; we verify with `flutter build ios`
that the build doesn't error on the manifest, but the runtime check
requires a device.

---

## File changes

### New (iOS shell)

```
ios/RunnerShareExt/
  ShareViewController.swift            # Share Extension entry point
  Info.plist                          # Extension manifest
  MainInterface.storyboard            # Minimal UI
  RunnerShareExt.entitlements         # App Group declaration

ios/Runner/
  Runner.entitlements                 # App Group declaration (new)
  AppDelegate.swift                   # MODIFIED: forward open(url:) to plugin
  Info.plist                          # MODIFIED: scene manifest, .ent file
```

### New (Dart)

```
lib/main_ios.dart
lib/app/app.dart
lib/app/app_android.dart
lib/app/app_ios.dart
lib/app/router.dart
lib/platform/file_intent.dart
lib/platform/http_server.dart
lib/platform/settings_repository.dart
lib/platform/file_repository.dart
lib/platform/theme_provider.dart
lib/platform_android/  × 4 impl files
lib/platform_ios/      × 4 impl files
lib/features/reader/   (organized as above)
lib/features/home/
lib/features/settings/
lib/features/editor/.gitkeep
lib/features/export_pdf/.gitkeep
lib/features/export_image/.gitkeep
test/core/...
test/platform_android/...
test/platform_ios/...
test/features/...
test/integration/...
test/contracts/...
```

### Migrated (no semantic change)

| Old | New |
|---|---|
| `lib/utils/markdown_parser.dart` | `lib/core/markdown/parser.dart` |
| `lib/services/settings_service.dart` | interface in `lib/core/storage/settings_repository.dart` + Android + iOS impls |
| `lib/services/file_service.dart` | interface in `lib/core/storage/file_repository.dart` + Android + iOS impls |
| `lib/services/intent_handler.dart` | `lib/platform/file_intent.dart` + Android + iOS impls |
| `lib/widgets/webview_block.dart` | `lib/features/reader/presentation/widgets/webview_block.dart` |
| `lib/widgets/markdown_view.dart` | `lib/features/reader/presentation/widgets/markdown_view.dart` |
| `lib/widgets/code_block.dart` | `lib/features/reader/presentation/widgets/code_block.dart` |
| `lib/screens/home_screen.dart` | `lib/features/home/home_screen.dart` (+ `home_screen_ios.dart`) |
| `lib/screens/preview_screen.dart` | `lib/features/reader/presentation/screens/preview_screen.dart` (+ `_ios.dart`) |
| `lib/screens/settings_screen.dart` | `lib/features/settings/settings_screen.dart` (+ `_ios.dart`) |
| `lib/main.dart` | `lib/app/app.dart` (root widget) + `lib/main.dart` (Android entry) + `lib/main_ios.dart` (iOS entry) |

### Build configuration

```
pubspec.yaml             Add path_provider, app_links (later, only if needed)
android/app/build.gradle.kts   (no change; default main.dart works)
ios/Podfile              (modified to include RunnerShareExt target)
ios/Runner.xcodeproj/project.pbxproj  (manually add Share Extension target)
```

---

## Testing strategy (no iOS device available)

| Test | Tool | What it covers |
|---|---|---|
| Dart unit | `flutter test test/core/` | Markdown parser, segment logic, Result type |
| Dart unit | `flutter test test/platform_android/` | Android platform impl with mocked MethodChannel |
| Dart unit | `flutter test test/platform_ios/` | iOS platform impl with mocked MethodChannel |
| Widget | `flutter test test/features/...` | Screen rendering, theme, layout |
| Integration | `flutter test integration_test/` | MethodChannel mocks verify the file-open end-to-end flow at the Dart level |
| Contract | `flutter test test/contracts/` | Scans Swift `case "methodName"` strings and Dart `invokeMethod("methodName")` strings; asserts they match |
| Static Swift | `grep` + manual review in the PR description | Every Swift file in `ios/` is read, structure documented |
| iOS build | `flutter build ios --release -t lib/main_ios.dart --no-codesign` | Verifies the iOS shell compiles end-to-end |
| Android build | `flutter build apk --debug` | Verifies the Android shell still compiles after the refactor (zero regression) |
| iOS simulator / device | ❌ not run | Out of scope (no Mac available) |

The **Android build must continue to pass** at every step. This is the
acceptance test for "iOS changes don't break Android."

---

## Risk register

| # | Risk | Likelihood | Mitigation |
|---|---|---|---|
| R1 | Migration introduces Android regression despite intent | Medium | Run `flutter test` + `flutter build apk --debug` after every refactor step; never land a refactor commit without both passing |
| R2 | `project.pbxproj` hand-editing breaks Xcode build | High | Keep the change minimal; document the steps; provide a recovery note ("open in Xcode to verify") |
| R3 | iOS Share Extension target conflicts with existing Pods setup | Medium | Match the extension's deployment target to Runner's; reference the receive_sharing_intent README's iOS section |
| R4 | App Group ID `group.com.frank.mdpreview` collides with another app | Low | Use a clearly branded ID; allow override via `Info.plist` |
| R5 | `dart:io HttpServer.bind(127.0.0.1, 0)` behaves differently on iOS than on Android | Low | Same call; iOS uses POSIX loopback identically; if it fails, fall back to a Unix domain socket in a temp dir |
| R6 | `CupertinoApp` theme diverges from existing Material 3 in unexpected ways | Low | Test both themes; only swap individual components, not the whole shell, in v0.2 |
| R7 | v2/v3 placeholder directories cause Flutter "no code" warnings | Low | Each placeholder contains a `.gitkeep` and a `README.md` documenting intent |

---

## Rollout plan (when implementation begins)

This is **deferred** until the user signals they're ready (after their v1 optimization is complete). The planned order is:

1. **Refactor phase** — restructure to new directory layout, no behavior change
   - Step 1: Move `lib/utils/markdown_parser.dart` → `lib/core/markdown/parser.dart`
   - Step 2: Move services, define port interfaces, write Android impls
   - Step 3: Move widgets, screens; verify Android build + tests pass
   - Step 4: Add `lib/main.dart` (Android entry) and `lib/main_ios.dart` (iOS entry stubs)
2. **iOS phase** — wire iOS file opening
   - Step 5: Add `RunnerShareExt` target + `AppDelegate` forward
   - Step 6: Implement `IOSFileIntentReceiver`, verify with mock-based tests
   - Step 7: Cupertino styling for `PreviewScreen` + `SettingsScreen`
   - Step 8: iPad master-detail for `HomeScreen`
   - Step 9: `flutter build ios` verification + Swift static walkthrough
3. **Release**
   - Step 10: Tag v2.0.0, push release, document migration in CHANGELOG
4. **Roadmap**
   - v3: implement `features/editor/`
   - v4: implement `features/export_pdf/` and `features/export_image/`

---

## Open questions for implementation

These do not block this spec, but the implementer will need answers:

- OQ1: Do we need a `webview_flutter` OHOS-equivalent for the iPadOS picture-in-picture or split-view drag handles? (Likely no for v0.2.)
- OQ2: Does the user want app-lock (Face ID / Touch ID) on iOS for opening files? (Out of scope unless requested.)
- OQ3: The `flutter_flavorizr` package could automate the entry-point split; do we use it, or keep the manual `-t` flag? (Recommendation: keep manual, simpler.)
