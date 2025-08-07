// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use, prefer_typing_uninitialized_variables, non_constant_identifier_names

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
import 'package:whatsapp/view_models/lead_list_vm.dart';

import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/views/view/NotificationPage.dart';
import 'package:whatsapp/views/view/campaign_list_view.dart';
// import 'package:whatsapp/views/view/clipper_test.dart';
import 'package:whatsapp/views/view/lead_list_view.dart';
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
import '../../view_models/campaign_chart_vm.dart' show CampaignChartViewModel;
import '../../view_models/campaign_count_vm.dart';
import '../../view_models/chart_list_vm.dart';
import '../../view_models/lead_count_vm.dart';
import '../../view_models/templete_list_vm.dart';
import '../../view_models/whatsapp_setting_vm.dart';
import '../widgets/app_drawer_widget.dart';

// ignore: must_be_immutable
class HomeView extends StatefulWidget {
  LeadCountAgentModel? agentModel;
  Leadsmonthmodel? monthmodel;
  HomeView({Key? key, this.agentModel, this.monthmodel}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // List of items for the dropdown
  String? lastAddedId;
  Map<String, String> itemsMap = {};
  List allNums = [];
  IO.Socket? socket;
  String phNum = "+919876543210";
  String token = "your_token_here";
  var userId;
  List allWhNums = [];
  List unreadList = [];
  String? selectedWhatsAppNumber;
  UnreadCountVm? unreadCountVm;
  ChartListViewModel? leadListVM;
  LeadCountViewModel? leadCountVM;
  WhatsappSettingViewModel? whatsAppSettingVM;
  AutoResponseViewModel? autoResponseVM;
  CampaignCountViewModel? campaignVM;
  TempleteListViewModel? templateVM;
  WhatsappSettingModel? nmodel;
  CampaignChartViewModel? chartListVM;

  UnreadCountVm? unreadcountvm;

  ApprovedTemplateViewModel? approveddataVM;
  // Aprovedtempltemodeldata? modeltemplete;
  List<Datum> datatempletlist = [];
  //-------- Start code method of month chart------
  List<String?> addData = [];
  late TooltipBehavior _tooltipBehavior;
  List<_SalesData> businessData = [];
  List<Templatedata> templatedata = [];
  List<Color> areaColor = [
    AppColor.navBarIconColor,
    const Color.fromARGB(255, 205, 244, 247),
    Colors.blue,
    Colors.green
  ];

  String? countNewLeads = '';
  String? autoResponseCount = '';
  String? campaignCount = '0';
  int? templateCount;
  int? unreaddatacount;
  num totalCountofIncome = 0;
  num totalCountofExpence = 0;
  String? globalUnreadCount = "";
  List<Templatedata> Templatedat = [];

  Future<String?> getPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('selectedWhatsAppNumber');
    debug('Retrieved phone number: $phoneNumber');
    return phoneNumber;
  }

  // bool _isVisible = false;
  String selectedNumber = "";

  @override
  void initState() {
    {
      _tooltipBehavior = TooltipBehavior(enable: true);
      NotificationUtil.registerToken();
      getAvailableModules();
      getPhoneNumber();
      _getUnreadCount();
      fetch();
      // connectSocket();
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> modules = [];
  Future<void> getAvailableModules() async {
    final prefs = await SharedPreferences.getInstance();
    modules =
        prefs.getStringList(SharedPrefsConstants.userAvailableMoulesKey) ?? [];
    setState(() {});

    print("modules:::: $modules");

    if (modules.contains("Calls")) {
      String tkn = await AppUtils.getToken() ?? "";
      Map<String, dynamic> decodedToken = JwtDecoder.decode(tkn);
      userId = decodedToken;
      print("modules contains calls so we are here ::::::::  $userId");
      // CallSocketService().connect(tkn, userId);
    }
  }

  void fetch() async {
    final prefs = await SharedPreferences.getInstance();
    String? selectedWhatsAppNumber = prefs.getString('phoneNumber');
    await Provider.of<WhatsappSettingViewModel>(context, listen: false).fetch();
    print(
        "selectedWhatsAppNumber:::::::::::::::::::::::::::: $selectedWhatsAppNumber");
    if (selectedWhatsAppNumber == null || selectedWhatsAppNumber.isEmpty) {
      if (Provider.of<WhatsappSettingViewModel>(context, listen: false)
          .viewModels
          .isNotEmpty) {
        selectedWhatsAppNumber = Provider.of<WhatsappSettingViewModel>(
          context,
          listen: false,
        ).viewModels[0].model.record[0].phone;
        selectedNumber = selectedWhatsAppNumber ?? "";
        await prefs.setString('phoneNumber', selectedWhatsAppNumber ?? "");
      }
    } else {
      selectedNumber = selectedWhatsAppNumber;
    }
    print("selectedNumber:::>>>> $selectedNumber");
    // setState(() {});

    debugPrint('Selected WhatsApp Number: $selectedWhatsAppNumber');

    await Provider.of<CampaignChartViewModel>(context, listen: false)
        .fetchCampaignChart(number: selectedWhatsAppNumber);
    // Provider.of<ApprovedTemplateViewModel>(context, listen: false)
    //     .fetchTemplatechart(number: selectedWhatsAppNumber);
    await Provider.of<TempleteListViewModel>(context, listen: false)
        .templeteCountfetch(number: selectedWhatsAppNumber);
    await Provider.of<TempleteListViewModel>(context, listen: false)
        .templetefetch(number: selectedWhatsAppNumber);
    await Provider.of<CampaignCountViewModel>(context, listen: false)
        .fetchCampaignCount(number: selectedWhatsAppNumber);

    // Provider.of<ChartListViewModel>(context, listen: false).fetchLeadsMonth();
    Provider.of<LeadCountViewModel>(context, listen: false).countNewLead();
    Provider.of<AutoResponseViewModel>(context, listen: false)
        .autoResponseFetch();

    EasyLoading.dismiss();
  }

  // String? _phone;
  void whatsappSettingNumber(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Options'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: itemsMap.length,
                  itemBuilder: (context, index) {
                    String key = itemsMap.keys.elementAt(index);
                    String value = itemsMap[key]!;

                    return Column(
                      children: [
                        ListTile(
                          title: Text(value),
                          onTap: () async {
                            setState(() {
                              selectedWhatsAppNumber = key;
                            });
                            Provider.of<CampaignCountViewModel>(context,
                                    listen: false)
                                .fetchCampaignCount(
                                    number: selectedWhatsAppNumber);

                            Provider.of<TempleteListViewModel>(context,
                                    listen: false)
                                .templeteCountfetch(
                                    number: selectedWhatsAppNumber);

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(
                                'phoneNumber', selectedWhatsAppNumber ?? "");

                            Navigator.of(context).pop();
                          },
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    itemsMap = {};

    leadListVM = Provider.of<ChartListViewModel>(context);
    leadCountVM = Provider.of<LeadCountViewModel>(context);
    whatsAppSettingVM = Provider.of<WhatsappSettingViewModel>(context);
    autoResponseVM = Provider.of<AutoResponseViewModel>(context);
    campaignVM = Provider.of<CampaignCountViewModel>(context);
    templateVM = Provider.of<TempleteListViewModel>(context);
    chartListVM = Provider.of<CampaignChartViewModel>(context);
    unreadcountvm = Provider.of<UnreadCountVm>(context);
    approveddataVM = Provider.of<ApprovedTemplateViewModel>(context);
    _updateItemsMap();
    WidgetStateProperty.all(AppColor.navBarIconColor);

    for (var viewModel in leadCountVM!.viewModels) {
      NewLeadCountModel nmodel = viewModel.model;
      countNewLeads = nmodel.total;
    }

    for (var viewModel in autoResponseVM!.viewModels) {
      AutoResponseModel automodel = viewModel.model;
      autoResponseCount = automodel.total;
    }

    for (var viewModel in campaignVM!.viewModels) {
      CampaignCountModel campmodel = viewModel.model;

      var pend = campmodel.result?.pending;
      var comp = campmodel.result?.completed;
      var abort = campmodel.result?.aborted;
      var prog = campmodel.result?.inProgress;
      var allCamp = int.parse(pend!) +
          int.parse(comp!) +
          int.parse(abort!) +
          int.parse(prog!);
      campaignCount = allCamp.toString();
    }
    // print("cammma=>${campaignCount}");

    for (var viewModel in templateVM!.viewModels) {
      TemplateModel tempmodel = viewModel.model;
      templateCount = tempmodel.data?.length;
      debug('countofdata===$templateCount');
    }

    getBusinessWidgets();

    getTemplateData();

    int totalUnreadCount = 0;

    for (var viewModel in unreadcountvm!.viewModels) {
      if (viewModel.model is UnreadMsgModel) {
        UnreadMsgModel unreadvm = viewModel.model as UnreadMsgModel;
        var records = unreadvm.records ?? [];
        // print("recorcccccccccccds${records.length}");
        for (var data in records) {
          String? unreadCount = data.unreadMsgCount;

          if (unreadCount != null) {
            // int count = int.tryParse(unreadCount) ?? 0;
            setState(() {
              totalUnreadCount = records.length;
            });
          }
        }
      } else {
        print("Model is not UnreadMsgModel: ${viewModel.model.runtimeType}");
      }
    }
    return Consumer<DashBoardController>(builder: (context, ref, child) {
      return FocusDetector(
        onFocusGained: () {
          log('\x1B[95mFCM     home Screen focused again::::::::::::::::::::::::::::::::::::::::::::::::::');

          // print("Screen focused again");
          connectSocket();
        },
        onFocusLost: () {
          disconnectSocket();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          drawer: const AppDrawerWidget(),
          appBar: AppBar(
            iconTheme:
                const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
            centerTitle: true,
            elevation: 2,
            backgroundColor: AppColor.navBarIconColor,
            title: const Text(
              "Home",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
            actions: [
              IconButton(
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
                      const Icon(
                        Icons.notifications,
                        size: 28,
                      ),
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
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer,
                            padding: const EdgeInsets.all(2),
                          ),
                        ),
                    ],
                  )),
              PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                icon: const Icon(Icons.phone, size: 23, color: Colors.white),
                itemBuilder: (BuildContext context) {
                  return allNums.map((number) {
                    final isSelected = number.phone == selectedNumber;
                    return PopupMenuItem<String>(
                      value: number.phone,
                      child: Text(
                        "${number.name} ${number.phone} ",
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                    );
                  }).toList();
                },
                onSelected: (value) async {
                  print('Selected: $value');
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('phoneNumber', value);

                  EasyLoading.showToast("$value marked as selected",
                      toastPosition: EasyLoadingToastPosition.bottom);
                  selectedNumber = value;
                  EasyLoading.show();
                  fetch();

                  setState(() {});
                },
              ),
            ],
          ),
          body: res.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 60),
                  child: Center(
                      child: Text(
                    res,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: AppFonts.semiBold,
                        color: Colors.redAccent,
                        fontSize: 18),
                  )),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Padding(

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            HomePageCard(
                              title: "All Leads",
                              subtitle:
                                  "${(countNewLeads ?? 0).toString()} / Total",
                              icon: Icons.leaderboard_rounded,
                              polygonAsset: "assets/images/home_polygon.png",
                              tap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LeadListView()));
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            HomePageCard(
                              title: "All Campaigns",
                              subtitle:
                                  "${(campaignCount ?? 0).toString()} / Total",
                              icon: Icons.leaderboard_rounded,
                              polygonAsset: "assets/images/home_polygon.png",
                              tap: () {
                                if (modules.contains("Campaign") ||
                                    modules.contains('Campaigns')) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CampaignListView()));
                                } else {
                                  EasyLoading.showToast(
                                      "Access to Campaign is not included in this Plan");
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            HomePageCard(
                              title: "Total Templates",
                              subtitle:
                                  "${(templateCount ?? 0).toString()} / Total",
                              icon: Icons.leaderboard_rounded,
                              polygonAsset: "assets/images/home_polygon.png",
                              tap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const TempleteListView()));
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            HomePageCard(
                              title: "Auto Message",
                              subtitle: "${autoResponseCount ?? ""} / Total",
                              icon: Icons.leaderboard_rounded,
                              polygonAsset: "assets/images/home_polygon.png",
                              tap: () {},
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            modules.contains("Campaign")
                                ? campaignCount != "0"
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.12),
                                              blurRadius: 6,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              'Campaign',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            SfCircularChart(
                                                tooltipBehavior:
                                                    _tooltipBehavior,
                                                legend: const Legend(
                                                    isVisible: true,
                                                    position:
                                                        LegendPosition.top,
                                                    overflowMode:
                                                        LegendItemOverflowMode
                                                            .wrap),
                                                series: <PieSeries<_SalesData,
                                                    String>>[
                                                  PieSeries<_SalesData, String>(
                                                      legendIconType:
                                                          LegendIconType.circle,
                                                      radius: '100',
                                                      dataSource: businessData,
                                                      enableTooltip: true,
                                                      pointColorMapper:
                                                          (_SalesData sales,
                                                                  int index) =>
                                                              areaColor[index %
                                                                  areaColor
                                                                      .length],
                                                      xValueMapper:
                                                          (_SalesData sales,
                                                                  _) =>
                                                              sales.status,
                                                      yValueMapper:
                                                          (_SalesData sales,
                                                                  _) =>
                                                              sales.count)
                                                ]),
                                          ],
                                        ),
                                      )
                                    : const SizedBox()
                                : const SizedBox(),
                            const SizedBox(
                              height: 20,
                            ),
                            templatedata.isEmpty
                                ? const SizedBox()
                                : Container(
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
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Text(
                                          'Template',
                                          style: TextStyle(
                                            color: Colors.black,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: AppFonts.semiBold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SfCircularChart(
                                            tooltipBehavior: _tooltipBehavior,
                                            legend: const Legend(
                                                isVisible: true,
                                                position: LegendPosition.top,
                                                overflowMode:
                                                    LegendItemOverflowMode
                                                        .wrap),
                                            series: <DoughnutSeries<
                                                Templatedata, String>>[
                                              DoughnutSeries<Templatedata,
                                                      String>(
                                                  radius: '100',
                                                  dataSource: templatedata,
                                                  enableTooltip: true,
                                                  pointColorMapper:
                                                      (Templatedata sales,
                                                              int index) =>
                                                          areaColor[index %
                                                              areaColor.length],
                                                  xValueMapper:
                                                      (Templatedata sales, _) =>
                                                          sales.status,
                                                  yValueMapper:
                                                      (Templatedata sales, _) =>
                                                          sales.count)
                                            ]),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }

  void getTemplateData() {
    Map<String, int> categoryCount = {};
    templatedata.clear();

    for (var viewModel in templateVM!.viewModels) {
      // print("working....");

      if (viewModel.model is TemplateModel) {
        TemplateModel templateModel = viewModel.model as TemplateModel;
        // print("Working haiiii...");

        if (templateModel.data != null) {
          for (var entry in templateModel.data!) {
            String? templateCategory = entry.category;
            if (categoryCount.containsKey(templateCategory)) {
              categoryCount[templateCategory!] =
                  categoryCount[templateCategory]! + 1;
            } else {
              categoryCount[templateCategory!] = 1;
            }
          }
        }
      } else {
        debugPrint("erorr : ${viewModel.model.runtimeType}");
      }

      categoryCount.forEach((category, count) {
        templatedata.add(Templatedata(category, count));
        // print("category name: $category, count: $count");
      });
    }
  }

  void getBusinessWidgets() {
    businessData.clear();

    for (var viewModel in chartListVM!.viewModels) {
      if (viewModel.model is CampaignChartModel) {
        CampaignChartModel countagent = viewModel.model as CampaignChartModel;
        if (countagent.result != null) {
          int completed = int.parse(countagent.result?.completed ?? "0");
          int pending = int.parse(countagent.result?.pending ?? "0");
          int inProgress = int.parse(countagent.result?.inProgress ?? "0");
          int aborted = int.parse(countagent.result?.aborted ?? "0");

          businessData.add(_SalesData("Pending", pending));
          businessData.add(_SalesData("In Progress", inProgress));
          businessData.add(_SalesData("Completed", completed));
          businessData.add(_SalesData("Aborted", aborted));
        }
      } else {
        debugPrint("Unexpected model type: ${viewModel.model.runtimeType}");
      }
    }
  }

  void _updateItemsMap() {
    itemsMap.clear();
    allNums = [];
    print(
        "whatsAppSettingVM!.viewModels:::   ${whatsAppSettingVM!.viewModels}");
    for (var viewModel in whatsAppSettingVM!.viewModels) {
      var nmodel = viewModel.model;
      print("nmodel::::    $viewModel");
      if (nmodel != null) {
        for (var record in nmodel?.record ?? []) {
          allNums.add(record);
          allWhNums.add("${record.name} ${record.phone}");
          itemsMap[record.phone] = "${record.name} ${record.phone}";
        }
      }
    }
    print("itemsMap::: $itemsMap   $allNums");
  }

  Future<void> connectSocket() async {
    log("connecting to socket::::::::::::::::::::::::::::::::: ");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    String tkn = await AppUtils.getToken() ?? "";
    Map<String, dynamic> decodedToken = JwtDecoder.decode(tkn);

    token = tkn;
    phNum = number ?? "";
    userId = decodedToken;

    try {
      // print("Token: $token");

      socket = IO.io(
        'https://sandbox.watconnect.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/swp/socket.io')
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );
      socket!.connect();
      socket!.onConnect((_) {
        print('Connected to WebSocket on home');
        socket!.emit("setup", userId);
      });
      socket!.on("connected", (_) {
        // print(" WebSocket setup complete");
      });

      socket!.on("receivedwhatsappmessage", (data) {
        print(" New WhatsApp message: $data");
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

  var res = "";
  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    var number = prefs.getString('phoneNumber');

    if (!mounted) return;
    res =
        await Provider.of<LeadListViewModel>(context, listen: false).fetch() ??
            "";
    print("res:::::::::::  $res");
    await Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number ?? "");

    var unreadMsgModel;
    for (var unreadModel in unreadCountVm?.viewModels ?? []) {
      unreadMsgModel = unreadModel.model as UnreadMsgModel;
    }
    if (unreadMsgModel != null) {
      unreadList = unreadMsgModel.records ?? [];
    }

    setState(() {});
  }

  void disconnectSocket() {
    if (socket != null) {
      socket!.disconnect();
      print(" WebSocket Disconnected on home");
    }
  }

  void getSfCampWidgets() {
    DashBoardController dbController = Provider.of(context, listen: false);
    businessData.clear();
    businessData
        .add(_SalesData("Pending", dbController.campStatus?.pending ?? 0));
    businessData.add(
        _SalesData("In Progress", dbController.campStatus?.inProgress ?? 0));
    businessData
        .add(_SalesData("Completed", dbController.campStatus?.completed ?? 0));
  }

  void getSfTemplateData() {
    DashBoardController dbController = Provider.of(context, listen: false);
    templatedata.clear();
    templatedata
        .add(Templatedata("Pending", dbController.tempStatus?.pending ?? 0));
    templatedata.add(
        Templatedata("In Progress", dbController.tempStatus?.pending ?? 0));
    templatedata
        .add(Templatedata("Approved", dbController.tempStatus?.approved ?? 0));
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
