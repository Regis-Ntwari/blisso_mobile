import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewVerification extends StatefulWidget {
  final String url;
  const WebviewVerification({super.key, required this.url});

  @override
  State<WebviewVerification> createState() => _WebviewVerificationState();
}

class _WebviewVerificationState extends State<WebviewVerification> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final decodedURL = Uri.decodeComponent(widget.url);
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            const LoadingScreen();
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          // onNavigationRequest: (NavigationRequest request) {
          //   if (request.url.startsWith('https://www.youtube.com/')) {
          //     return NavigationDecision.prevent;
          //   }
          //   return NavigationDecision.navigate;
          // },
        ),
      )
      ..loadRequest(Uri.parse(decodedURL));
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () => Routemaster.of(context).replace('/homepage'),
            child: const Icon(Icons.keyboard_arrow_left),
          ),
          title: const Text(
            'Blisso',
            style: TextStyle(color: GlobalColors.primaryColor),
          ),
        ),
        body: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
