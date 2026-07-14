import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Bonus native module: a small platform channel exposing haptic
    // feedback and basic device info to the Dart side (see
    // lib/core/services/native/native_bridge_service.dart).
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NativeBridgeChannel")
    let channel = FlutterMethodChannel(
      name: "com.yubiteck.test/native_bridge",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "triggerHapticFeedback":
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        result(nil)
      case "getDeviceInfo":
        let device = UIDevice.current
        result([
          "platform": "iOS",
          "model": device.model,
          "osVersion": device.systemVersion,
        ])
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
