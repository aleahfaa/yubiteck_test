package com.example.yubiteck_test

import android.os.Build
import android.view.HapticFeedbackConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Bonus native module: a small platform channel exposing haptic feedback
 * and basic device info to the Dart side (see
 * lib/core/services/native/native_bridge_service.dart).
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.yubiteck.test/native_bridge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "triggerHapticFeedback" -> {
                        window.decorView.performHapticFeedback(
                            HapticFeedbackConstants.VIRTUAL_KEY
                        )
                        result.success(null)
                    }
                    "getDeviceInfo" -> {
                        result.success(
                            mapOf(
                                "platform" to "Android",
                                "model" to Build.MODEL,
                                "osVersion" to Build.VERSION.RELEASE
                            )
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
