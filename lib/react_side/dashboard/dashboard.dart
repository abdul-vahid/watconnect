import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/call_socket.dart';
import 'package:whatsapp/models/user_model/user_model.dart';
import 'package:whatsapp/react_side/home/pages/home_page_screen.dart';
import 'package:whatsapp/react_side/lead/page/lead_list_page.dart';
import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/screens/sf_home_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_profile_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_recent_chat_screen.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:whatsapp/utils/notification_utils.dart';
import 'package:whatsapp/view_models/lead_controller.dart';
import 'package:whatsapp/views/view/profile_view.dart';
import 'package:whatsapp/views/view/user_list_view.dart'; 

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  int _selectedIndex = 0;

  UserModel? userModelData;
  bool isSalesforce = false;

  List<Widget> screens = [];

  bool _socketConnected = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();


    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    final drProvider =
        Provider.of<DashBoardController>(context, listen: false);

    isSalesforce = drProvider.fromSalesForce;

    userModelData = AppUtils.getSessionUser(prefs);

    await _setupSocket(prefs);
    await _getBusinessNumbers();

    _buildScreens();

    if (!mounted) return;
    setState(() {});
  }

  void _buildScreens() {
    screens = [
      isSalesforce ? const SfHomeScreen() : HomePageScreen(),
      isSalesforce ? const SfProfileScreen() : ProfileView(),

      if (userModelData?.userrole == "ADMIN")
        const UserListView(),

      isSalesforce
          ? const SfRecentChatScreen()
          : const LeadListPage(),
    ];
  }

 
  List<BottomNavigationBarItem> _navItems() {
    return [
      const BottomNavigationBarItem(
          icon: Icon(Icons.home), label: "Home"),

      const BottomNavigationBarItem(
          icon: Icon(Icons.person), label: "Profile"),

      if (userModelData?.userrole == "ADMIN")
        const BottomNavigationBarItem(
            icon: Icon(Icons.people), label: "Users"),

      const BottomNavigationBarItem(
          icon: Icon(Icons.chat), label: "Chats"),
    ];
  }


  Future<void> _setupSocket(SharedPreferences prefs) async {
    final drProvider =
        Provider.of<DashBoardController>(context, listen: false);

    if (drProvider.fromSalesForce && !_socketConnected) {
      String tkn = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";

      if (tkn.isNotEmpty) {
        Map<String, dynamic> decodedToken =
            Map<String, dynamic>.from(JwtDecoder.decode(tkn));

        String deviceId =
            prefs.getString(SharedPrefsConstants.deviceId) ?? "";

        final busNum =
            prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

        LeadController leadCtrl =
            Provider.of<LeadController>(context, listen: false);

        decodedToken.addAll({
          "business_numbers": leadCtrl.allBusinessNumbers,
          "business_number": busNum
        });

        CallSocketService().connect(tkn, decodedToken, deviceId, busNum);
        _socketConnected = true;
      }
    }

    bool hasCalls =
        prefs.getBool(SharedPrefsConstants.hasCallsKey) ?? false;

    if (hasCalls && !_socketConnected) {
      String tkn = await AppUtils.getToken() ?? "";

      if (tkn.isNotEmpty) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(tkn);

        String deviceId =
            prefs.getString(SharedPrefsConstants.deviceId) ?? "";

        String busPhNum = prefs.getString('phoneNumber') ?? "";

        CallSocketService().connect(tkn, decodedToken, deviceId, busPhNum);
        _socketConnected = true;
      }
    }
  }


  Future<void> _getBusinessNumbers() async {
    final drProvider =
        Provider.of<DashBoardController>(context, listen: false);

    if (drProvider.fromSalesForce) {
      final busCtrl =
          Provider.of<BusinessNumberController>(context, listen: false);

      await busCtrl.getBusinessNumberApiCall();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (screens.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex.clamp(0, screens.length - 1),
            children: screens,
          ),

          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: AppColor.navBarIconColor,
            currentIndex: _selectedIndex.clamp(0, screens.length - 1),
            onTap: (index) {
              if (index < screens.length) {
                setState(() => _selectedIndex = index);
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white38,
            items: _navItems(),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}