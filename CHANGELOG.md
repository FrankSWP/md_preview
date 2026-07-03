# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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