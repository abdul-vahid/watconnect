import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as badges;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:whatsapp/react_side/home/controller/home_summary_controller.dart';
import 'package:whatsapp/react_side/home/model/business_number_model.dart';
import 'package:whatsapp/react_side/home/widgets/chart_section.dart';
import 'package:whatsapp/react_side/home/widgets/top_section.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:whatsapp/view_models/get_user_vm.dart';
import 'package:whatsapp/view_models/lead_controller.dart';
import 'package:whatsapp/views/view/NotificationPage.dart';

import 'package:whatsapp/views/widgets/app_drawer_widget.dart';


class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  void initState() {
    getChartData();
    
    super.initState();
  }

  IO.Socket? _socket;
  List<String> _modules = [];

  final List<ChartData> _businessData = [];
  final List<TemplateChartData> _templateData = [];

  getChartData() async {
    final prefs = await SharedPreferences.getInstance();
 await _checkPasswordChange();
    _modules =
        prefs.getStringList(SharedPrefsConstants.userAvailableMoulesKey) ?? [];

    final ctrl = context.read<HomeSummaryController>();
   await ctrl.fetchBusinessNumbers();
    ctrl.fetchUnreadList();



    await ctrl.fetchHomeSummary();
    _templateData.add(TemplateChartData("Marketing",
        ctrl.homeSummary?.data?.templateCategoryCount?.marketing ?? 0));
    _templateData.add(TemplateChartData("Utility",
        ctrl.homeSummary?.data?.templateCategoryCount?.utility ?? 0));

    _businessData.addAll([
      ChartData(
          "Pending", ctrl.homeSummary?.data?.campaignStatus?.pending ?? 0),
      ChartData("In Progress",
          ctrl.homeSummary?.data?.campaignStatus?.inProgress ?? 0),
      ChartData(
          "Completed", ctrl.homeSummary?.data?.campaignStatus?.completed ?? 0),
      ChartData(
          "Aborted", ctrl.homeSummary?.data?.campaignStatus?.aborted ?? 0),
    ]);
    setState(() {
      
    });
  }

  final List<Color> _areaColor = [
    AppColor.navBarIconColor,
    const Color.fromARGB(255, 205, 244, 247),
    Colors.blue,
    Colors.green,
  ];


  @override
  Widget build(BuildContext context) {
    return FocusDetector(
         onFocusGained: () {
                      log('Home Screen focused again');
                      _connectSocket();
                    },
                    onFocusLost: () {
                      _disconnectSocket();
                    },
      child: Scaffold(
          backgroundColor: Colors.white,
          drawer: const AppDrawerWidget(),
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                TopCardsSection(modules: _modules),
                const SizedBox(height: 20),
                ChartsSection(modules: _modules,),
              ],
            ),
          )),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      elevation: 2,
      backgroundColor: AppColor.navBarIconColor,
      title: const Text("Home", style: TextStyle(color: Colors.white)),
      actions: [
        _buildNotificationIcon(),
        _buildPhoneMenu(),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return Consumer<HomeSummaryController>(
      builder: (context, ctrl, child) {
        final totalUnreadCount = ctrl.unReadData?.total??0;

        return IconButton(
          tooltip: "Messages",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
          },
          icon: Stack(
            children: [
              const Icon(Icons.notifications, size: 28),
              if (totalUnreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: badges.Badge(
                    isLabelVisible: true,
                    label: Text(
                      totalUnreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
                    padding: const EdgeInsets.all(2),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoneMenu() {
    return Consumer<HomeSummaryController>(
      builder: (context, ctrl, child) {
        return PopupMenuButton<BusinessRecord>(
          position: PopupMenuPosition.under,
          icon: const Icon(Icons.phone, size: 23, color: Colors.white),
          itemBuilder: (BuildContext context) {
            return ctrl.businessNumbers.map((number) {
              final isSelected =
                  number.phone == ctrl.selectedBusinessNum?.phone;

              return PopupMenuItem<BusinessRecord>(
                value: number,
                child: Row(
                  children: [
                    if (isSelected)
                      const Icon(Icons.check, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${number.name} ${number.phone}",
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          onSelected: (value) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('phoneNumber', value.phone ?? "");

            ctrl.setSelectedBusinessNum(value);

            EasyLoading.showToast(
              "$value marked as selected",
              toastPosition: EasyLoadingToastPosition.bottom,
            );
          },
        );
      },
    );
  }
Future<void> _connectSocket() async {
    log("connecting to socket::::::::::::::::::::::::::::::::: ");
    
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString('phoneNumber');
    final tkn = await AppUtils.getToken() ?? "";
    
    Map<String, dynamic> decodedToken = {};
    try {
      decodedToken = Map<String, dynamic>.from(JwtDecoder.decode(tkn));
    } catch (e, stackTrace) {
      print("error in decode token >>>. $e. >>>> $stackTrace");
    }  final ctrl = context.read<HomeSummaryController>();
    
   var _token = tkn;
   var _phNum = number ?? "";
    
    final userId = {
      ...decodedToken,
      "business_numbers": ctrl.activeBusinessNumbers,
      "business_number": number
    };

    log("user id sending in socket setup::::   $userId");

    try {
      _socket = IO.io(
        'https://admin.watconnect.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/ibs/socket.io')
            .setExtraHeaders({'Authorization': 'Bearer $_token'})
            .build(),
      );
      
      _socket!.connect();
      _socket!.onConnect((_) {
        print('Connected to WebSocket on home');
        _socket!.emit("setup", userId);
      });
      _socket!.on("connected", (_) {});
      _socket!.on("receivedwhatsappmessage", (data) {
          

      ctrl.fetchUnreadList();
      });
      _socket!.onDisconnect((_) {
        print(" WebSocket Disconnected home");
      });
      _socket!.onError((error) {
        print(" WebSocket Error home: $error");
      });
    } catch (error) {
      print("Error connecting to WebSocket home: $error");
    }
  }

    void _disconnectSocket() {
    _socket?.disconnect();
    print(" WebSocket Disconnected on home");
  }
  
  Future<void> _checkPasswordChange() async {
    final tkn = await AppUtils.getToken() ?? "";
    Map<String, dynamic> decodedToken;
    
    try {
      decodedToken = Map<String, dynamic>.from(JwtDecoder.decode(tkn));
    } catch (e) {
      print("Error decoding token: $e");
      return;
    }

    final userCtrl = Provider.of<GetUserViewModel>(context, listen: false);
    userCtrl.clearUserData();
    await userCtrl.fetchUser();
    
    for (var viewModel in userCtrl.viewModels) {
      final model = viewModel.model;
      print("model password_changed_at ${model.password_changed_at}. decoded token>>> ${decodedToken['password_changed_at']}");

      if (model.password_changed_at != decodedToken['password_changed_at']) {
        AppUtils.logout(context);
      }
    }
  }


}

class ChartData {
  final String status;
  final int count;

  ChartData(this.status, this.count);
}

class TemplateChartData {
  final String status;
  final int count;

  TemplateChartData(this.status, this.count);
}
