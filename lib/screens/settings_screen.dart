import 'package:flutter/material.dart';
import 'package:md_preview/services/settings_service.dart';

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
  }

  @override
  void dispose() {
    _s.themeModeListenable.removeListener(_onChange);
    _s.fontSizeListenable.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  String _label(ThemeMode m) => switch (m) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  @override
  Widget build(BuildContext context) {
    final mode = _s.themeModeListenable.value;
    final size = _s.fontSizeListenable.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_label(mode)),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {mode},
              onSelectionChanged: (s) => _s.setThemeMode(s.first),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Font size'),
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
        ],
      ),
    );
  }
}