import 'package:flutter/material.dart';
import 'package:md_preview/services/settings_service.dart';
import 'package:md_preview/utils/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settings;
  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsService _s = widget.settings;

  @override
  void initState() {
    super.initState();
    _s.themeModeListenable.addListener(_onChange);
    _s.fontSizeListenable.addListener(_onChange);
    _s.localeListenable.addListener(_onChange);
  }

  @override
  void dispose() {
    _s.themeModeListenable.removeListener(_onChange);
    _s.fontSizeListenable.removeListener(_onChange);
    _s.localeListenable.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    // Defensive: surface any build-time exception in-app rather than
    // leaving the user with a blank white screen. Should never fire,
    // but if something does throw (e.g. corrupt SharedPreferences data)
    // the user sees the error instead of a blank screen.
    try {
      return _buildContent(context);
    } catch (e, st) {
      debugPrint('[SettingsScreen] build error: $e\n$st');
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Settings failed to render.\n\n$e\n\n$st',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      );
    }
  }

  Widget _buildContent(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mode = _s.themeModeListenable.value;
    final size = _s.fontSizeListenable.value;
    final currentLocale = _s.locale;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsAppbarTitle)),
      body: ListView(
        children: [
          // ── Appearance ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              _themeSectionLabel(l),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          ListTile(
            title: Text(_themeSettingLabel(l)),
            subtitle: Text(_themeLabel(mode, l)),
            trailing: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l.settingsThemeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l.settingsThemeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l.settingsThemeDark),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (s) => _s.setThemeMode(s.first),
            ),
          ),
          const Divider(),

          // ── Reading ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l.settingsSectionReading,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          ListTile(
            title: Text(_fontSizeLabel(l)),
            subtitle: Text('${size.toStringAsFixed(0)} pt'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              min: 10,
              max: 32,
              divisions: 22,
              value: size,
              label: size.toStringAsFixed(0),
              onChanged: (v) => _s.setFontSize(v),
            ),
          ),
          const Divider(),

          // ── Language ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              _languageSectionLabel(l),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          ListTile(
            title: Text(_languageSettingLabel(l)),
            trailing: PopupMenuButton<Locale>(
              initialValue: currentLocale,
              onSelected: (locale) => _s.setLocale(locale),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: const Locale('zh'),
                  child: Text(l.settingsLanguageZh),
                ),
                PopupMenuItem(
                  value: const Locale('en'),
                  child: Text(l.settingsLanguageEn),
                ),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentLocale.languageCode == 'zh'
                        ? l.settingsLanguageZh
                        : l.settingsLanguageEn,
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const Divider(),

          // ── About ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              _aboutSectionLabel(l),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          ListTile(
            title: Text(l.settingsAboutVersion),
            subtitle: const Text('v0.3.2'),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode m, AppLocalizations l) => switch (m) {
        ThemeMode.system => l.settingsThemeSystem,
        ThemeMode.light => l.settingsThemeLight,
        ThemeMode.dark => l.settingsThemeDark,
      };

  String _themeSectionLabel(AppLocalizations l) => l.settingsSectionAppearance;
  String _themeSettingLabel(AppLocalizations l) => l.settingsThemeLabel;
  String _fontSizeLabel(AppLocalizations l) => l.settingsFontSizeLabel;
  String _languageSectionLabel(AppLocalizations l) => l.settingsSectionLanguage;
  String _languageSettingLabel(AppLocalizations l) => l.settingsLanguageLabel;
  String _aboutSectionLabel(AppLocalizations l) => l.settingsSectionAbout;
}
