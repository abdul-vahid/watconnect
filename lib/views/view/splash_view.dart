// ignore_for_file: use_build_context_synchronously, unnecessary_brace_in_string_interps, library_private_types_in_public_api

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';

import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';

import 'package:whatsapp/views/view/login_view.dart';
import '../widgets/bottomnavigatonbar.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // registerToken();
    startTimer();
    // setupFirebase();
  }

  void startTimer() async {
    const duration = Duration(seconds: 3);
    Timer(duration, _isLoggedIn);
  }

  void _isLoggedIn() async {
    String signature = await SmsAutoFill().getAppSignature;
    print(
        " for sms autofill this is right now for test>>>>>>>>>>>>>>>>>>>. $signature");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String sfAccessToken =
        prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
    String user = prefs.getString(SharedPrefsConstants.userKey) ?? "";
    String sfNodeToken = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
    
    log("🔍 Splash screen token check:");
    log("   SF Access Token: '${sfAccessToken}' (length: ${sfAccessToken.length})");
    log("   User Token: '${user}' (length: ${user.length})");
    log("   SF Node Token: '${sfNodeToken}' (length: ${sfNodeToken.length})");

    // FIXED: Check if values are NOT EMPTY and have meaningful length
    if ((sfAccessToken.isNotEmpty && sfAccessToken.length > 10) || 
        (user.isNotEmpty && user.length > 10) || 
        (sfNodeToken.isNotEmpty && sfNodeToken.length > 10)) {
      log("✅ Valid tokens found, proceeding to main app");
      if (user.isEmpty) {
        DashBoardController dashBoardController =
            Provider.of(context, listen: false);
        dashBoardController.setLoginType(true);
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const FooterNavbarPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      log("❌ No valid tokens found, redirecting to login");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBgGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/whatsapp.png",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor:
                        AlwaysStoppedAnimation(AppColor.navBarIconColor),
                    minHeight: 5,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
