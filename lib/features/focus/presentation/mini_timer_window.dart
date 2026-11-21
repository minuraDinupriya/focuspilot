import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MiniTimerWindow {
  const MiniTimerWindow();

  static const _channel = MethodChannel('focuspilot/mini_timer');

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  Future<void> setEnabled(bool enabled) =>
      _channel.invokeMethod<void>('setEnabled', enabled);
}
