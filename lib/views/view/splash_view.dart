import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/views/view/login_view.dart';

import '../../utils/app_constants.dart';
import '../widgets/bottomnavigatonbar.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, _isLoggedIn);
  }

  void _isLoggedIn() {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.containsKey(SharedPrefsConstants.userKey)) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const FooterNavbarPage()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginView()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      "assets/images/whatsapp.png", // Path to your logo
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
