# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.2] — 2026-07-06

### Fixed

- **"View all" link tapped → white screen in release mode** — root
  cause: `app.dart` had `onViewAllRecents: () => Navigator.pushNamed(
  context, '/recents')` where `context` was the `AnimatedBuilder`'s
  context, which is **above** the `MaterialApp` and has no `Navigator`
  ancestor. `Navigator.pushNamed` threw a state error on every tap; in
  release mode the exception was swallowed and the screen went blank.

  Fix: route the navigation through `rootNavigatorKey.currentState`,
  the same pattern already used by `_pushPreview` and the static
  `pushLoaded`. The icon's `BuildContext` is the right one; only the
  callback-created-in-build context was wrong.

  Regression covered by `test/app_flow_test.dart`:
  - `Tapping 查看全部 does NOT white-screen` (zh mode)
  - `Full flow: settings → switch to English → back → view all`
    (covers the full zh → en round-trip and English view-all)

## [0.3.1] — 2026-07-06

### Removed

- **Open-source licenses entry** — `Settings → 关于 → 开源许可 / Open source
  licenses` has been removed. It opened Flutter's built-in
  `showLicensePage()` which listed every Dart package's license (10+
  packages, scroll-heavy, long load time that appeared as a blank white
  screen). The list was not useful for a single-user viewer and the
  blank-screen delay is gone.

### Notes

- The 查看全部 (View all) link in v0.3.0 uses a `TextButton` (fixed in
  v0.2.2) — if it still appears unclickable, verify the installed APK
  reports `v0.3.1` in `Settings → 关于 → 版本`. v0.2.0 / v0.2.1 builds
  had the unclickable `GestureDetector` and need a reinstall.

## [0.3.0] — 2026-07-06

### Added

- **Internationalization (i18n)** — the entire UI now supports two languages:
  Simplified Chinese (default) and English.
  - New `AppLocalizations` class (`lib/utils/app_localizations.dart`) with
    hand-rolled per-locale string tables (no codegen, no `.arb` files —
    keeps the project simple for two languages).
  - New `Settings.locale` field persisted in SharedPreferences; live
    switching via `SettingsService.setLocale(Locale)`.
  - New **Settings → Language** section with a popup menu to switch
    between `中文` and `English` without restarting the app.
  - `formatRelativeTime` is now locale-aware (Chinese buckets: 刚刚 /
    X 分钟前 / X 小时前 / 昨天 / X 天前 / X 周前 / YYYY-MM-DD; English
    buckets: just now / X min ago / X h ago / yesterday / X d ago /
    X w ago / YYYY-MM-DD).
- `flutter_localizations` SDK dep added (for default Material/Cupertino
  localization delegates).

### Changed

- HomeScreen, FullRecentListScreen, SettingsScreen, PreviewScreen all
  read strings via `AppLocalizations.of(context).<key>` instead of
  hardcoded literals.
- Missing-file dialog in `app.dart` uses translated strings.
- MaterialApp wired with `localizationsDelegates`, `supportedLocales`,
  and `locale` so widgets (date pickers, etc.) follow the chosen language.

### Tests

- 196 tests passing (up from 113 in v0.2.2)
- `flutter analyze` clean on new code
- `flutter build apk --debug` verified

## [0.2.0] — 2026-07-04

### Added

- **HomeScreen redesigned** — fully Chinese UI. The home page now shows:
  - A large centered icon, title, and "打开 Markdown 文件" button (instead of the English-only placeholder)
  - A "最近文件" section listing the 3 most recently opened Markdown files
  - A "查看全部 →" link to a full list of all recent files (up to 50)
- **Recent files persistence** — every Markdown file you open is recorded
  in `SharedPreferences` (key `recent_files`, JSON list, FIFO at 50). The
  list is sorted by `lastOpenedAt` descending, so the most recent file is
  always at the top.
- **Full recent list screen** — `/recents` route. Shows all 50 entries,
  with a "清空" action that confirms before clearing.
- **Tap to re-open** — tapping a recent file loads it directly, no picker.
  This is the new behavior in v0.2.0; v0.1.0's "tap a card re-opens the
  picker" has been removed.
- **Missing-file handling** — if a recent file no longer exists at its
  recorded path, a dialog offers "移除" (remove from recents) or "取消"
  (keep it).
- **Long-press to delete** — both HomeScreen and FullRecentListScreen
  support long-pressing a card to remove the entry, with a "撤销"
  snackbar action to undo.
- **Relative time formatting** — Chinese buckets: 刚刚 / X 分钟前 /
  X 小时前 / 昨天 / X 天前 / X 周前 / YYYY-MM-DD. `formatRelativeTime` in
  `lib/utils/relative_time.dart`.

### Architecture

- New `RecentFilesRepository` (interface + impl in `lib/services/`).
- New `RecentFile` data class with `==` / `hashCode` and JSON
  serialization.
- New `RecentFileCard` widget (`lib/widgets/`) — extracted from
  `HomeScreen` so both HomeScreen and FullRecentListScreen share it.
- `FileService` extended with `loadFromPath` returning a sealed
  `Ok | Error | Missing` result.

### Tests

- 109 tests passing (up from 49 in v0.1.0)
- `flutter analyze` clean on the new code
- `flutter build apk --debug` verified

## [0.1.0] — 2026-07-03

### Added

- **Markdown rendering**
  - GFM tables (pipe-style), headings, ordered/unordered lists, paragraphs, fenced code blocks
  - Code syntax highlighting via bundled `highlight.js` (~ 200 languages)
  - **Mermaid** diagrams via bundled `mermaid.min.js` (3.3 MB minified) — flowcharts, sequence, class, state, ER, gantt, pie
  - **KaTeX** math rendering:
    - Block math (`$$ ... $$`, ` ```math `, ` ```latex `, ` ```tex `)
    - Inline math (`$...$` within a paragraph)
    - MathML fallback annotation is hidden via CSS so only the rendered HTML is visible
  - Currency heuristic: `$5.99` is **not** treated as math (only `$` not followed by a digit opens math)
- **Local viewer server**
  - App-scoped HTTP server on `127.0.0.1` (ephemeral port) serves a single fully-inlined HTML page (~ 4.6 MB after CSS+font inlining) for **every** code block, avoiding Chromium's 2 MB `data:` URL limit and `file://` cross-origin issues
  - KaTeX CSS is patched in-process: every `url(fonts/*.woff2|woff|ttf)` reference is rewritten to a `data:font/woff2;base64,...` URL with the vendored font bytes, so the app works offline (no font 404 noise)
- **Android integration**
  - Registered `.md` / `.markdown` as document types via `intent-filter` in `AndroidManifest.xml`
  - `IntentHandler` resolves incoming `ACTION_VIEW` intents (both `content://` URIs and `file://` paths) into a `FileService.read()`
- **iOS integration**
  - Registered Markdown UTI (`net.daringfireball.markdown`) and document type in `Info.plist`
  - Opening a `.md` from another app launches md_preview via document interaction
- **Settings**
  - Light / Dark / System theme (default: System)
  - Font size: 10 – 32 pt with live preview, default 14 pt
  - Persisted via `shared_preferences`
- **Self-distribution**
  - Pure-Flutter build, no proprietary SDK; sideloadable APK from CI
  - `minSdk = 23` (Android 6.0+) covers > 99 % of active devices

### Project hygiene

- 49 / 49 tests passing (`flutter test`)
- `flutter analyze` clean (strict `analysis_options.yaml`)
- Vendor libraries checked in under `assets/viewer/` — no runtime CDN dependency