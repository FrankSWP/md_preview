# Lessons Learned

A running log of mistakes, near-misses, and "we should have caught this earlier"
notes from working on this project. Read this before designing widget tests
or laying out UI for a new feature.

---

## 2026-07-07 — Settings → white screen on real device (v0.3.0–v0.3.3)

**Symptom:** Tapping the Settings gear icon showed a blank white screen on
a real Android device. The widget test suite passed.

**What we got wrong, four times in a row:**

1. **v0.3.1** — assumed the issue was `showLicensePage()` showing a
   heavy package-license list. Removed the license entry. Still white.
2. **v0.3.2** — assumed it was a navigator-context bug in
   `app.dart`. Fixed the View-all callback. Settings still white.
3. **v0.3.3** — added a defensive try/catch in SettingsScreen.build
   to surface any exception. Still white, because the throw was a
   Flutter framework layout assertion, swallowed in release mode.
4. **v0.3.4** — finally read the actual `flutter run` stack trace
   from a real device, which pointed to
   `lib/screens/settings_screen.dart:75:11`: a `ListTile` whose
   `trailing:` was a 3-segment `SegmentedButton` (`跟随系统 / 浅色 / 深色`).

**Root cause:** `ListTile.trailing` has a hard upper width limit
(~320 dp on a narrow phone after the parent's padding). A
3-segment SegmentedButton with localized labels doesn't fit in that
slot. Flutter's `ListTile` throws
`tileWidth != trailingSize?.width || tileWidth == 0.0`. In release
mode the assertion is swallowed, the screen renders blank. **The
test surface was 800 × 600 — three Chinese labels fit easily at that
width, so the test never reproduced the bug.**

**Fix:** Moved the SegmentedButton out of the `ListTile.trailing`
slot and into its own full-width row below the ListTile.

**Lesson — the rule for future mobile projects:**

> **Every layout-touching widget test must run on a narrow phone
> surface — at minimum 360 × 800. The default 800 × 600 surface
> hides layout overflow bugs that hit users on real devices.**

Concretely: for any test that touches `ListTile`, `Row` with
mixed-size children, `IntrinsicWidth`, `Table`, `Wrap`,
`SegmentedButton`, popup menus, `ActionChip` rows, or any widget
that could overflow a fixed-width slot:

```dart
tester.view.physicalSize = const Size(360, 800);
tester.view.devicePixelRatio = 1.0;
addTearDown(tester.view.resetPhysicalSize);
addTearDown(tester.view.resetDevicePixelRatio);
```

Add this to every such test. Skipping it produces a test that passes
while users see a blank screen.

**Related:** When the user reports a "white screen" but the test
passes, do **not** add another defensive try/catch. Run `flutter run`
on the real device, capture the **full** `══╡ EXCEPTION CAUGHT BY
RENDERING LIBRARY ╞══` block (red, with stack), and read the
`ListTile:.../path/to/file.dart:LINE:COL` reference. Layout assertions
look like "white screen" from the outside but are always a
"FlutterError" with a specific widget and line number in the logs.

**Diagnostic path that finally worked:**

1. User captured `flutter run` output to a file.
2. We searched the file for `EXCEPTION` and `ListTile`.
3. Got the line: `lib/screens/settings_screen.dart:75:11`.
4. Read the surrounding code and saw the SegmentedButton in
   `trailing:`.
5. Realised the test surface was 800 px and never reproduced the
   360 dp reality.

**Why this is in the repo:** conversations expire; this file
doesn't. If you read this and think "I'm smarter than that, my
test surface is fine" — run a narrow-phone test once before you
ship. It costs 30 seconds and saves a 4-day debug cycle.
