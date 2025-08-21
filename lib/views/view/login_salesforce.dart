// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
import 'package:whatsapp/views/widgets/bottomnavigatonbar.dart';
// import 'package:whatsapp/salesforce/screens/sf_dashboard.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

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
                  await chatMessageController.getSfAccessTokenApiCall(body);

              if (success) {
                DashBoardController dashBoardController =
                    Provider.of(context, listen: false);

                SfFileUploadController sfFileUploadController =
                    Provider.of(context, listen: false);

                await sfFileUploadController.getReactCredApiCall();
                // "shivani.m+s@ibirdsservices.com",
                // "Admin@123",
                // "salesforce");
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
          leading: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          title: const Text(
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
