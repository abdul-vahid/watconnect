import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart'
    show InternetConnectionChecker;
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import '../../utils/app_color.dart';
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
  // late StreamSubscription subscription;
  int selectedPage = 0;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  int _currentPageIndex = 0;
  // late NotchBottomBarController _controller;

  @override
  void initState() {
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

  final _pageOptions = [
    HomeView(),
    ProfileView(),
    const UserListView(),
    const Whtsapphone(),
  ];
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
            BottomBarItem(
              icon: const Icon(Icons.settings_accessibility_outlined),
              title: const Text('User'),
              backgroundColor: Colors.white,
            ),
            BottomBarItem(
              icon: const Icon(Icons.phone),
              title: const Text('Phone'),
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
