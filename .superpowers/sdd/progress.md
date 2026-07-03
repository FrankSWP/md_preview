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

## GitHub release (2026-07-03)

Repository: **https://github.com/FrankSWP/md_preview**

- Pushed: `main` (fast-forwarded to `c60dfb8`) and `feat/md-preview`
- Tag: `v0.1.0` (annotated)
- Release: https://github.com/FrankSWP/md_preview/releases/tag/v0.1.0
- License: MIT (`LICENSE`)
- Repo cleanup commit: `c60dfb8 chore: clean repo for v0.1.0 release`
  - New `LICENSE`, real `README.md`, expanded `CHANGELOG.md`
  - Removed `test_bugs/` and the device-screenshot from tracking; both in `.gitignore`

## Environment

- Branch: `feat/md-preview` (off `main` @ `2dd7e54`)
- Flutter: 3.24.3 (stable) at `D:\Programs\flutter`
- JDK: OpenJDK 17.0.11 (Temurin) at `D:\Programs\jdk-17.0.11+9`
- Android SDK: 34.0.0 at `D:\Programs\android-sdk`
- Devices: Android phone via USB (deferred until Task 15)
