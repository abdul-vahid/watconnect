import 'dart:developer';

import 'package:focus_detector/focus_detector.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as badges;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/datum.dart';
import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/model/business_number_model.dart';
import 'package:whatsapp/salesforce/screens/confige_listing_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_campaign_listing_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_darwer.dart';
import 'package:whatsapp/salesforce/widget/sf_dashboard_card.dart';
import 'package:whatsapp/utils/app_constants.dart';
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

class _HomeViewState extends State<HomeView> with RouteAware {
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

  bool _isVisible = false;
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
    // disconnectSocket();
    // routeObserver.unsubscribe(this);
    super.dispose();
  }

  // @override
  // void dispose() {
  //   routeObserver.unsubscribe(this);
  //   disconnectSocket();
  //   super.dispose();
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   final route = ModalRoute.of(context);
  //   if (route is PageRoute) {
  //     routeObserver.subscribe(this, route);
  //     print(" Subscribed to RouteObserver in HomeView");
  //   }
  // }

  // @override
  // void didPush() {
  //   super.didPush();
  //   print(" didPush - HomeView is now visible");
  //   _onHomeVisible();
  // }

  /// Called when HomeView comes back to top after popping another screen
  // @override
  // void didPopNext() {
  //   super.didPopNext();
  //   print("didPopNext - Back to HomeView");
  //   _onHomeVisible();
  // }

  /// Called when navigating away from HomeView

  List<String> modules = [];
  Future<void> getAvailableModules() async {
    final prefs = await SharedPreferences.getInstance();
    modules = await prefs
            .getStringList(SharedPrefsConstants.userAvailableMoulesKey) ??
        [];
    setState(() {});

    print("modules:::: ${modules}");
  }

  void fetch() async {
    final prefs = await SharedPreferences.getInstance();
    String? selectedWhatsAppNumber = prefs.getString('phoneNumber');
    await Provider.of<WhatsappSettingViewModel>(context, listen: false).fetch();
    print(
        "selectedWhatsAppNumber:::::::::::::::::::::::::::: ${selectedWhatsAppNumber}");
    if (selectedWhatsAppNumber == null || selectedWhatsAppNumber!.isEmpty) {
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
      selectedNumber = selectedWhatsAppNumber!;
    }
    print("selectedNumber:::>>>> ${selectedNumber}");
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

    Provider.of<ChartListViewModel>(context, listen: false).fetchLeadsMonth();
    Provider.of<LeadCountViewModel>(context, listen: false).countNewLead();
    Provider.of<AutoResponseViewModel>(context, listen: false)
        .autoResponseFetch();

    EasyLoading.dismiss();
  }

  String? _phone;
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
      campaignCount = campmodel.result?.pending;
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
            int count = int.tryParse(unreadCount) ?? 0;
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
          drawer: AppDrawerWidget(),
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

                  EasyLoading.showToast("${value} marked as selected",
                      toastPosition: EasyLoadingToastPosition.bottom);
                  selectedNumber = value;
                  EasyLoading.show();
                  fetch();

                  setState(() {});
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 12),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
                //   child: AppUtils.getDropdown(
                //     'Select',
                //     data: allWhNums,
                //     onChanged: (p0) {
                //       setState(() {
                //         _phone = p0;
                //         // _userType = null;
                //       });
                //     },
                //     value: _phone,
                //     validator: (value) => value == null ? 'Role is required' : null,
                //   ),
                // ),
                // Container(
                //   width: 300,
                //   child: AppUtils.getDropdown(
                //     'Select Category',
                //     data: dropdownItems,
                //     onChanged: (String? selectedCategory) {},
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Wrap(
                //     spacing: 8.0,
                //     runSpacing: 8.0,
                //     alignment: WrapAlignment.start,
                //     children: [
                //       GestureDetector(
                //         onTap: () => {
                //           Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) => const LeadListView()))
                //         },
                //         child: Card(
                //           elevation: 2,
                //           color: const Color(0xFFF6EDE8),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(15),
                //           ),
                //           child: Container(
                //             width: 160,
                //             padding: const EdgeInsets.all(16),
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(15),
                //               image: const DecorationImage(
                //                 image: AssetImage("assets/images/bg011.jpg"),
                //                 fit: BoxFit.cover,
                //               ),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 const Icon(
                //                   Icons.leaderboard,
                //                   size: 30,
                //                   color: Colors.white,
                //                 ),
                //                 Container(height: 5),
                //                 const Text(
                //                   "ALL Leads",
                //                   style: TextStyle(
                //                     color: Colors.white,
                //                     fontSize: 14,
                //                     fontWeight: FontWeight.w700,
                //                   ),
                //                 ),
                //                 Row(
                //                   children: [
                //                     RichText(
                //                       text: TextSpan(
                //                         text: (countNewLeads ?? 0).toString(),
                //                         style: const TextStyle(
                //                           color: Colors.white,
                //                           fontSize: 30,
                //                           fontWeight: FontWeight.w600,
                //                         ),
                //                         children: const [
                //                           TextSpan(
                //                             text: '/ Total',
                //                             style: TextStyle(
                //                               color: Colors.white,
                //                               fontWeight: FontWeight.bold,
                //                               fontSize: 14,
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //       GestureDetector(
                //         onTap: () => {
                //           if (modules.contains("Campaign") ||
                //               modules.contains('Campaigns'))
                //             {
                //               Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                       builder: (context) =>
                //                           const CampaignListView()))
                //             }
                //           else
                //             {
                //               EasyLoading.showToast(
                //                   "Access to Campaign is not included in this Plan")
                //             }
                //         },
                //         child: Card(
                //           elevation: 2,
                //           color: const Color(0xfffece9f2),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(15),
                //           ),
                //           child: Container(
                //             width: 160,
                //             padding: const EdgeInsets.all(16),
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(15),
                //               image: const DecorationImage(
                //                 image: AssetImage(
                //                   "assets/images/bg011.jpg",
                //                 ), // Add your image path
                //                 fit: BoxFit.cover, // Cover entire card
                //               ),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 const Icon(
                //                   Icons.assignment_ind,
                //                   size: 30,
                //                   color: Colors.white,
                //                 ),
                //                 Container(height: 5),
                //                 const Text(
                //                   "Pending Campa..",
                //                   style: TextStyle(
                //                     color: Colors.white,
                //                     fontSize: 14,
                //                     fontWeight: FontWeight.w600,
                //                   ),
                //                 ),
                //                 Row(
                //                   children: [
                //                     RichText(
                //                       text: TextSpan(
                //                         text: (campaignCount ?? 0)
                //                             .toString(), // Default text
                //                         style: const TextStyle(
                //                           color: Colors.white,
                //                           fontSize: 30,
                //                           fontWeight: FontWeight.w600,
                //                         ),
                //                         children: const [
                //                           TextSpan(
                //                             text: '/ Total',
                //                             style: TextStyle(
                //                               color: Colors.white,
                //                               fontWeight: FontWeight.bold,
                //                               fontSize: 14,
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //       GestureDetector(
                //         onTap: () => {
                //           Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) =>
                //                       const TempleteListView()))
                //         },
                //         child: Card(
                //           elevation: 2,
                //           color: const Color(0xfffece9f2),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(15),
                //           ),
                //           child: Container(
                //             width: 160,
                //             padding: const EdgeInsets.all(16),
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(15),
                //               image: const DecorationImage(
                //                 image: AssetImage(
                //                   "assets/images/bg011.jpg",
                //                 ), // Add your image path
                //                 fit: BoxFit.cover, // Cover entire card
                //               ),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 const Icon(
                //                   Icons.assignment,
                //                   size: 30,
                //                   color: Colors.white,
                //                 ),
                //                 Container(height: 5),
                //                 const Text(
                //                   "Total Templates",
                //                   style: TextStyle(
                //                     color: Colors.white,
                //                     fontSize: 14,
                //                     fontWeight: FontWeight.w600,
                //                   ),
                //                 ),
                //                 Row(
                //                   children: [
                //                     RichText(
                //                       text: TextSpan(
                //                         text: (templateCount ?? 0).toString(),
                //                         style: const TextStyle(
                //                           color: Colors.white,
                //                           fontSize: 30,
                //                           fontWeight: FontWeight.w600,
                //                         ),
                //                         children: const [
                //                           TextSpan(
                //                             text: '/ Total',
                //                             style: TextStyle(
                //                               color: Colors.white,
                //                               fontWeight: FontWeight.bold,
                //                               fontSize: 14,
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //       Card(
                //         elevation: 2,
                //         color: const Color(0xFFF6EDE8),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(15),
                //         ),
                //         child: Container(
                //           width: 160,
                //           padding: const EdgeInsets.all(16),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(15),
                //             image: const DecorationImage(
                //               image: AssetImage(
                //                 "assets/images/bg011.jpg",
                //               ), // Add your image path
                //               fit: BoxFit.cover, // Cover entire card
                //             ),
                //           ),
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               const Icon(
                //                 Icons.message,
                //                 size: 30,
                //                 // color: Colors.white,
                //                 color: Colors.white,
                //               ),
                //               Container(height: 5),
                //               const Text(
                //                 "Auto Message",
                //                 style: TextStyle(
                //                   color: Colors.white,
                //                   fontSize: 14,
                //                   fontWeight: FontWeight.w600,
                //                 ),
                //               ),
                //               Row(
                //                 children: [
                //                   RichText(
                //                     text: TextSpan(
                //                       text: autoResponseCount ?? "",
                //                       style: const TextStyle(
                //                         color: Colors.white,
                //                         fontSize: 30,
                //                         fontWeight: FontWeight.w600,
                //                       ),
                //                       children: const [
                //                         TextSpan(
                //                           text: '/ Total',
                //                           style: TextStyle(
                //                             color: Colors.white,
                //                             fontWeight: FontWeight.bold,
                //                             fontSize: 14,
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
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
                              MaterialPageRoute(
                                  builder: (context) => const LeadListView()));
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      HomePageCard(
                        title: "Pending Campa..",
                        subtitle: "${(campaignCount ?? 0).toString()} / Total",
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
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      HomePageCard(
                        title: "Total Templates",
                        subtitle: "${(templateCount ?? 0).toString()} / Total",
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
                      // modules.contains("Campaign")
                      //     ? campaignCount != "0"
                      //         ? Container(
                      //             decoration: const BoxDecoration(
                      //               color: AppColor.navBarIconColor,
                      //               borderRadius: BorderRadius.all(
                      //                 Radius.circular(10),
                      //               ),
                      //             ),
                      //             // width: 400,
                      //             height: 50,
                      //             child: const Center(
                      //               child: Text(
                      //                 'Campaign',
                      //                 style: TextStyle(
                      //                   color: Color.fromARGB(
                      //                       255, 255, 255, 255),
                      //                   fontSize: 18,
                      //                 ),
                      //               ),
                      //             ),
                      //           )
                      //         : SizedBox()
                      //     : SizedBox(),
                      modules.contains("Campaign")
                          ? campaignCount != "0"
                              ? Container(
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
                                              overflowMode:
                                                  LegendItemOverflowMode.wrap),
                                          series: <PieSeries<_SalesData,
                                              String>>[
                                            PieSeries<_SalesData, String>(
                                                legendIconType: LegendIconType
                                                    .circle,
                                                radius: '100',
                                                dataSource: businessData,
                                                enableTooltip: true,
                                                pointColorMapper:
                                                    (_SalesData sales,
                                                            int index) =>
                                                        areaColor[index %
                                                            areaColor.length],
                                                xValueMapper:
                                                    (_SalesData sales, _) =>
                                                        sales.status,
                                                yValueMapper:
                                                    (_SalesData sales, _) =>
                                                        sales.count)
                                          ]),
                                    ],
                                  ),
                                )
                              : SizedBox()
                          : SizedBox(),

                      SizedBox(
                        height: 20,
                      ),
                      // Container(
                      //   decoration: const BoxDecoration(
                      //     color: AppColor.navBarIconColor,
                      //     borderRadius: BorderRadius.all(
                      //       Radius.circular(10),
                      //     ),
                      //   ),
                      //   // width: 400,
                      //   height: 50,
                      //   child: const Center(
                      //     child: Text(
                      //       'Template',
                      //       style: TextStyle(
                      //         color: Color.fromARGB(255, 255, 255, 255),
                      //         fontSize: 18,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Container(
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
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
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
                                      pointColorMapper: (Templatedata sales,
                                              int index) =>
                                          areaColor[index % areaColor.length],
                                      xValueMapper: (Templatedata sales, _) =>
                                          sales.status,
                                      yValueMapper: (Templatedata sales, _) =>
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

  // Widget _buildCircleIcon(IconData icon) {
  //   return Container(
  //     padding: const EdgeInsets.all(10),
  //     decoration: const BoxDecoration(
  //       color: Color(0xFF00A1E4),
  //       shape: BoxShape.circle,
  //     ),
  //     child: Icon(icon, color: Colors.white, size: 24),
  //   );
  // }

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
    for (var viewModel in whatsAppSettingVM!.viewModels) {
      var nmodel = viewModel.model;
      for (var record in nmodel?.record ?? []) {
        allNums.add(record);
        allWhNums.add("${record.name} ${record.phone}");
        itemsMap[record.phone] = "${record.name} ${record.phone}";
      }
    }
    print("itemsMap::: ${itemsMap}   ${allNums}");
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

  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    var number = prefs.getString('phoneNumber');

    if (!mounted) return;
    Provider.of<LeadListViewModel>(context, listen: false).fetch();
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
