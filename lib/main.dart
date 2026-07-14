import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebaseIfSupported();
  runApp(const App());
}

Future<void> _initFirebaseIfSupported() async {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) return;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    if (kDebugMode) {
      debugPrint(
        'Firebase init skipped (expected until `flutterfire configure` is run): $error',
      );
    }
  }
}
