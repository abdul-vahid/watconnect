import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/views/widgets/bottomnavigatonbar.dart';
// import 'package:whatsapp/salesforce/screens/sf_dashboard.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  WebViewPage({required this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  String? visitedUrl;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => visitedUrl = url);
            print("Page started loading: $url");
          },
          onPageFinished: (String url) async {
            setState(() => visitedUrl = url);
            print("Final loaded URL: $url");

            Uri uri = Uri.parse(url);

            String? authCode = uri.queryParameters["code"];

            if (authCode != null) {
              print("Extracted Authorization Code: $authCode");

              Map<String, String> body = {
                "grant_type": "authorization_code",
                "client_id":
                    "3MVG9HDaKRUgW3VrsUI_RKn2LNBUcxtribjudS7kOePtrSPn9mK.aWox_5gvqxOTD50qyOmRcRWV6jp3jwTOs",
                "client_secret":
                    "A34A06D1DD329F2DCEED942971BF62FC3758588B2DF22EB4FF86FA1A0B6A5C87",
                "code": authCode,
                "redirect_uri":
                    "https://test.salesforce.com/services/oauth2/success",
              };

              ChatMessageController chatMessageController =
                  Provider.of(context, listen: false);
              bool success =
                  await chatMessageController.getSfAccessTokenApiApiCall(body);

              if (success) {
                DashBoardController dashBoardController =
                    Provider.of(context, listen: false);
                dashBoardController.setLoginType(true);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FooterNavbarPage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            } else {
              print("No authorization code found in URL.");
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print("Redirected URL: ${request.url}");
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Salesforce Login",
        style: TextStyle(color: Colors.white),
      )),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _controller)),
          // if (visitedUrl != null)
          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Text("Visited URL: $visitedUrl"),
          // ),
        ],
      ),
    );
  }
}
