// lib/components/web_view_screen_vnpay.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreenVNPAY extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreenVNPAY({super.key, required this.url, required this.title});

  @override
  WebViewScreenVNPAYState createState() => WebViewScreenVNPAYState();
}

class WebViewScreenVNPAYState extends State<WebViewScreenVNPAY> {
  late final WebViewController _controller;
  // This is the URL your Flask backend redirects to.
  // Make sure it matches the VNPAY_RETURN_URL in your config.
  final String returnUrl = 'http://192.168.1.4:5000/payment_return';

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                // Check if the WebView is navigating to our return URL.
                if (request.url.startsWith(returnUrl)) {
                  // Parse the URL to get the query parameters.
                  final Uri uri = Uri.parse(request.url);
                  final String? responseCode =
                      uri.queryParameters['vnp_ResponseCode'];

                  // VNPAY success code is '00'.
                  if (responseCode == '00') {
                    // If successful, pop the screen and return 'success'.
                    Navigator.of(context).pop('success');
                  } else {
                    // If it failed for any reason, pop and return 'failed'.
                    Navigator.of(context).pop('failed');
                  }

                  // Prevent the WebView from actually navigating to the return page.
                  return NavigationDecision.prevent;
                }
                // Allow all other navigation requests.
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      // The WillPopScope handles the user pressing the physical or virtual back button.
      // We return 'cancelled' to let the previous screen know the user backed out.
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop('cancelled');
          return true;
        },
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
