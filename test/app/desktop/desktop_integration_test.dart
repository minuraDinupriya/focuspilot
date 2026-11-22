import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/app/desktop/desktop_integration.dart';

void main() {
  const integration = DesktopIntegration();
  const channel = MethodChannel('focuspilot/desktop');

  testWidgets(
    'Windows tray commands reach Flutter until the handler is removed',
    (tester) async {
      final messenger = tester.binding.defaultBinaryMessenger;
      final commands = <String>[];
      integration.setCommandHandler(commands.add);
      addTearDown(() => integration.setCommandHandler(null));
      const codec = StandardMethodCodec();

      await messenger.handlePlatformMessage(
        channel.name,
        codec.encodeMethodCall(const MethodCall('togglePause')),
        null,
      );
      await messenger.handlePlatformMessage(
        channel.name,
        codec.encodeMethodCall(const MethodCall('shown')),
        null,
      );
      integration.setCommandHandler(null);
      await messenger.handlePlatformMessage(
        channel.name,
        codec.encodeMethodCall(const MethodCall('togglePause')),
        null,
      );

      expect(commands, ['togglePause', 'shown']);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets('mobile never contacts the Windows desktop channel', (
    tester,
  ) async {
    final messenger = tester.binding.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });

    expect(integration.isSupported, isFalse);
    await integration.hideToTray();
    await integration.updateTray(
      status: 'Focus paused',
      isRunning: false,
      isPaused: true,
    );
    await integration.showIntervalEnded(
      title: 'Focus target reached',
      body: 'The timer is now in Flow Time.',
    );

    expect(calls, isEmpty);
  }, variant: TargetPlatformVariant.mobile());
}
