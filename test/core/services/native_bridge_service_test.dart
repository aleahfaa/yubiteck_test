import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yubiteck_test/core/services/native_bridge_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.yubiteck.test/native_bridge');
  final service = NativeBridgeService();
  final calls = <MethodCall>[];

  void setHandler(Future<Object?> Function(MethodCall call)? handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  setUp(() {
    calls.clear();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });

  tearDown(() {
    setHandler(null);
    debugDefaultTargetPlatformOverride = null;
  });

  test('triggerHapticFeedback invokes the platform channel', () async {
    setHandler((call) async {
      calls.add(call);
      return null;
    });

    await service.triggerHapticFeedback();

    expect(calls.single.method, 'triggerHapticFeedback');
  });

  test('triggerHapticFeedback swallows a PlatformException', () async {
    setHandler((call) async {
      throw PlatformException(code: 'boom');
    });

    // Should not throw.
    await service.triggerHapticFeedback();
  });

  test('getDeviceInfo parses the native response', () async {
    setHandler(
      (call) async => {
        'platform': 'Android',
        'model': 'Pixel 9',
        'osVersion': '15',
      },
    );

    final info = await service.getDeviceInfo();

    expect(info?.platform, 'Android');
    expect(info?.model, 'Pixel 9');
    expect(info?.osVersion, '15');
  });

  test(
    'getDeviceInfo returns null when no native handler is registered',
    () async {
      setHandler(null);

      final info = await service.getDeviceInfo();

      expect(info, isNull);
    },
  );

  test('no-ops on platforms without a native counterpart', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    setHandler((call) async {
      calls.add(call);
      return null;
    });

    await service.triggerHapticFeedback();
    final info = await service.getDeviceInfo();

    expect(calls, isEmpty);
    expect(info, isNull);
  });
}
