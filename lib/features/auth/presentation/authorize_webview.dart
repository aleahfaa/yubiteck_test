import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/widgets/app_loading_view.dart';

class AuthorizeWebview extends StatefulWidget {
  final String url;
  const AuthorizeWebview({super.key, required this.url});
  @override
  State<AuthorizeWebview> createState() => _AuthorizeWebviewState();
}

class _AuthorizeWebviewState extends State<AuthorizeWebview> {
  late final WebViewController _controller;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading) const AppLoadingView(),
      ],
    );
  }
}
