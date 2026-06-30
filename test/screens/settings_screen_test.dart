import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/screens/settings_screen.dart';
import 'package:md_preview/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SettingsScreen renders theme and font-size controls',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final s = await SettingsService.create();
    await tester.pumpWidget(MaterialApp(
      home: SettingsScreen(settings: s),
    ),);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Font size'), findsOneWidget);
  });
}