// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/views/view/login_view.dart';
import 'package:whatsapp/views/widgets/bottomnavigatonbar.dart';
// import 'package:whatsapp/salesforce/screens/sf_dashboard.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String env;
  final sfLoginType loginType;

  const WebViewPage({
    super.key,
    required this.url,
    required this.env,
    required this.loginType,
  });

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  String? visitedUrl;

  @override
  @override
  void initState() {
    super.initState();

    debugPrint("widget.loginType::::::::::::::: ${widget.loginType}");
    debugPrint("URL::::::::::::::: ${widget.url}");

    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              debugPrint("Page started loading: $url");
              if (mounted) {
                setState(() => visitedUrl = url);
              }
            },
            onPageFinished: (String url) async {
              debugPrint("Final loaded URL: $url");

              if (!mounted) return;

              setState(() => visitedUrl = url);

              Uri uri = Uri.parse(url);
              debugPrint("URI:::::::::: $uri");

              String? authCode = uri.queryParameters["code"];
              debugPrint("Authorization Code: $authCode");
              if (authCode != null) {
                debugPrint("Authorization Code: $authCode");

                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(SharedPrefsConstants.sfEnv, widget.env);

                Map<String, String> body = {
                  "grant_type": "authorization_code",
                  "client_id": widget.loginType == sfLoginType.WatConnect
                      ? "3MVG9dAEux2v1sLvMShd1QqukhBR6uzZfjJuCm2Jind0stiCXF_X4sJrrVuyO9mz6e2efAESPs532ydpDE_nZ"
                      : "3MVG9dAEux2v1sLu9_ht_e8ED9vCM5br3PAMdEIJiJ4BmAN5eKQ7aSvd0wZGn3gq3KQy1Z3aDIf8xQUGDTXcc",
                  "client_secret": widget.loginType == sfLoginType.WatConnect
                      ? "195E44ED6BAFD4F6F5CB20343F7FFC169616D9C417B3C51089B00F6487E0F459"
                      : "F105FEAA63B821AE7F6C6E7004E7BFA5206212864DD18B3C65F5610626BFFB06",
                  "code": authCode,
                  "redirect_uri": widget.env == 'Test'
                      ? "https://test.salesforce.com/services/oauth2/success"
                      : "https://login.salesforce.com/services/oauth2/success",
                };

                debugPrint("BODY:::::::: $body");

                // Provider calls in post frame
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  ChatMessageController chatMessageController =
                      Provider.of(context, listen: false);
                  
                  // Store login type and environment before making API call
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(SharedPrefsConstants.sfLoginType, 
                      widget.loginType == sfLoginType.WatConnect ? "WatConnect" : "SFWatConnect");
                  await prefs.setString(SharedPrefsConstants.sfEnv, widget.env);

                  bool success =
                      await chatMessageController.getSfAccessTokenApiCall(body);

                  if (success) {
                    DashBoardController dashBoardController =
                        Provider.of(context, listen: false);

                    SfFileUploadController sfFileUploadController =
                        Provider.of(context, listen: false);

                    await sfFileUploadController.getReactCredApiCall();

                    dashBoardController.setLoginType(true);

                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FooterNavbarPage(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                });
              } else {
                debugPrint("No authorization code found.");
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              debugPrint("Redirected URL: ${request.url}");
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    } catch (e) {
      debugPrint("INIT ERROR:::::::: $e");
    }
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
