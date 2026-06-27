# MD Preview 移动端工具 — 设计文档

- **日期**：2026-06-27
- **作者**：与 Claude 协作完成
- **状态**：待实施

## 1. 背景与目标

### 1.1 问题
在手机上查看 Markdown（.md）文件很麻烦：没有默认打开的应用，系统自带的「文本查看器」对格式化、代码块、表格、公式等支持极差，几乎只能看到纯文本源码。

### 1.2 目标
构建一个**跨平台移动应用**（Android + iOS），实现：
1. **系统级文件关联**：注册为 `.md` 文件的默认/可选打开应用
2. **高质量 Markdown 渲染**：包括 GFM 表格、代码语法高亮、Mermaid 流程图、数学公式
3. **舒适的阅读体验**：深浅主题切换、字号调节

### 1.3 非目标（本期不做）
- ❌ 本地编辑/保存（后续迭代）
- ❌ 多文件管理、文件夹浏览（后续迭代）
- ❌ 云存储同步（GitHub/WebDAV/坚果云等）
- ❌ 账号系统
- ❌ 上架 App Store / Google Play（当前仅自用 sideload）

## 2. 平台与技术栈

| 维度 | 选型 | 理由 |
|------|------|------|
| 平台 | Android + iOS | 跨平台覆盖 |
| 技术栈 | **Flutter (Dart)** | 生态成熟、单代码库、社区活跃 |
| 分发 | 自用 sideload | `flutter build apk` 手动安装，不走商店审核 |
| 最低系统 | Android 6.0+ / iOS 12+ | Flutter 默认支持 |

## 3. 渲染策略 — 混合渲染

### 3.1 三种方案对比

| 方案 | 描述 | 优势 | 劣势 |
|------|------|------|------|
| A. 纯 Flutter Widget | `flutter_markdown` 渲染 | 原生体验、内存低 | 代码高亮/Mermaid/公式需自实现 |
| B. 纯 WebView | HTML + marked.js + highlight.js + mermaid + KaTeX | JS 生态全开 | 滚动/选中体验差、内存大 |
| **C. 混合渲染** ✅ | `flutter_markdown` 渲染常规内容；Mermaid/公式/复杂代码块走 WebView | 体验与成本平衡 | 渲染路径两套 |

**采用方案 C**。

### 3.2 混合路由规则

```dart
MarkdownView(source, theme, fontSize):
  parsed = parseMarkdown(source)
  for each block in parsed:
    if block is CodeBlock and isComplex(block.language):
      render WebViewBlock(language, code)
    else:
      render flutter_markdown's widget for block
```

`isComplex(language)` 判断：
- `mermaid` → true
- `math` / `latex` / `tex` → true
- `*`（未知语言）但包含 `$$...$$` 或行内 `$...$` → true
- 其它 → false

## 4. 架构

### 4.1 分层

```
┌──────────────────────────────────────────────────┐
│                  App 入口层                       │
│  main.dart 接收 Android Intent / iOS Open-in     │
│  → 解析文件 URI → 路由到 PreviewScreen            │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────┐
│               UI 层 (Flutter Widgets)             │
│  • HomeScreen: 空状态/最近文件                    │
│  • PreviewScreen: 顶部工具栏 + MD 内容区          │
│  • SettingsScreen: 主题/字号/默认值               │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────┐
│             渲染层 (混合策略)                     │
│  • MarkdownView (Widget) → flutter_markdown      │
│  • 遇到 Mermaid/公式/复杂代码 → WebViewBlock     │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────┐
│            服务层                                │
│  • FileService: 读文件、读 Intent                 │
│  • SettingsService: 主题/字号持久化               │
│  • AssetService: 加载 HTML/CSS/JS 模板           │
└──────────────────────────────────────────────────┘
```

### 4.2 模块边界
- **UI 层** 不知道文件怎么来
- **渲染层** 不知道 UI 怎么布局
- **服务层** 通过接口注入，方便单测

## 5. 关键模块设计

### 5.1 文件接收与打开

#### Android
`AndroidManifest.xml` 注册 intent-filter：

```xml
<intent-filter android:label="@string/app_name">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="file" />
  <data android:scheme="content" />
  <data android:mimeType="text/markdown" />
  <data android:mimeType="text/x-markdown" />
  <data android:mimeType="text/plain" />
  <data android:pathPattern=".*\\.md" />
  <data android:pathPattern=".*\\.markdown" />
</intent-filter>
```

通过 `receive_sharing_intent` 插件获取分享的 URI，再用 `ContentResolver` 读取。

#### iOS
`Info.plist` 配置：
- `CFBundleDocumentTypes`：声明支持 `text/markdown`
- `UTExportedTypeDeclarations`：导出 UTI `public.markdown`

`AppDelegate.swift` 在 `application(_:open:options:)` 中处理。

#### 应用内手动打开
用 `file_picker` 插件提供"打开文件"按钮作为兜底，覆盖以下场景：
- 用户没注册为默认
- 测试时方便
- 从历史/收藏打开

### 5.2 渲染层 — `MarkdownView` Widget

```dart
class MarkdownView extends StatelessWidget {
  final String source;
  final AppTheme theme;
  final double fontSize;
  
  Widget build(BuildContext context) {
    final blocks = parseMarkdown(source);
    return ListView.builder(
      itemCount: blocks.length,
      itemBuilder: (_, i) {
        final b = blocks[i];
        if (b is CodeBlock && isComplex(b.language)) {
          return WebViewBlock(
            language: b.language,
            code: b.code,
            theme: theme,
          );
        }
        return _renderBlock(b, theme, fontSize);
      },
    );
  }
}
```

`WebViewBlock` 通过 `WebViewController` 加载 `assets/viewer/viewer.html`，传入语言类型和源码。viewer.html 内预置 marked + highlight.js + mermaid + KaTeX。

### 5.3 设置持久化

`shared_preferences` 存：
- `theme_mode`: `light` / `dark` / `system`（默认 `system`）
- `font_size`: `double`（默认 16.0）
- `code_font_family`: `string`（默认 `monospace`）

设置变更通过 `ValueNotifier` 通知 UI 实时刷新。

### 5.4 错误处理

| 场景 | 行为 |
|------|------|
| 文件不存在 / 权限拒绝 | Snackbar 提示 + 回到首页 |
| 文件 > 5MB | Dialog 警告，用户可选择继续 |
| 文件非 UTF-8 | 用 `chardet` 探测编码，提示用户 |
| Mermaid/公式语法错误 | WebView 内显示错误（不阻塞其他内容） |
| WebView 加载失败 | 显示降级视图（纯文本 + 提示） |

### 5.5 性能预算
- 冷启动 < 2s（中型手机）
- 1MB MD 渲染 < 500ms
- 内存峰值 < 100MB

## 6. 项目结构

```
md_preview/
├── android/                          # Android 工程
│   └── app/src/main/AndroidManifest.xml
├── ios/                              # iOS 工程
│   └── Runner/Info.plist
├── lib/
│   ├── main.dart                     # 入口，处理 Intent
│   ├── app.dart                      # MaterialApp + 路由
│   ├── theme/
│   │   └── app_theme.dart            # 浅/深主题
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── preview_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── markdown_view.dart
│   │   ├── webview_block.dart
│   │   └── code_block.dart
│   ├── services/
│   │   ├── file_service.dart
│   │   ├── settings_service.dart
│   │   └── intent_handler.dart
│   └── utils/
│       └── markdown_parser.dart
├── assets/
│   └── viewer/
│       ├── viewer.html
│       ├── viewer.css
│       ├── marked.min.js
│       ├── highlight.min.js
│       ├── mermaid.min.js
│       └── katex.min.js
├── test/
│   ├── services/
│   ├── widgets/
│   └── integration/
├── pubspec.yaml
└── docs/
    └── superpowers/specs/
        └── 2026-06-27-md-preview-design.md
```

## 7. 关键依赖（pubspec.yaml）

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_markdown: ^0.7.x        # MD 渲染
  webview_flutter: ^4.x            # WebView
  file_picker: ^8.x                # 应用内打开文件
  receive_sharing_intent: ^1.x     # Android Intent 接收
  shared_preferences: ^2.x         # 设置持久化
  chardet: ^0.4.x                  # 编码探测
  path_provider: ^2.x              # 路径

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.x
```

## 8. 测试策略

| 类型 | 范围 | 工具 |
|------|------|------|
| 单元测试 | `FileService`、`SettingsService`、`isComplexLang()`、`markdown_parser.dart` | `flutter_test` |
| Widget 测试 | `MarkdownView` 渲染样例 MD、主题切换、字号变化 | `flutter_test` |
| 集成测试 | 模拟 Intent 投递 → 跳转到 PreviewScreen → 正确渲染 | `integration_test` |
| 手工测试 | 真机跑：纯文本、含 Mermaid、含公式、含长文、含表格、含中文 | 真机 |

测试覆盖目标：核心逻辑 ≥ 80%。

## 9. 实施阶段（粗略）

| 阶段 | 内容 | 验收 |
|------|------|------|
| Phase 1 | 工程脚手架 + Android/iOS intent 注册 + 应用内打开文件 + `flutter_markdown` 基础渲染 | 能打开一个 .md 看到格式化 |
| Phase 2 | 主题切换 + 字号调节 + 设置持久化 | 切深色/调字号重启后保留 |
| Phase 3 | 代码高亮（普通语言） | 代码块有颜色 |
| Phase 4 | Mermaid/数学公式 WebView 集成 | 流程图和公式正确显示 |
| Phase 5 | 错误处理 + 性能优化 + 打包出 APK | 真机流畅运行 |

## 10. 风险与缓解

| 风险 | 影响 | 缓解 |
|------|------|------|
| iOS 真机调试需 Mac | 开发体验 | 先在 Android 跑通，iOS 部分用 `flutter analyze` + 模拟代码评审 |
| WebView 内 mermaid 渲染慢 | 大文档卡顿 | 复杂内容走 WebView 时显示加载占位 |
| iOS App Store 审核（即使本期不上） | 未来上架风险 | 保持代码中性，不引入私有 API |
| 第三方 JS 库体积 | APK 增大 | mermaid/KaTeX 按需懒加载 |
| Android Intent MIME 兼容（部分文件管理器发送 `*/*`） | 关联失败 | 同时声明 `text/markdown`、`text/plain`、扩展名匹配三道 |

## 11. 开放问题

- [ ] 是否需要"TOC 目录"侧边栏？（大文档友好）
- [ ] 是否需要"搜索文档内文字"？
- [ ] 是否需要"字号记忆 per-file"（不同文件用不同字号）？

这些是 nice-to-have，可在 Phase 2 后视情况加入。

## 12. 后续迭代方向（不在本期）

- 本地编辑（基础 textarea / CodeMirror 嵌入）
- 多文件管理（最近文件、文件夹浏览）
- 云同步（GitHub API、WebDAV、坚果云）
- 收藏夹 / 标签
- 导出 PDF / 图片
- 主题自定义（颜色、字体）
