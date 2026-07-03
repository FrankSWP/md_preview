# md_preview

> A mobile-first Markdown viewer for Android & iOS — handles GFM tables,
> code highlighting, Mermaid diagrams, and KaTeX math (block **and**
> inline), all rendered locally with zero network dependency.

md_preview is a small Flutter app that lets you open any `.md` /
`.markdown` file on your phone and read it the way it should look on
GitHub — including diagrams and formulas. It registers itself as a
handler for `.md` files, so opening one from your file manager, email,
or chat app launches md_preview directly.

---

## ✨ Features

| | |
|---|---|
| 📋 **GFM tables** | Pipe-style tables render with header divider rows |
| 🎨 **Code highlighting** | 200+ languages via bundled `highlight.js` |
| 🧩 **Mermaid diagrams** | Flowcharts, sequence, class, state, ER, gantt, pie |
| 🧮 **KaTeX math** | Block (`$$ ... $$`) **and** inline (`$...$`) formulas |
| 🌗 **Light / Dark** | Material 3 themes, follow system by default |
| 🔠 **Adjustable font size** | 10 – 32 pt, live preview, persisted |
| 📂 **File association** | Tap any `.md` file in your file manager to open it |
| 🔌 **100 % offline** | All libraries (marked, highlight, mermaid, KaTeX + fonts) vendored in `assets/viewer/` |

---

## 📸 Screenshots

Device-tested on Android. Math rendering uses real KaTeX fonts
(typeset math symbols, not Unicode fallbacks):

![Inline + block KaTeX math rendered on Android](docs/images/math-rendering.png)

Sample documents are in `test_samples/` — copy any one to your phone
and open it to see all features in action:

| File | Shows off |
|---|---|
| `sample_basic.md` | Headings, lists, links, emphasis |
| `sample_chinese.md` | CJK text, mixed paragraphs |
| `sample_code.md` | Code blocks in several languages |
| `sample_math.md` | Block + inline KaTeX math |
| `sample_mermaid.md` | Flowchart, sequence, class diagrams |

---

## 🏗 Architecture

```
Markdown source
   │
   ▼  (line-based parser — no flutter_markdown AST)
List<ParsedBlock>  (Heading, Paragraph, Code, List, Table, Other)
   │
   ├── paragraph / list / heading / table  →  flutter_markdown
   ├── code (plain)                        →  flutter_highlight widget
   └── code (mermaid | math)               →  WebViewBlock
                                                 │
                                                 ▼
                                  ViewerServer (127.0.0.1:<port>)
                                                 │
                                  Serves fully-inlined viewer.html
                                  (marked + highlight + mermaid + katex
                                   + CSS patched with data:font URLs)
                                                 │
                                                 ▼
                                  WebView loads URL with
                                  #lang=...&code=...&displayMode=...
                                  fragment, JS parses and renders
```

**Why a local HTTP server?** Chromium WebView refuses to navigate to any
URL longer than ~2 MB, and `loadHtmlString` uses the same internal
`data:` URL mechanism. The bundled viewer (mermaid is 3.3 MB alone,
plus KaTeX + CSS + 16 fonts) is ~4.6 MB, so it cannot be passed via
`loadHtmlString` / `data:` URL. `file://` loading crashes the renderer
on Android. Serving the HTML over a short `http://127.0.0.1:port/...`
URL sidesteps every length limit, requires no extra permissions beyond
`usesCleartextTraffic="true"` (loopback-only and allowed by the
platform), and keeps the URL fragment small enough for the math code
to round-trip cleanly.

---

## 🧪 Tests

```bash
flutter test
# 49 / 49 passing
```

Coverage:

- `markdown_parser` — block / inline classification, currency heuristic,
  segment merging, math boundary detection
- `webview_block` — HTML bundling, CSS inlining, font patching
- `settings`, `file_service` — round-trips

---

## 🔨 Building

```bash
# 1. Install Flutter 3.24+ and the Android SDK / Xcode
flutter --version

# 2. Fetch packages
flutter pub get

# 3. Run on a connected device
flutter run                       # uses default device
flutter run -d <device-id>

# 4. Build a release APK
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

iOS works the same way (`flutter build ios --release`); this repo was
developed primarily on Android.

### Android requirements

- `minSdk = 23` (Android 6.0+)
- `targetSdk = 34`
- `compileSdk = 34`
- JDK 17

---

## 📁 Project layout

```
md_preview/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── screens/                (HomeScreen, PreviewScreen, SettingsScreen)
│   ├── services/               (FileService, SettingsService, IntentHandler)
│   ├── utils/                  (markdown_parser.dart — the line-based splitter)
│   └── widgets/
│       ├── markdown_view.dart  (block router)
│       ├── code_block.dart     (flutter_highlight wrapper)
│       └── webview_block.dart  (ViewerServer + WebView wrapper)
├── assets/viewer/
│   ├── viewer.html             (marked + mermaid + katex harness)
│   ├── marked.min.js
│   ├── highlight.min.js
│   ├── mermaid.min.js
│   ├── katex.min.js
│   ├── katex.min.css           (fonts patched at bundle time)
│   └── fonts/                  (16 vendored KaTeX woff2 fonts)
├── test_samples/               (try-on samples — copy to device)
├── docs/superpowers/           (design spec + implementation plan + ledger)
└── android/, ios/              (platform shells)
```

---

## 📦 Vendored libraries

| Library | Version | Why vendored |
|---|---|---|
| [`marked`](https://marked.js.org/) | bundled | Markdown → HTML in the WebView |
| [`highlight.js`](https://highlightjs.org/) | bundled | Code syntax highlighting |
| [`mermaid`](https://mermaid.js.org/) | 10+ | Diagram rendering |
| [`KaTeX`](https://katex.org/) | bundled | Math rendering |

Vendoring keeps the app fully offline and removes any CDN dependency.

---

## 🤝 Contributing

This is a single-purpose viewer, not a Markdown editor. PRs welcome for:

- Additional Markdown extensions already supported by GitHub (task lists,
  footnotes, definition lists)
- Theming options (sepia / solarized / pure black)
- Performance: reduce viewer HTML size (currently 4.6 MB) by lazy-loading
  the mermaid bundle only when needed

Bug reports: please include the device model, Android/iOS version, and a
small `.md` file that reproduces the issue.

---

## 📜 License

[MIT](LICENSE) © 2026 md_preview contributors