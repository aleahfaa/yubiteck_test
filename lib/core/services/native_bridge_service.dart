import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeDeviceInfo {
  final String platform;
  final String model;
  final String osVersion;
  const NativeDeviceInfo({
    required this.platform,
    required this.model,
    required this.osVersion,
  });
}

class NativeBridgeService {
  static const MethodChannel _channel = MethodChannel(
    'com.yubiteck.test/native_bridge',
  );
  bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  Future<void> triggerHapticFeedback() async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod<void>('triggerHapticFeedback');
    } on PlatformException {
    } on MissingPluginException {}
  }

  Future<NativeDeviceInfo?> getDeviceInfo() async {
    if (!_isSupported) return null;
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'getDeviceInfo',
      );
      if (result == null) return null;
      return NativeDeviceInfo(
        platform: result['platform'] as String? ?? '',
        model: result['model'] as String? ?? '',
        osVersion: result['osVersion'] as String? ?? '',
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
