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
            print("uri::::::::::  $uri");

            String? authCode = uri.queryParameters["code"];

            if (authCode != null) {
              print("Extracted Authorization Code: $authCode");

              Map<String, String> body = {
                "grant_type": "authorization_code",
                "client_id":
                    "3MVG9dAEux2v1sLvMShd1QqukhBR6uzZfjJuCm2Jind0stiCXF_X4sJrrVuyO9mz6e2efAESPs532ydpDE_nZ",
                "client_secret":
                    "195E44ED6BAFD4F6F5CB20343F7FFC169616D9C417B3C51089B00F6487E0F459",
                "code": authCode,
                "redirect_uri":
                    "https://login.salesforce.com/services/oauth2/success",
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
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
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
