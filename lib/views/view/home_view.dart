import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as badges;

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/datum.dart';
import 'package:whatsapp/view_models/approved_template_vm.dart';

import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/views/view/NotificationPage.dart';
import 'package:whatsapp/views/view/campaign_list_view.dart';
import 'package:whatsapp/views/view/lead_list_view.dart';
import 'package:whatsapp/views/view/templete_list_view.dart';

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
  String? selectedWhatsAppNumber;
  UnreadCountVm? unreadCountVm;
  // ignore: prefer_typing_uninitialized_variables
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

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);

    getPhoneNumber();
    fetch();
    super.initState();
  }

  void fetch() async {
    final prefs = await SharedPreferences.getInstance();
    String? selectedWhatsAppNumber = prefs.getString('phoneNumber');

    if (selectedWhatsAppNumber == null || selectedWhatsAppNumber.isEmpty) {
      await Provider.of<WhatsappSettingViewModel>(context, listen: false)
          .fetch();

      if (Provider.of<WhatsappSettingViewModel>(context, listen: false)
          .viewModels
          .isNotEmpty) {
        selectedWhatsAppNumber = Provider.of<WhatsappSettingViewModel>(
          context,
          listen: false,
        ).viewModels[0].model.record[0].phone;

        await prefs.setString('phoneNumber', selectedWhatsAppNumber ?? "");
      }
    }

    debugPrint('Selected WhatsApp Number: $selectedWhatsAppNumber');

    Provider.of<CampaignChartViewModel>(context, listen: false)
        .fetchCampaignChart(number: selectedWhatsAppNumber);
    // Provider.of<ApprovedTemplateViewModel>(context, listen: false)
    //     .fetchTemplatechart(number: selectedWhatsAppNumber);
    Provider.of<TempleteListViewModel>(context, listen: false)
        .templeteCountfetch(number: selectedWhatsAppNumber);
    Provider.of<TempleteListViewModel>(context, listen: false)
        .templetefetch(number: selectedWhatsAppNumber);
    Provider.of<CampaignCountViewModel>(context, listen: false)
        .fetchCampaignCount(number: selectedWhatsAppNumber);

    Provider.of<ChartListViewModel>(context, listen: false).fetchLeadsMonth();
    Provider.of<LeadCountViewModel>(context, listen: false).countNewLead();
    Provider.of<AutoResponseViewModel>(context, listen: false)
        .autoResponseFetch();
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
      campaignCount = campmodel.result?.pending;
    }
    print("cammma=>${campaignCount}");

    // for (var viewModel in templateVM!.viewModels) {
    //   TemplateModel tempmodel = viewModel.model;
    //   templateCount = tempmodel.data?.length;
    //   debug('countofdata===$templateCount');
    // }

    getBusinessWidgets();
    getTemplateData();

    int totalUnreadCount = 0;
    // for (var viewModel in unreadcountvm!.viewModels) {
    //   UnreadMsgModel unreadvm = viewModel.model;
    //   var records = unreadvm.records;

    //   if (records != null) {
    //     print("Records : $records");

    //     for (var data in records) {
    //       print("dattat: $data");

    //       var unreadCount = data.unreadMsgCount;

    //       if (unreadCount != null) {
    //         print("unrnnrnr$unreadCount");
    //         int count = int.tryParse(unreadCount) ?? 0;
    //         setState(() {
    //           totalUnreadCount += count;
    //         });
    //       }
    //     }
    //   } else {
    //     print("No records found.");
    //   }
    // }

    // int totalUnreadCount = 0;
    for (var viewModel in unreadcountvm!.viewModels) {
      if (viewModel.model is UnreadMsgModel) {
        UnreadMsgModel unreadvm = viewModel.model as UnreadMsgModel;
        var records = unreadvm.records;

        if (records != null) {
          for (var data in records) {
            String? unreadCount = data.unreadMsgCount;

            if (unreadCount != null) {
              // Safely convert String to int
              int count = int.tryParse(unreadCount) ?? 0;
              setState(() {
                totalUnreadCount += count;
              });
            }
          }
        } else {
          print("No records found.");
        }
      } else {
        print("Model is not UnreadMsgModel: ${viewModel.model.runtimeType}");
      }
    }

    return Scaffold(
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
                    builder: (context) => const NotificationPage()),
              );
            },
            icon: badges.Badge(
              isLabelVisible: true,
              label: Text(
                totalUnreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor:
                  Theme.of(context).colorScheme.onTertiaryContainer,
              child: const Icon(
                Icons.notifications,
                size: 22,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LeadListView()))
                    },
                    child: Card(
                      elevation: 2,
                      color: const Color(0xFFF6EDE8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: const DecorationImage(
                            image: AssetImage("assets/images/bg011.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.leaderboard,
                              size: 30,
                              color: Colors.white,
                            ),
                            Container(height: 5),
                            const Text(
                              "ALL Leads",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: countNewLeads
                                        .toString(), // Default text
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: '/ Total',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CampaignListView()))
                    },
                    child: Card(
                      elevation: 2,
                      color: const Color(0xfffece9f2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: const DecorationImage(
                            image: AssetImage(
                              "assets/images/bg011.jpg",
                            ), // Add your image path
                            fit: BoxFit.cover, // Cover entire card
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.assignment_ind,
                              size: 30,
                              color: Colors.white,
                            ),
                            Container(height: 5),
                            const Text(
                              "Pending Campa..",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: campaignCount
                                        .toString(), // Default text
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: '/ Total',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TempleteListView()))
                    },
                    child: Card(
                      elevation: 2,
                      color: const Color(0xfffece9f2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: const DecorationImage(
                            image: AssetImage(
                              "assets/images/bg011.jpg",
                            ), // Add your image path
                            fit: BoxFit.cover, // Cover entire card
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.assignment,
                              size: 30,
                              color: Colors.white,
                            ),
                            Container(height: 5),
                            const Text(
                              "Total Templates",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: templateCount
                                        .toString(), // Default text
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: '/ Total',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 2,
                    color: const Color(0xFFF6EDE8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: const DecorationImage(
                          image: AssetImage(
                            "assets/images/bg011.jpg",
                          ), // Add your image path
                          fit: BoxFit.cover, // Cover entire card
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.message,
                            size: 30,
                            // color: Colors.white,
                            color: Colors.white,
                          ),
                          Container(height: 5),
                          const Text(
                            "Auto Message",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: autoResponseCount ?? "",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: '/ Total',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                // height: 5/00,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColor.navBarIconColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      // width: 400,
                      height: 50,
                      child: const Center(
                        child: Text(
                          'Campaign',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SfCircularChart(
                        tooltipBehavior: _tooltipBehavior,
                        legend: const Legend(
                            isVisible: true,
                            position: LegendPosition.top,
                            overflowMode: LegendItemOverflowMode.wrap),
                        series: <PieSeries<_SalesData, String>>[
                          PieSeries<_SalesData, String>(
                              legendIconType: LegendIconType.circle,
                              radius: '100',
                              dataSource: businessData,
                              enableTooltip: true,
                              pointColorMapper: (_SalesData sales, int index) =>
                                  areaColor[index % areaColor.length],
                              xValueMapper: (_SalesData sales, _) =>
                                  sales.status,
                              yValueMapper: (_SalesData sales, _) =>
                                  sales.count)
                        ]),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColor.navBarIconColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      // width: 400,
                      height: 50,
                      child: const Center(
                        child: Text(
                          'Template',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SfCircularChart(
                        tooltipBehavior: _tooltipBehavior,
                        legend: const Legend(
                            isVisible: true,
                            position: LegendPosition.top,
                            overflowMode: LegendItemOverflowMode.wrap),
                        series: <DoughnutSeries<Templatedata, String>>[
                          DoughnutSeries<Templatedata, String>(
                              radius: '100',
                              dataSource: templatedata,
                              enableTooltip: true,
                              pointColorMapper:
                                  (Templatedata sales, int index) =>
                                      areaColor[index % areaColor.length],
                              xValueMapper: (Templatedata sales, _) =>
                                  sales.status,
                              yValueMapper: (Templatedata sales, _) =>
                                  sales.count)
                        ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: FooterNavbarPage(),

      // bottomNavigationBar: const FooterNavbarPage(),
    );
  }

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFF00A1E4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  void getTemplateData() {
    Map<String, int> categoryCount = {};
    templatedata.clear();

    for (var viewModel in templateVM!.viewModels) {
      print("working....");

      if (viewModel.model is TemplateModel) {
        TemplateModel templateModel = viewModel.model as TemplateModel;
        print("Working haiiii...");

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
        print("category name: $category, count: $count");
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
  // final String status;
  // final int count;
}
