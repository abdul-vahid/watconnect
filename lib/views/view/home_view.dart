// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:focus_detector/focus_detector.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as badges;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/datum.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';

import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_fonts.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:whatsapp/utils/notification_utils.dart';
import 'package:whatsapp/view_models/approved_template_vm.dart';
import 'package:whatsapp/view_models/campaign_chart_vm.dart';
import 'package:whatsapp/view_models/lead_controller.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';

import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/views/view/NotificationPage.dart';
import 'package:whatsapp/views/view/campaign_list_view.dart';
import 'package:whatsapp/views/view/lead/lead_list_view.dart';
import 'package:whatsapp/views/view/templete_list_view.dart';
import 'package:whatsapp/views/widgets/home_page_cards.dart';

import '../../models/auto_response_model.dart';
import '../../models/campaign_count_model/campaign_count_model.dart';
import '../../models/campaignchart_model/campaign_chart_vm.dart';
import '../../models/lead_count_agent_model.dart';
import '../../models/lead_count_model.dart';
import '../../models/leadsmonthmodel.dart';
import '../../models/template_model/template_model.dart';
import '../../models/unread_msg_model/unread_msg_model.dart';
import '../../models/whatsapp_setting_model/whatsapp_setting_model.dart';
import '../../utils/app_color.dart';
import '../../utils/function_lib.dart' show debug;
import '../../view_models/auto_response_vm.dart';
import '../../view_models/campaign_count_vm.dart';
import '../../view_models/chart_list_vm.dart';
import '../../view_models/lead_count_vm.dart';
import '../../view_models/templete_list_vm.dart';
import '../../view_models/whatsapp_setting_vm.dart';
import '../widgets/app_drawer_widget.dart';

class _HomeData {
  String? countNewLeads;
  String? autoResponseCount;
  String? campaignCount;
  int? templateCount;
  String? selectedNumber;
  List<_SalesData> businessData = [];
  List<Templatedata> templatedata = [];
  List<String> modules = [];
  bool isLoading = false;

  // Cache for phone numbers
  List<dynamic> allNums = [];
  Map<String, String> itemsMap = {};
}

// ignore: must_be_immutable
class HomeView extends StatefulWidget {
  LeadCountAgentModel? agentModel;
  Leadsmonthmodel? monthmodel;
  HomeView({Key? key, this.agentModel, this.monthmodel}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _homeData = _HomeData();
  late TooltipBehavior _tooltipBehavior;
  IO.Socket? socket;
  List<Color> areaColor = [
    AppColor.navBarIconColor,
    const Color.fromARGB(255, 205, 244, 247),
    Colors.blue,
    Colors.green
  ];

  final _dataRefreshController = StreamController<void>.broadcast();
  late StreamSubscription<void> _dataRefreshSubscription;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    NotificationUtil.registerToken();

    // Listen for data refresh events
    _dataRefreshSubscription = _dataRefreshController.stream.listen((_) {
      _refreshData();
    });

    _initializeData();
  }

  @override
  void dispose() {
    _dataRefreshSubscription.cancel();
    _dataRefreshController.close();
    disconnectSocket();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _homeData.isLoading = true);

    try {
      await Future.wait([
        _getAvailableModules(),
        _loadPhoneNumber(),
        _fetchInitialData(),
      ]);
    } catch (e) {
      print('Error initializing data: $e');
      EasyLoading.showError('Failed to load data');
    } finally {
      if (mounted) {
        setState(() => _homeData.isLoading = false);
      }
    }
  }

  Future<void> _getAvailableModules() async {
    final prefs = await SharedPreferences.getInstance();
    _homeData.modules =
        prefs.getStringList(SharedPrefsConstants.userAvailableMoulesKey) ?? [];
  }

  Future<void> _loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final whatsAppVM =
        Provider.of<WhatsappSettingViewModel>(context, listen: false);

    // Fetch WhatsApp settings first
    await whatsAppVM.fetch();

    String? selectedNumber = prefs.getString('phoneNumber');

    if (selectedNumber == null || selectedNumber.isEmpty) {
      if (whatsAppVM.viewModels.isNotEmpty) {
        selectedNumber = whatsAppVM.viewModels[0].model.record[0].phone;
        await prefs.setString('phoneNumber', selectedNumber ?? "");
      }
    }

    _homeData.selectedNumber = selectedNumber ?? "";

    // Build phone number items map
    _buildPhoneNumberMap(whatsAppVM);
  }

  void _buildPhoneNumberMap(WhatsappSettingViewModel whatsAppSettingVM) {
    final leadController = Provider.of<LeadController>(context, listen: false);
    _homeData.itemsMap.clear();
    leadController.clearAllBusNums();
    _homeData.allNums = [];

    for (var viewModel in whatsAppSettingVM.viewModels) {
      final nmodel = viewModel.model;
      if (nmodel != null) {
        for (var record in nmodel.record ?? []) {
          _homeData.allNums.add(record);
          leadController.setAllBusNums(record.phone);
          _homeData.itemsMap[record.phone] = "${record.name} ${record.phone}";
        }
      }
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedWhatsAppNumber = prefs.getString('phoneNumber');

      await Future.wait([
        // Only fetch essential data
        _fetchChartData(selectedWhatsAppNumber),
        _fetchTemplateData(selectedWhatsAppNumber),
        _fetchCountData(),
      ]);
    } catch (e) {
      print('Error fetching initial data: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> _fetchChartData(String? number) async {
    await Provider.of<CampaignChartViewModel>(context, listen: false)
        .fetchCampaignChart(number: number);
  }

  Future<void> _fetchTemplateData(String? number) async {
    final templateVM =
        Provider.of<TempleteListViewModel>(context, listen: false);

    await Future.wait([
      templateVM.templeteCountfetch(number: number),
      templateVM.templetefetch(number: number),
    ]);
  }

  Future<void> _fetchCountData() async {
    await Future.wait([
      Provider.of<CampaignCountViewModel>(context, listen: false)
          .fetchCampaignCount(number: _homeData.selectedNumber),
      Provider.of<LeadCountViewModel>(context, listen: false).countNewLead(),
      Provider.of<AutoResponseViewModel>(context, listen: false)
          .autoResponseFetch(),
      _getUnreadCount(),
    ] as Iterable<Future>);
  }

  Future<void> _refreshDataWithNewNumber(String number) async {
    setState(() => _homeData.isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phoneNumber', number);
      _homeData.selectedNumber = number;

      await Future.wait([
        Provider.of<CampaignCountViewModel>(context, listen: false)
            .fetchCampaignCount(number: number),
        Provider.of<TempleteListViewModel>(context, listen: false)
            .templeteCountfetch(number: number),
        Provider.of<CampaignChartViewModel>(context, listen: false)
            .fetchCampaignChart(number: number),
      ]);

      _dataRefreshController.add(null);
    } catch (e) {
      print('Error refreshing data: $e');
      EasyLoading.showError('Failed to refresh data');
    } finally {
      if (mounted) {
        setState(() => _homeData.isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    // This will be called when data needs to be refreshed
    _updateCalculatedValues();
    _updateChartData();
    _updateTemplateData();

    if (mounted) {
      setState(() {});
    }
  }

  void _updateCalculatedValues() {
    final leadCountVM = Provider.of<LeadCountViewModel>(context, listen: false);
    final autoResponseVM =
        Provider.of<AutoResponseViewModel>(context, listen: false);
    final campaignVM =
        Provider.of<CampaignCountViewModel>(context, listen: false);
    final templateVM =
        Provider.of<TempleteListViewModel>(context, listen: false);

    // Update leads count
    if (leadCountVM.viewModels.isNotEmpty) {
      _homeData.countNewLeads = leadCountVM.viewModels.first.model.total;
    }

    // Update auto response count
    if (autoResponseVM.viewModels.isNotEmpty) {
      _homeData.autoResponseCount = autoResponseVM.viewModels.first.model.total;
    }

    // Update campaign count
    if (campaignVM.viewModels.isNotEmpty) {
      final campmodel = campaignVM.viewModels.first.model;
      final pend = campmodel.result?.pending ?? "0";
      final comp = campmodel.result?.completed ?? "0";
      final abort = campmodel.result?.aborted ?? "0";
      final prog = campmodel.result?.inProgress ?? "0";

      final allCamp = int.parse(pend) +
          int.parse(comp) +
          int.parse(abort) +
          int.parse(prog);
      _homeData.campaignCount = allCamp.toString();
    }

    // Update template count
    if (templateVM.viewModels.isNotEmpty) {
      _homeData.templateCount =
          templateVM.viewModels.first.model.data?.length ?? 0;
    }
  }

  void _updateChartData() {
    final chartListVM =
        Provider.of<CampaignChartViewModel>(context, listen: false);
    _homeData.businessData.clear();

    for (var viewModel in chartListVM.viewModels) {
      if (viewModel.model is CampaignChartModel) {
        final countagent = viewModel.model as CampaignChartModel;
        if (countagent.result != null) {
          final completed = int.parse(countagent.result?.completed ?? "0");
          final pending = int.parse(countagent.result?.pending ?? "0");
          final inProgress = int.parse(countagent.result?.inProgress ?? "0");
          final aborted = int.parse(countagent.result?.aborted ?? "0");

          _homeData.businessData.addAll([
            _SalesData("Pending", pending),
            _SalesData("In Progress", inProgress),
            _SalesData("Completed", completed),
            _SalesData("Aborted", aborted),
          ]);
        }
      }
    }
  }

  void _updateTemplateData() {
    final templateVM =
        Provider.of<TempleteListViewModel>(context, listen: false);
    final Map<String, int> categoryCount = {};
    _homeData.templatedata.clear();

    for (var viewModel in templateVM.viewModels) {
      if (viewModel.model is TemplateModel) {
        final templateModel = viewModel.model as TemplateModel;
        if (templateModel.data != null) {
          for (var entry in templateModel.data!) {
            final templateCategory = entry.category ?? 'Uncategorized';
            categoryCount[templateCategory] =
                (categoryCount[templateCategory] ?? 0) + 1;
          }
        }
      }
    }

    categoryCount.forEach((category, count) {
      _homeData.templatedata.add(Templatedata(category, count));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_homeData.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FocusDetector(
      onFocusGained: () {
        log('Home Screen focused again');
        connectSocket();
        _dataRefreshController.add(null); // Refresh data on focus
      },
      onFocusLost: () {
        disconnectSocket();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const AppDrawerWidget(),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 2,
          backgroundColor: AppColor.navBarIconColor,
          title: const Text(
            "Home",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            _buildNotificationIcon(),
            _buildPhoneMenu(),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Consumer<UnreadCountVm>(
      builder: (context, unreadCountVm, child) {
        final totalUnreadCount = _calculateUnreadCount(unreadCountVm);

        return IconButton(
          tooltip: "Messages",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationPage(),
              ),
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
                    backgroundColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
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
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      icon: const Icon(Icons.phone, size: 23, color: Colors.white),
      itemBuilder: (BuildContext context) {
        return _homeData.allNums.map((number) {
          final isSelected = number.phone == _homeData.selectedNumber;
          return PopupMenuItem<String>(
            value: number.phone,
            child: Text(
              "${number.name} ${number.phone} ",
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          );
        }).toList();
      },
      onSelected: (value) async {
        await _refreshDataWithNewNumber(value);
        EasyLoading.showToast(
          "$value marked as selected",
          toastPosition: EasyLoadingToastPosition.bottom,
        );
      },
    );
  }

  Widget _buildBody() {
    // Update data before building
    _updateCalculatedValues();
    _updateChartData();
    _updateTemplateData();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildTopCards(),
          const SizedBox(height: 20),
          _buildCharts(),
        ],
      ),
    );
  }

  Widget _buildTopCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          HomePageCard(
            title: "All Leads",
            subtitle: "${(_homeData.countNewLeads ?? 0).toString()} / Total",
            icon: Icons.leaderboard_rounded,
            polygonAsset: "assets/images/home_polygon.png",
            tap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeadListView()),
              );
            },
          ),
          const SizedBox(width: 10),
          HomePageCard(
            title: "All Campaigns",
            subtitle: "${(_homeData.campaignCount ?? 0).toString()} / Total",
            icon: Icons.leaderboard_rounded,
            polygonAsset: "assets/images/home_polygon.png",
            tap: () {
              if (_homeData.modules.contains("Campaign") ||
                  _homeData.modules.contains('Campaigns')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CampaignListView(),
                  ),
                );
              } else {
                EasyLoading.showToast(
                  "Access to Campaign is not included in this Plan",
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          if (_homeData.modules.contains("Campaign") &&
              _homeData.campaignCount != "0")
            _buildCampaignChart(),
          if (_homeData.modules.contains("Campaign") &&
              _homeData.campaignCount != "0")
            const SizedBox(height: 20),
          if (_homeData.templatedata.isNotEmpty) _buildTemplateChart(),
        ],
      ),
    );
  }

  Widget _buildCampaignChart() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Campaign',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SfCircularChart(
            tooltipBehavior: _tooltipBehavior,
            legend: const Legend(
              isVisible: true,
              position: LegendPosition.top,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            series: <PieSeries<_SalesData, String>>[
              PieSeries<_SalesData, String>(
                legendIconType: LegendIconType.circle,
                radius: '100',
                dataSource: _homeData.businessData,
                enableTooltip: true,
                pointColorMapper: (_SalesData sales, int index) =>
                    areaColor[index % areaColor.length],
                xValueMapper: (_SalesData sales, _) => sales.status,
                yValueMapper: (_SalesData sales, _) => sales.count,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateChart() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Template',
            style: TextStyle(
              color: Colors.black,
              fontFamily: AppFonts.semiBold,
              fontSize: 18,
            ),
          ),
          SfCircularChart(
            tooltipBehavior: _tooltipBehavior,
            legend: const Legend(
              isVisible: true,
              position: LegendPosition.top,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            series: <DoughnutSeries<Templatedata, String>>[
              DoughnutSeries<Templatedata, String>(
                radius: '100',
                dataSource: _homeData.templatedata,
                enableTooltip: true,
                pointColorMapper: (Templatedata sales, int index) =>
                    areaColor[index % areaColor.length],
                xValueMapper: (Templatedata sales, _) => sales.status,
                yValueMapper: (Templatedata sales, _) => sales.count,
              )
            ],
          ),
        ],
      ),
    );
  }

  int _calculateUnreadCount(UnreadCountVm unreadCountVm) {
    int totalUnreadCount = 0;
    for (var viewModel in unreadCountVm.viewModels) {
      if (viewModel.model is UnreadMsgModel) {
        final unreadvm = viewModel.model as UnreadMsgModel;
        totalUnreadCount = unreadvm.records?.length ?? 0;
      }
    }
    return totalUnreadCount;
  }

  Future<void> connectSocket() async {
    log("connecting to socket::::::::::::::::::::::::::::::::: ");
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString('phoneNumber');
    final leadCtrl = Provider.of<LeadController>(context, listen: false);
    final tkn = await AppUtils.getToken() ?? "";
    final decodedToken = Map<String, dynamic>.from(JwtDecoder.decode(tkn));

    final userId = {
      ...decodedToken,
      "business_numbers": leadCtrl.allBusinessNumbers,
      "business_number": number
    };

    log("user id sending in socket setup::::   $userId");

    try {
      socket = IO.io(
        'https://admin.watconnect.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/ibs/socket.io')
            .setExtraHeaders({'Authorization': 'Bearer $tkn'})
            .build(),
      );
      socket!.connect();
      socket!.onConnect((_) {
        print('Connected to WebSocket on home');
        socket!.emit("setup", userId);
      });
      socket!.on("connected", (_) {});
      socket!.on("receivedwhatsappmessage", (data) {
        _getUnreadCount();
      });
      socket!.onDisconnect((_) {
        print(" WebSocket Disconnected home");
      });
      socket!.onError((error) {
        print(" WebSocket Error home: $error");
      });
    } catch (error) {
      print("Error connecting to WebSocket home: $error");
    }
  }

  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString('phoneNumber');

    if (!mounted) return;

    await Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number ?? "");

    _dataRefreshController.add(null); // Trigger UI refresh
  }

  void disconnectSocket() {
    if (socket != null) {
      socket!.disconnect();
      print(" WebSocket Disconnected on home");
    }
  }
}

class _SalesData {
  _SalesData(this.status, this.count);
  final String status;
  final int count;
}

class Templatedata {
  Templatedata(this.status, this.count);
  final String status;
  final int count;
}
