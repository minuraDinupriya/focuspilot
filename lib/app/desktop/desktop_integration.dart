import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DesktopIntegration {
  const DesktopIntegration();

  static const _channel = MethodChannel('focuspilot/desktop');

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  Future<void> hideToTray() async {
    if (isSupported) await _channel.invokeMethod<void>('hideToTray');
  }

  Future<void> updateTray({
    required String status,
    required bool isRunning,
    required bool isPaused,
  }) async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('updateTray', {
      'status': status,
      'isRunning': isRunning,
      'isPaused': isPaused,
    });
  }

  Future<void> showIntervalEnded({
    required String title,
    required String body,
  }) async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('showIntervalEnded', {
      'title': title,
      'body': body,
    });
  }

  void setCommandHandler(void Function(String)? handler) {
    if (!isSupported) return;
    _channel.setMethodCallHandler(
      handler == null
          ? null
          : (call) async {
              handler(call.method);
            },
    );
  }
}
