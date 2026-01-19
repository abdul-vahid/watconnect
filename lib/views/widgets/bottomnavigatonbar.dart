// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously

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
import 'package:whatsapp/view_models/lead_controller.dart';
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
  int selectedPage = 0;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  int selected = 0;

  @override
  void initState() {
    NotificationUtil(context).initialize();

    SharedPreferences.getInstance().then((prefs) {
      userModelData = AppUtils.getSessionUser(prefs);
      print("userModelData initrole ${userModelData?.userrole}");
    });
    getBusNumApiCall();
    getuserrole();
    super.initState();
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
                  onPressed: () => exit(0),
                  child: const Text('Yes',
                      style: TextStyle(color: AppColor.navBarIconColor))),
            ],
          ),
        )) ??
        false;
  }

  void getuserrole() async {
    final prefs = await SharedPreferences.getInstance();
    DashBoardController drProvider = Provider.of(context, listen: false);

    if (drProvider.fromSalesForce) {
      String tkn = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
      print("node token ::::  ${tkn}");
      // Map<String, dynamic> decodedToken = JwtDecoder.decode(tkn);
      // var userId = decodedToken;

      Map<String, dynamic> decodedToken = Map<String, dynamic>.from(
        JwtDecoder.decode(tkn),
      );

      // token = tkn;
      // phNum = number ?? "";
      Map<String, dynamic> userId = decodedToken;

      String deviId = prefs.getString(SharedPrefsConstants.deviceId) ?? "";
      final busNum =
          prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      LeadController leadCtrl = Provider.of(context, listen: false);
      userId.addAll({
        "business_numbers": leadCtrl.allBusinessNumbers,
        "business_number": busNum
      });
      CallSocketService().connect(tkn, userId, deviId, busNum);
    }

    bool hasCalls = prefs.getBool(SharedPrefsConstants.hasCallsKey) ?? false;
    if (hasCalls) {
      String tkn = await AppUtils.getToken() ?? "";
      Map<String, dynamic> decodedToken = JwtDecoder.decode(tkn);
      var userId = decodedToken;
      String deviId = prefs.getString(SharedPrefsConstants.deviceId) ?? "";
      String busPhNum = prefs.getString('phoneNumber') ?? "";
      CallSocketService().connect(tkn, userId, deviId, busPhNum);
    }

    setState(() {
      userModelData = AppUtils.getSessionUser(prefs);
    });
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

    final List<Map<String, dynamic>> items = [
      {'icon': Icons.home, 'label': 'Home', 'visible': true},
      {'icon': Icons.person, 'label': 'Profile', 'visible': true},
      {
        'icon': Icons.people,
        'label': 'Users',
        'visible': userModelData?.userrole == "ADMIN"
      },
      {'icon': Icons.chat, 'label': 'Chats', 'visible': true},
    ];

    final visibleItems =
        items.where((item) => item['visible'] == true).toList();

    final pageOptions = [
      drProvider.fromSalesForce ? const SfHomeScreen() : HomeView(),
      drProvider.fromSalesForce ? const SfProfileScreen() : ProfileView(),
      if (userModelData?.userrole == "ADMIN") const UserListView(),
      drProvider.fromSalesForce
          ? const SfRecentChatScreen()
          : const RecentChatView(),
      // ignore: unnecessary_null_comparison
    ].where((page) => page != null).toList();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => selected = index),
            children: pageOptions,
          ),
          bottomNavigationBar: _buildSimpleBottomNavigationBar(
            selected: selected,
            items: visibleItems,
            onItemTap: (index) {
              setState(() => selected = index);
              _pageController.jumpToPage(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleBottomNavigationBar({
    required int selected,
    required List<Map<String, dynamic>> items,
    required Function(int) onItemTap,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColor.navBarIconColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = selected == index;
        return GestureDetector(
  behavior: HitTestBehavior.opaque, // VERY IMPORTANT
  onTap: () => onItemTap(index),
  child: SizedBox(
    width: 80, // increases horizontal tap area
    height: double.infinity, // full navbar height
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          items[index]['icon'] as IconData,
          color: isSelected ? Colors.white : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          items[index]['label'] as String,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight:
                isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    ),
  ),
);

        }),
      ),
    );
  }
}
