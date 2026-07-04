# MD Preview — Subagent-Driven Development Progress

> Ledger for the 15-task implementation plan in `docs/superpowers/plans/2026-06-27-md-preview.md`.
> Maintained by the controller (Claude). Each task entry records the commits
> produced and the review verdict.

## Status legend

- ⏳ pending
- 🚧 implementing
- 👀 reviewing
- ✅ done (clean review)
- ⚠️ done with minor findings (recorded in code-reviewer final pass)

## Tasks

| # | Title | Status | Commits | Review |
|---|-------|--------|---------|--------|
| 1 | Scaffold Flutter project | ✅ | 2dd7e54..9a99e4c | approved (after minSdk=23 fix) |
| 2 | Add dependencies + lint | ✅ | 9a99e4c..6e945c4 | approved (after package name fix: `uri_content` not `flutter_content_uri`; `chardet` removed) |
| 3 | SettingsService (TDD) | ✅ | 6254d4b..877bf72 | approved |
| 4 | App theme | ✅ | 877bf72..fea5a9c | approved |
| 5 | Markdown parser (TDD) | ✅ | fea5a9c..5a89543 | approved |
| 6 | FileService (TDD) | ✅ | 5a89543..9ece454 | approved |
| 7 | HomeScreen | ✅ | 9ece454..30801c8 | approved |
| 8 | CodeBlock + MarkdownView | ✅ | 30801c8..0a8e745 | approved (with test-assertion fix) |
| 9 | PreviewScreen | ✅ | 0a8e745..89ddaf8 | approved |
| 10 | SettingsScreen | ✅ | 89ddaf8..b5508a6 | approved |
| 11 | Android file association + IntentHandler | ✅ | b5508a6..5a3b224 | approved |
| 12 | iOS file association | ✅ | 5a3b224..525a6d9 | approved (Mac validation pending) |
| 13 | Real WebViewBlock + viewer.html | ✅ | 525a6d9..3beb0fd | approved (with loadHtmlString adaptation) |
| 14 | App entry, routing, main wiring | ✅ | 3beb0fd..57602f4 | approved (with const-lint info) |
| 15 | Build verification | ✅ | 57602f4..21c7233 | approved (APK built; device install pending user) |

## Math-rendering improvements (2026-07-02)

Baseline: `5d870365fbe273dd76fc5d5bc32e58ddbe2681c0`

| # | Title | Status | Brief |
|---|-------|--------|-------|
| 16 | Inline KaTeX CSS + Fonts | ✅ | `0a84032..ecbbb0d` | approved (after fix: also patch woff/ttf refs) |
| 17 | Inline `$...$` math support | ✅ | `56780af..39bfbaa` | approved (with minor notes) |

## v0.2.0 — Recent files (2026-07-04)

Repository: https://github.com/FrankSWP/md_preview

- Tag: v0.2.0 (annotated)
- Branch: `feat/recent-files` merged into main
- Tasks 18-21: RecentFilesRepository + HomeScreen redesign +
  FullRecentListScreen + app.dart wiring
- 109/109 tests passing, lint clean on new code, APK builds
- v0.1.0 still reachable via `git checkout v0.1.0`

### Commits

- 025d4a3 feat: RecentFilesRepository + formatRelativeTime helper
- 51359d5 fix(recent): round week boundary + drop placeholder test
- b9c4aa5 feat(home): Chinese UI + recent files section
- baab48d fix(home): layout overflow + lint issues
- eb1ec7d fix Task 19: center-when-fits layout + test 11 expectations
- 759595c Task 20: FullRecentListScreen + extracted RecentFileCard widget
- 5923ba9 Task 21: app.dart wiring + tap-to-open + missing-file dialog
- 0157bb4 fix(tests): add trailing commas to home_screen_test.dart
- (Task 22 commits)

## GitHub release (2026-07-03)

Repository: **https://github.com/FrankSWP/md_preview**

- Pushed: `main` (fast-forwarded to `c60dfb8`) and `feat/md-preview`
- Tag: `v0.1.0` (annotated)
- Release: https://github.com/FrankSWP/md_preview/releases/tag/v0.1.0
- License: MIT (`LICENSE`)
- Repo cleanup commit: `c60dfb8 chore: clean repo for v0.1.0 release`
  - New `LICENSE`, real `README.md`, expanded `CHANGELOG.md`
  - Removed `test_bugs/` and the device-screenshot from tracking; both in `.gitignore`

## Platform-isolation spec (2026-07-03, deferred)

Brainstorming session agreed on an iOS adaptation + platform-isolation refactor. Spec at `docs/superpowers/specs/2026-07-03-platform-isolation-design.md` (commit `440b2ff`).

Key decisions:

- iOS and Android code split via **two entry points** (`lib/main.dart` Android, `lib/main_ios.dart` iOS) — iOS files unreachable from the Android compiler.
- Layered structure: `core / platform / platform_android / platform_ios / features / app`.
- iOS scope: end-to-end file open (Share Extension + App Group), Cupertino styling, iPad master-detail.
- **HarmonyOS / OpenHarmony explicitly out of scope** — Flutter OHOS is not GA, all our plugins lack OHOS implementations.
- **v2 (editor) + v3 (export PDF, export image)** reserved as `features/<name>/.gitkeep` placeholders.
- Android build must continue to pass at every refactor step (zero-regression acceptance test).

**Status:** deferred — the user is doing a v1 optimization first. Implementation begins when the user signals they're ready.

## Version tags for rollback

| Tag | Commit | Use |
|---|---|---|
| `v0.1.0` | `c60dfb8` (post-cleanup) | First public release. Read-only archive. |
| `v0.1.0-mvp` | `21c7233` | Pre-cleanup MVP release notes. |
| `main` HEAD | `440b2ff` | Currently equals `v0.1.0` + spec doc. |

To check out a specific version:

```bash
git fetch --all --tags
git checkout v0.1.0    # ← the "first version" before any refactor
flutter pub get
flutter run
```

After the optimization is tagged, `v0.1.1` (or whatever) will be added. After the platform-isolation refactor lands, `v2.0.0` will be added.

## Environment

- Branch: `feat/md-preview` (off `main` @ `2dd7e54`)
- Flutter: 3.24.3 (stable) at `D:\Programs\flutter`
- JDK: OpenJDK 17.0.11 (Temurin) at `D:\Programs\jdk-17.0.11+9`
- Android SDK: 34.0.0 at `D:\Programs\android-sdk`
- Devices: Android phone via USB (deferred until Task 15)
