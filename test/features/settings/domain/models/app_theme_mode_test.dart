import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/settings/domain/models/app_theme_mode.dart';

void main() {
  group('AppThemeMode Enum Tests', () {
    test('displayName returns user-friendly label', () {
      expect(AppThemeMode.system.displayName, 'System');
      expect(AppThemeMode.light.displayName, 'Light');
      expect(AppThemeMode.dark.displayName, 'Dark');
    });

    test('icon returns relevant Material icon', () {
      expect(AppThemeMode.system.icon, Icons.brightness_auto_rounded);
      expect(AppThemeMode.light.icon, Icons.light_mode_rounded);
      expect(AppThemeMode.dark.icon, Icons.dark_mode_rounded);
    });

    test('toFlutterThemeMode maps correctly to Flutter ThemeMode', () {
      expect(AppThemeMode.system.toFlutterThemeMode(), ThemeMode.system);
      expect(AppThemeMode.light.toFlutterThemeMode(), ThemeMode.light);
      expect(AppThemeMode.dark.toFlutterThemeMode(), ThemeMode.dark);
    });

    test('fromString parses valid and fallback values', () {
      expect(AppThemeMode.fromString('system'), AppThemeMode.system);
      expect(AppThemeMode.fromString('light'), AppThemeMode.light);
      expect(AppThemeMode.fromString('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromString(null), AppThemeMode.system);
      expect(AppThemeMode.fromString('unknown_value'), AppThemeMode.system);
    });
  });
}
