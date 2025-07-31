// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart'
    show InternetConnectionChecker;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/call_socket.dart';
import 'package:whatsapp/models/user_model/user_model.dart';
import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/screens/sf_home_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_profile_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_recent_chat_screen.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:whatsapp/views/view/recent_chats_screen.dart';

import '../../utils/app_color.dart';
import '../../utils/notification_utils.dart';
import '../view/home_view.dart';
import '../view/profile_view.dart' show ProfileView;
import '../view/user_list_view.dart';

class FooterNavbarPage extends StatefulWidget {
  const FooterNavbarPage({super.key});

  @override
  State<FooterNavbarPage> createState() => _FooterNavbarPageState();
}

class _FooterNavbarPageState extends State<FooterNavbarPage> {
  final PageController _pageController = PageController();
  UserModel? userModelData;
  // late StreamSubscription subscription;
  int selectedPage = 0;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  int selected = 0;
  // late NotchBottomBarController _controller;

  @override
  void initState() {
    NotificationUtil(context).initialize();

    SharedPreferences.getInstance().then((prefs) {
      userModelData = AppUtils.getSessionUser(prefs);
      print("userModelData initrole ${userModelData?.userrole}");
      // userModel ?? AppUtils.logout(context);
    });
    getBusNumApiCall();
    getuserrole();
    print("init startwtwtwyw=>${userModelData?.userrole}");
    super.initState();

    setState(() {});
  }

  getBusNumApiCall() async {
    DashBoardController drProvider = Provider.of(context, listen: false);

    if (drProvider.fromSalesForce) {
      BusinessNumberController busNumCtrl = Provider.of(context, listen: false);
      await busNumCtrl.getBusinessNumberApiCall();
    }
  }

  @override
  void dispose() {
    // subscription.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
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

  void getuserrole() async {
    final prefs = await SharedPreferences.getInstance();
    print("userModelData=>${userModelData?.userrole}");

    bool hasCalls = prefs.getBool(SharedPrefsConstants.hasCallsKey) ?? false;
    if (hasCalls) {
      String tkn = await AppUtils.getToken() ?? "";
      Map<String, dynamic> decodedToken = JwtDecoder.decode(tkn);
      var userId = decodedToken;

      CallSocketService().connect(tkn, userId);
    }
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
    DashBoardController drProvider = Provider.of(context, listen: false);
    print(
        "drProvider::::: from salesforce:::::::  ${drProvider.fromSalesForce}");
    final pageOptions = [
      drProvider.fromSalesForce ? const SfHomeScreen() : HomeView(),
      drProvider.fromSalesForce ? const SfProfileScreen() : ProfileView(),
      if (userModelData?.userrole == "ADMIN") const UserListView(),
      drProvider.fromSalesForce
          ? const SfRecentChatScreen()
          : const RecentChatView(),
    ];

    final List<Map<String, dynamic>> items = [
      {'icon': Icons.home_filled, 'label': 'Home'},
      {'icon': Icons.account_circle, 'label': 'Profile'},
      if (userModelData?.userrole == "ADMIN")
        {'icon': Icons.settings_accessibility_outlined, 'label': 'Users'},
      {'icon': Icons.chat, 'label': 'Chats'},
    ];
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => selected = index),
            children: pageOptions,
          ),
          bottomNavigationBar: buildBottomNavigationBar(
            selected: selected,
            items: items,
            context: context,
            onItemTap: (index) {
              setState(() => selected = index);
              _pageController.jumpToPage(index);
            },
          ),
        )

        // Scaffold(
        //   body: _pageOptions[selected],
        //   bottomNavigationBar: StylishBottomBar(
        //     backgroundColor: AppColor.navBarIconColor,
        //     option: DotBarOptions(
        //       dotStyle: DotStyle.tile,
        //       gradient: const LinearGradient(
        //         colors: [Colors.white, Colors.white],
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomRight,
        //       ),
        //     ),

        //     hasNotch: true,
        //     currentIndex: selected,
        //     onTap: (index) {
        //       setState(() {
        //         selected = index;
        //       });
        //     },
        //   ),
        // ),
        );
  }
}

Widget buildBottomNavigationBar({
  required int selected,
  required List<Map<String, dynamic>> items,
  required Function(int) onItemTap,
  required BuildContext context,
}) {
  return SizedBox(
    height: 60,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // Blue nav bar background
        Container(
          height: 60,
          decoration: const BoxDecoration(
            color: AppColor.navBarIconColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = selected == index;
              return GestureDetector(
                onTap: () => onItemTap(index),
                child: SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: isSelected
                              ? const SizedBox()
                              : Icon(
                                  items[index]['icon'],
                                  color: Colors.white,
                                  size: 25,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          items[index]['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        // Animated white notch
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          top: -20,
          left: MediaQuery.of(context).size.width / items.length * selected +
              (MediaQuery.of(context).size.width / items.length - 50) / 2,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 550),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Container(
              key: ValueKey<int>(selected),
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                items[selected]['icon'],
                size: 24,
                color: AppColor.navBarIconColor,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
