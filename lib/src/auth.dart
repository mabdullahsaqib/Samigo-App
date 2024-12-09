import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OAuthWebView extends StatefulWidget {
  final String authUrl;
  final String redirectUri;

  const OAuthWebView({
    super.key,
    required this.authUrl,
    required this.redirectUri,
  });

  @override
  State<OAuthWebView> createState() => _OAuthWebViewState();
}

class _OAuthWebViewState extends State<OAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  final String useragent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.6876.3 Safari/537.36";

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(useragent) // Set the user agent here
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('Page loading progress: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(widget.redirectUri)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  void _handleRedirect(String url) {
    try {
      final Uri uri = Uri.parse(url);
      final String? code = uri.queryParameters['code'];

      if (code != null) {
        Navigator.pop(context,
            code); // Return the authorization code to the calling screen
      } else {
        Navigator.pop(context,
            null); // Handle cases where the user denies access or no code is present
      }
    } catch (e) {
      debugPrint('Error handling redirect: $e');
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google OAuth'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
