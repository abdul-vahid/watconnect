import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart'
    show InternetConnectionChecker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:whatsapp/models/user_model/user_model.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:whatsapp/views/view/recent_chats_screen.dart';

import '../../utils/app_color.dart';
import '../../utils/notification_utils.dart';
import '../view/home_view.dart';
import '../view/profile_view.dart' show ProfileView;
import '../view/user_list_view.dart';
import '../view/whatsappphone.dart';

class FooterNavbarPage extends StatefulWidget {
  const FooterNavbarPage({super.key});

  @override
  State<FooterNavbarPage> createState() => _FooterNavbarPageState();
}

class _FooterNavbarPageState extends State<FooterNavbarPage> {
  UserModel? userModelData;
  // late StreamSubscription subscription;
  int selectedPage = 0;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  int _currentPageIndex = 0;
  // late NotchBottomBarController _controller;

  @override
  void initState() {
    NotificationUtil(context).initialize();

    SharedPreferences.getInstance().then((prefs) {
      userModelData = AppUtils.getSessionUser(prefs);
      print("userModelData${userModelData}");
      // userModel ?? AppUtils.logout(context);
    });
    getuserrole();
    print("init startwtwtwyw=>${userModelData?.userrole}");
    super.initState();
    // _controller = NotchBottomBarController();
    // getConnectivity();s
    setState(() {
      _currentPageIndex = 0;
    });
  }

  @override
  void dispose() {
    // subscription.cancel();
    super.dispose();
  }

  // getConnectivity() {
  //   subscription = Connectivity()
  //       .onConnectivityChanged
  //       .listen((ConnectivityResult result) async {
  //     isDeviceConnected =
  //         await InternetConnectionChecker._instance.hasConnection;
  //     if (!isDeviceConnected && !isAlertSet) {
  //       showDialogBox();
  //       setState(() => isAlertSet = true);
  //     }
  //   });
  // }

  int selected = 0;

  Future<bool> _onWillPop() async {
    return (await showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), //<-- SEE HERE
                child: const Text('No',
                    style: TextStyle(color: AppColor.navBarIconColor)),
              ),
              TextButton(
                  onPressed: () => exit(0), // <-- SEE HERE
                  child: const Text('Yes',
                      style: TextStyle(color: AppColor.navBarIconColor))),
            ],
          ),
        )) ??
        false;
  }

  // void getuserrole() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   print(" wowowoow");
  //   userModelData = await AppUtils.getSessionUser(prefs);
  //   print("userModelData=>${userModelData?.userrole}");
  //   setState(() {
  //     // userModelData.userrole
  //   });
  //   print("dsfggggggg=>${userModelData?.userrole}");
  // }
  void getuserrole() async {
    final prefs = await SharedPreferences.getInstance();
    print("userModelData=>${userModelData?.userrole}");
    setState(() {
      userModelData = AppUtils.getSessionUser(prefs);
    });
    print("dsfggggggg=>${userModelData?.userrole}");
  }

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('No Connection'),
          content: const Text('Please check your internet connectivity'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && !isAlertSet) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
  @override
  Widget build(BuildContext context) {
    final _pageOptions = [
      HomeView(),
      ProfileView(),
      if (userModelData?.userrole == "ADMIN") const UserListView(),
      // const Whtsapphone(),
      const RecentChatView(),
    ];
    // print("dsfffffffffffffffffffffffffff=>${userModelData?.userrole}");
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _pageOptions[selected],
        bottomNavigationBar: StylishBottomBar(
          backgroundColor: AppColor.navBarIconColor,
          option: DotBarOptions(
            dotStyle: DotStyle.tile,
            gradient: const LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          items: [
            BottomBarItem(
              showBadge: false,
              icon: const Icon(Icons.home_filled),
              title: const Text('Home'),
              backgroundColor: Colors.white,
              selectedIcon: const Icon(Icons.home_filled),
            ),
            BottomBarItem(
              icon: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              backgroundColor: Colors.white,
            ),
            if (userModelData?.userrole == "ADMIN")
              BottomBarItem(
                icon: const Icon(Icons.settings_accessibility_outlined),
                title: const Text('User'),
                backgroundColor: Colors.white,
              ),
            // BottomBarItem(
            //   icon: const Icon(Icons.phone),
            //   title: const Text('Phone'),
            //   backgroundColor: Colors.white,
            // ),
            BottomBarItem(
              icon: const Icon(Icons.chat),
              title: const Text('Chats'),
              backgroundColor: Colors.white,
            ),
          ],
          hasNotch: true,
          currentIndex: selected,
          onTap: (index) {
            setState(() {
              selected = index;
            });
          },
        ),
      ),
    );
  }
}
