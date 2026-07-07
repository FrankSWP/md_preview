# MD Preview — 项目状态与需求总览

> 最后更新：2026-07-07
> 当前版本：v0.3.5（首个稳定版，Android 真机验证通过）

---

## 1. 项目概述

**目标**：手机版 Markdown 阅读器，关联 `.md` 后缀，支持富文本渲染。
**远期愿景**：手机版 Typora（阅读 → 编辑 → 导出）。
**分发方式**：自用 sideload（不上架商店）。
**仓库**：https://github.com/FrankSWP/md_preview（Public, MIT）

### 核心功能（v0.3.5 已实现）

- GFM 表格 / 标题 / 列表 / 段落 / 代码块
- 代码语法高亮（highlight.js，~200 语言）
- Mermaid 图表（流程图 / 时序图 / 类图 / 状态图 / ER / 甘特 / 饼图）
- KaTeX 数学公式（块级 `$$...$$` + 行内 `$...$`）
- 货币启发式：`$5.99` 不会被误判为公式
- 浅色 / 深色 / 跟随系统主题
- 字号 10-32pt 滑块，实时预览
- 最近文件（首页 3 条 + 完整列表 50 条，长按删除 + 撤销）
- 中英文 i18n 即时切换
- Android `.md` 文件关联（intent-filter）

---

## 2. 版本历程

| 版本 | 日期 | 内容 |
|---|---|---|
| v0.1.0-mvp | 2026-06-29 | 15 任务 subagent 流水线初版 |
| v0.1.0 | 2026-07-03 | 首个公开 release（GitHub Release 已建） |
| v0.2.0 | 2026-07-04 | 首页重设计 + 最近文件 + 全中文 UI |
| v0.2.1 | 2026-07-04 | 修最近文件没写入 bug（统一走 pushLoaded） |
| v0.2.2 | 2026-07-04 | 修"查看全部"点不开（GestureDetector→TextButton） |
| v0.3.0 | 2026-07-06 | i18n 中英文切换 + 语言选择器 |
| v0.3.1 | 2026-07-06 | 删 License Page（白屏元凶之一） |
| v0.3.2 | 2026-07-06 | 修"查看全部"Navigator context bug（rootNavigatorKey） |
| v0.3.3 | 2026-07-07 | Settings 加 try/catch 兜底 |
| v0.3.4 | 2026-07-07 | 修窄屏白屏（SegmentedButton 撑爆 ListTile.trailing，320px 断言失败） |
| **v0.3.5** | **2026-07-07** | **版本号动态读取（package_info_plus），首个稳定版，APK 上传 Release** |

查看所有 tag：`git tag --list`
切换版本：`git checkout v0.3.5 && flutter pub get && flutter run`

---

## 3. 当前状态（v0.3.5）

### 已验证

- 199/199 测试通过
- `flutter analyze` 干净
- Release APK 构建成功（分架构，debug keystore 签名）
- Android 真机全功能验证通过（2026-07-07，含之前白屏过的 3 条路径）
- GitHub Release v0.3.5 已发布，含 3 个 APK 安装包

### Release APK 下载

| 文件 | 适用 | 大小 |
|---|---|---|
| `md-preview-v0.3.5-arm64-v8a.apk` | 现代 Android 手机（2026 年绝大多数） | 19.9 MB |
| `md-preview-v0.3.5-armeabi-v7a.apk` | 老 32 位 ARM 手机 | 17.7 MB |
| `md-preview-v0.3.5-x86_64.apk` | 模拟器 / x86_64 | 21.0 MB |

下载页：https://github.com/FrankSWP/md_preview/releases/tag/v0.3.5

### 已知限制

- **iOS 未适配**：UTI 已注册但 AppDelegate 未接 URL、无 Share Extension、未跑过 `flutter build ios`
- **HarmonyOS 未支持**：Flutter OHOS 未 GA，插件缺适配，已决定跳过
- **签名**：当前用 debug keystore，适合自用 sideload，不适合上架商店
- **v0.3.5 tag 仍含错放文件**：`docs/测试结果.md`（已从 main 删除，但 tag 不动，下个版本自然干净）

---

## 4. 架构与技术决策

### 4.1 渲染策略：混合渲染

- `flutter_markdown` 渲染常规内容（90% 场景，省电流畅）
- WebView 渲染 Mermaid / KaTeX（复杂组件兜底）

### 4.2 WebView 加载方案：本地 HTTP 服务器

- App 内 `127.0.0.1` HTTP 服务器提供内联 HTML（~4.6MB，含 CSS+字体）
- 绕过 Chromium 2MB URL 限制和 `file://` 跨源问题
- KaTeX 字体引用全部改写为 data URL，离线可用

**演进历程**（踩坑记录）：
1. `loadHtmlString` → Android `loadDataWithBaseURL` ~2MB 限制，HTML 被截断
2. `file://` URL → WebView 跨源拒绝，渲染进程崩
3. `data:` URL → Chromium 2MB URL 长度限制
4. **本地 HTTP 服务器**（最终方案）→ URL 短，无大小限制

### 4.3 文件关联

- **Android**：intent-filter 注册 `.md` / `.markdown`，IntentHandler 处理 `content://`（用 `uri_content` 包）和 `file://`
- **iOS**：UTI 注册（`net.daringfireball.markdown`），但未真正打通

### 4.4 数据持久化

- SharedPreferences：设置（主题 / 字号 / 语言）+ 最近文件（JSON list，FIFO 50 条）

### 4.5 国际化

- 手写 `AppLocalizations`（无 codegen / .arb，两语言够简单）
- 40+ 字符串键的双语表
- 相对时间也跟随语言（刚刚 / X 分钟前 vs just now / X min ago）

---

## 5. 待办需求

### 5.1 平台隔离重构（spec 已就绪，状态：deferred）

**spec**：`docs/superpowers/specs/2026-07-03-platform-isolation-design.md`

**核心约束**：
- iOS / Android 代码分开，互不影响构建
- Android 功能零回归（现有行为 100% 保留）
- 为 v2/v3 功能预留扩展位

**结构提案**：
- 双入口：`main.dart`（Android）+ `main_ios.dart`（iOS）
- 分层：`core/`（纯 Dart）+ `platform/`（端口接口）+ `platform_android/` + `platform_ios/` + `features/` + `app/`
- 现有 14 个文件迁移到新结构

**目的**：以后改 iOS 不破 Android，加新功能不碰老代码。

### 5.2 iOS 适配（依赖 5.1 落地）

当前只注册了 UTI，没真正打通。要做：
- `AppDelegate.swift` 接 URL（现在只是 `super`）
- Method Channel 把 URL 传给 Dart
- Share Extension + App Group
- Cupertino 风格 + iPad master-detail
- 跑通 `flutter build ios`（**需 Mac 设备，用户目前没有**）

### 5.3 远期功能（v2/v3，"手机版 Typora"目标）

- **v2**：编辑功能
- **v3**：导出图片、导出 PDF
- 在平台隔离架构落地后才开始
- `features/` 下已预留占位目录

### 5.4 已明确不做

- **HarmonyOS**：Flutter OHOS 未 GA，所有插件缺适配。除非生态变化，否则不做。

### 5.5 待用户确认的 v1 小优化

用户曾提过"针对一个版本还有想要优化的地方"，但未具体说。如有，列出后逐个处理，打 v0.3.6 或 v0.4.0。

---

## 6. 环境与工具链

| 组件 | 版本 / 路径 |
|---|---|
| Flutter SDK | 3.24.3 (stable) @ `D:\Programs\flutter` |
| JDK | OpenJDK 17.0.11 (Temurin) @ `D:\Programs\jdk-17.0.11+9` |
| Android SDK | 34.0.0 @ `D:\Programs\android-sdk` |
| adb | `D:\Programs\android-sdk\platform-tools\adb.exe` |
| minSdk | 23 (Android 6.0+) |
| 包名 | `com.mdpreview.md_preview` |

**构建 Release APK**（需先设 JAVA_HOME）：
```bash
export JAVA_HOME="D:/Programs/jdk-17.0.11+9"
"D:\Programs\flutter\bin\flutter.bat" build apk --release --split-per-abi
```

**真机调试**：
```bash
D:\Programs\android-sdk\platform-tools\adb.exe devices
D:\Programs\android-sdk\platform-tools\adb.exe install -r build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
D:\Programs\android-sdk\platform-tools\adb.exe logcat -s flutter:V Console:V chromium:V
```

---

## 7. 关键文件索引

### 设计与规划
- `docs/superpowers/specs/2026-06-27-md-preview-design.md` — 原始设计文档
- `docs/superpowers/plans/2026-06-27-md-preview.md` — 原始实施计划（15 任务）
- `docs/superpowers/specs/2026-07-03-platform-isolation-design.md` — 平台隔离 spec（deferred）
- `.superpowers/sdd/progress.md` — subagent 进度账本（Task 1-25）

### 测试
- `docs/testing/device-smoke-test.md` — 真机冒烟测试指南
- `test_samples/` — 5 个测试样本（basic / code / mermaid / math / chinese）

### 教训
- `docs/lessons-learned.md` — 窄屏布局测试教训（v0.3.4 白屏根因分析）

### 发布
- `CHANGELOG.md` — 版本变更记录
- `README.md` — 项目说明
- `LICENSE` — MIT

---

## 8. 下一步建议

1. **平台隔离重构** — 后续所有大事（iOS、编辑、导出）的地基，越早做越省事。spec 已就绪。
2. **iOS 适配** — 受限于无 Mac 设备，可能要往后放。
3. **远期功能** — v2 编辑、v3 导出。

---

## 9. 真机验证清单（v0.3.5 已通过）

| # | 测试 | 状态 |
|---|------|------|
| 1 | 启动 < 2s | ✅ |
| 2 | 设置页不白屏（v0.3.4 修复） | ✅ |
| 3 | 主题切换 | ✅ |
| 4 | 字号 10/20/32 实时变化 | ✅ |
| 5 | 切英文后设置不白屏（v0.3.0 修复） | ✅ |
| 6 | 文件关联打开 | ✅ |
| 7 | 基础渲染（标题/列表/表格/引用） | ✅ |
| 8 | 代码高亮 | ✅ |
| 9 | Mermaid 图表 | ✅ |
| 10 | KaTeX 块公式 | ✅ |
| 11 | KaTeX 行内公式 | ✅ |
| 12 | 最近文件显示 | ✅ |
| 13 | 查看全部不白屏（v0.3.2 修复） | ✅ |
| 14 | 长按删除 + 撤销 | ✅ |
| 15 | 持久化（杀 App 重启） | ✅ |
| 16 | 版本号动态显示 v0.3.5+8 | ✅ |
