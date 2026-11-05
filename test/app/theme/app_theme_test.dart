import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/app/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('lightTheme has Material 3 enabled and Light brightness', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.appBarTheme.centerTitle, isFalse);
    });

    test('darkTheme has Material 3 enabled and Dark brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.appBarTheme.centerTitle, isFalse);
    });
  });
}
