// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'dart:convert';
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

// ignore: must_be_immutable
class HomeView extends StatefulWidget {
  LeadCountAgentModel? agentModel;
  Leadsmonthmodel? monthmodel;
  HomeView({Key? key, this.agentModel, this.monthmodel}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? lastAddedId;
  Map<String, String> itemsMap = {};
  List allNums = [];
  IO.Socket? socket;
  String phNum = "+919876543210";
  String token = "your_token_here";
  Map<String, dynamic> userId = {};
  List allWhNums = [];
  List unreadList = [];
  String? selectedWhatsAppNumber;

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

  bool _isInitialized = false;
  bool _isLoading = false;

  Future<String?> getPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('selectedWhatsAppNumber');
    debug('Retrieved phone number: $phoneNumber');
    return phoneNumber;
  }

  String selectedNumber = "";

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    NotificationUtil.registerToken();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    _isLoading = true;
    await getAvailableModules();
    await getPhoneNumber();
    await _fetchInitialData();
    _isInitialized = true;
    _isLoading = false;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }

  List<String> modules = [];
  Future<void> getAvailableModules() async {
    final prefs = await SharedPreferences.getInstance();
    modules =
        prefs.getStringList(SharedPrefsConstants.userAvailableMoulesKey) ?? [];
    print("modules:::: $modules");
  }

  Future<void> _fetchInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? selectedWhatsAppNumber = prefs.getString('phoneNumber');

      await Provider.of<WhatsappSettingViewModel>(context, listen: false)
          .fetch();

      final whatsAppVM =
          Provider.of<WhatsappSettingViewModel>(context, listen: false);
      if (selectedWhatsAppNumber == null || selectedWhatsAppNumber.isEmpty) {
        if (whatsAppVM.viewModels.isNotEmpty) {
          selectedWhatsAppNumber =
              whatsAppVM.viewModels[0].model.record[0].phone;
          selectedNumber = selectedWhatsAppNumber ?? "";
          await prefs.setString('phoneNumber', selectedWhatsAppNumber ?? "");
        }
      } else {
        selectedNumber = selectedWhatsAppNumber;
      }

      debugPrint('Selected WhatsApp Number: $selectedWhatsAppNumber');

      await Future.wait([
        Provider.of<CampaignChartViewModel>(context, listen: false)
            .fetchCampaignChart(number: selectedWhatsAppNumber),
        Provider.of<TempleteListViewModel>(context, listen: false)
            .templeteCountfetch(number: selectedWhatsAppNumber),
        Provider.of<TempleteListViewModel>(context, listen: false)
            .templetefetch(number: selectedWhatsAppNumber),
        Provider.of<CampaignCountViewModel>(context, listen: false)
            .fetchCampaignCount(number: selectedWhatsAppNumber),
        Provider.of<LeadCountViewModel>(context, listen: false).countNewLead(),
        Provider.of<AutoResponseViewModel>(context, listen: false)
            .autoResponseFetch(),
        _getUnreadCount(),
      ] as Iterable<Future>);
    } catch (e) {
      print('Error in _fetchInitialData: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _updateItemsMap(WhatsappSettingViewModel whatsAppSettingVM) {
    LeadController leadController = Provider.of(context, listen: false);
    itemsMap.clear();
    leadController.clearAllBusNums();
    allNums = [];

    for (var viewModel in whatsAppSettingVM.viewModels) {
      var nmodel = viewModel.model;
      if (nmodel != null) {
        for (var record in nmodel.record ?? []) {
          allNums.add(record);
          leadController.setAllBusNums(record.phone);
          allWhNums.add("${record.name} ${record.phone}");
          itemsMap[record.phone] = "${record.name} ${record.phone}";
        }
      }
    }

    print("all business numbers::::  ${leadController.allBusinessNumbers}");
  }

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
                              _isLoading = true;
                            });

                            await _refreshDataWithNewNumber(key);

                            setState(() {
                              _isLoading = false;
                            });

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

  Future<void> _refreshDataWithNewNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', number);

    await Future.wait([
      Provider.of<CampaignCountViewModel>(context, listen: false)
          .fetchCampaignCount(number: number),
      Provider.of<TempleteListViewModel>(context, listen: false)
          .templeteCountfetch(number: number),
      Provider.of<CampaignChartViewModel>(context, listen: false)
          .fetchCampaignChart(number: number),
    ]);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WhatsappSettingViewModel>(
      builder: (context, whatsAppSettingVM, child) {
        _updateItemsMap(whatsAppSettingVM);

        return Consumer<DashBoardController>(
          builder: (context, ref, child) {
            return _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FocusDetector(
                    onFocusGained: () {
                      log('Home Screen focused again');
                      connectSocket();
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
                          _buildPhoneMenu(whatsAppSettingVM),
                        ],
                      ),
                      body: _buildBody(),
                    ),
                  );
          },
        );
      },
    );
  }

  Widget _buildNotificationIcon() {
    return Consumer<UnreadCountVm>(
      builder: (context, unreadCountVm, child) {
        int totalUnreadCount = _calculateUnreadCount(unreadCountVm);

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

  Widget _buildPhoneMenu(WhatsappSettingViewModel whatsAppSettingVM) {
    return PopupMenuButton<String>(
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          );
        }).toList();
      },
      onSelected: (value) async {
        print('Selected: $value');
        setState(() {
          _isLoading = true;
        });

        await _refreshDataWithNewNumber(value);

        setState(() {
          _isLoading = false;
        });

        EasyLoading.showToast("$value marked as selected",
            toastPosition: EasyLoadingToastPosition.bottom);
      },
    );
  }

  Widget _buildBody() {
    return Consumer<LeadCountViewModel>(
      builder: (context, leadCountVM, child) {
        return Consumer<AutoResponseViewModel>(
          builder: (context, autoResponseVM, child) {
            return Consumer<CampaignCountViewModel>(
              builder: (context, campaignVM, child) {
                return Consumer<TempleteListViewModel>(
                  builder: (context, templateVM, child) {
                    return Consumer<CampaignChartViewModel>(
                      builder: (context, chartListVM, child) {
                        _calculateValues(leadCountVM, autoResponseVM,
                            campaignVM, templateVM);
                        _getBusinessWidgets(chartListVM);
                        _getTemplateData(templateVM);

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              _buildTopCards(),
                              const SizedBox(height: 20),
                              _buildCharts(chartListVM, templateVM),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTopCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          HomePageCard(
            title: "All Leads",
            subtitle: "${(countNewLeads ?? 0).toString()} / Total",
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
            subtitle: "${(campaignCount ?? 0).toString()} / Total",
            icon: Icons.leaderboard_rounded,
            polygonAsset: "assets/images/home_polygon.png",
            tap: () {
              if (modules.contains("Campaign") ||
                  modules.contains('Campaigns')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CampaignListView()),
                );
              } else {
                EasyLoading.showToast(
                    "Access to Campaign is not included in this Plan");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCharts(
      CampaignChartViewModel chartListVM, TempleteListViewModel templateVM) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          if (modules.contains("Campaign") && campaignCount != "0")
            _buildCampaignChart(chartListVM),
          if (modules.contains("Campaign") && campaignCount != "0")
            const SizedBox(height: 20),
          if (templatedata.isNotEmpty) _buildTemplateChart(templateVM),
        ],
      ),
    );
  }

  Widget _buildCampaignChart(CampaignChartViewModel chartListVM) {
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
                dataSource: businessData,
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

  Widget _buildTemplateChart(TempleteListViewModel templateVM) {
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
                dataSource: templatedata,
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

  void _calculateValues(
    LeadCountViewModel leadCountVM,
    AutoResponseViewModel autoResponseVM,
    CampaignCountViewModel campaignVM,
    TempleteListViewModel templateVM,
  ) {
    for (var viewModel in leadCountVM.viewModels) {
      NewLeadCountModel nmodel = viewModel.model;
      countNewLeads = nmodel.total;
    }

    for (var viewModel in autoResponseVM.viewModels) {
      AutoResponseModel automodel = viewModel.model;
      autoResponseCount = automodel.total;
    }

    for (var viewModel in campaignVM.viewModels) {
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

    for (var viewModel in templateVM.viewModels) {
      TemplateModel tempmodel = viewModel.model;
      templateCount = tempmodel.data?.length;
    }
  }

  int _calculateUnreadCount(UnreadCountVm unreadCountVm) {
    int totalUnreadCount = 0;
    for (var viewModel in unreadCountVm.viewModels) {
      if (viewModel.model is UnreadMsgModel) {
        UnreadMsgModel unreadvm = viewModel.model as UnreadMsgModel;
        var records = unreadvm.records ?? [];
        totalUnreadCount = records.length;
      }
    }
    return totalUnreadCount;
  }

  void _getTemplateData(TempleteListViewModel templateVM) {
    Map<String, int> categoryCount = {};
    templatedata.clear();

    for (var viewModel in templateVM.viewModels) {
      if (viewModel.model is TemplateModel) {
        TemplateModel templateModel = viewModel.model as TemplateModel;
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
      }
    }

    categoryCount.forEach((category, count) {
      templatedata.add(Templatedata(category, count));
    });
  }

  void _getBusinessWidgets(CampaignChartViewModel chartListVM) {
    businessData.clear();

    for (var viewModel in chartListVM.viewModels) {
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
      }
    }
  }

  Future<void> connectSocket() async {
    log("connecting to socket::::::::::::::::::::::::::::::::: ");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    LeadController leadCtrl = Provider.of(context, listen: false);
    String tkn = await AppUtils.getToken() ?? "";
    Map<String, dynamic> decodedToken = Map<String, dynamic>.from(
      JwtDecoder.decode(tkn),
    );

    token = tkn;
    phNum = number ?? "";
    userId = decodedToken;

    userId.addAll({
      "business_numbers": leadCtrl.allBusinessNumbers,
      "business_number": number
    });

    log("user id sending in socket setup::::   $userId");

    try {
      socket = IO.io(
        'https://admin.watconnect.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/ibs/socket.io')
            .setExtraHeaders({'Authorization': 'Bearer $token'})
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

  var res = "";
  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    var number = prefs.getString('phoneNumber');

    if (!mounted) return;

    await Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number ?? "");

    if (mounted) {
      setState(() {});
    }
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
