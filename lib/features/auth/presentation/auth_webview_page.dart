import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/app_button_styles.dart';
import 'authorize_webview.dart';

class AuthWebviewPage extends StatelessWidget {
  const AuthWebviewPage({super.key});
  String get _requestToken => Get.arguments as String;
  bool get _supportsEmbeddedWebview =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);
  Future<void> _openExternally() async {
    final url = Uri.parse(ApiConstants.authorizeUrl(_requestToken));
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve on TMDB')),
      body: Column(
        children: [
          Expanded(
            child: _supportsEmbeddedWebview
                ? AuthorizeWebview(
                    url: ApiConstants.authorizeUrl(_requestToken),
                  )
                : _ExternalBrowserPrompt(onOpen: _openExternally),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: AppButtonStyles.outlined(context),
                      onPressed: () => Get.back(result: false),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: AppButtonStyles.filled(context),
                      onPressed: () => Get.back(result: true),
                      child: const Text("I'VE APPROVED"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalBrowserPrompt extends StatelessWidget {
  final VoidCallback onOpen;
  const _ExternalBrowserPrompt({required this.onOpen});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.open_in_new,
              size: 40,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(
              'Approve access in your browser',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'themoviedb.org will open in your default browser. Come back '
              'here and tap "I\'ve approved" once you\'re done.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              style: AppButtonStyles.outlined(context),
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('OPEN BROWSER'),
            ),
          ],
        ),
      ),
    );
  }
}
