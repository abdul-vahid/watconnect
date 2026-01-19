// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/model/business_number_model.dart';
import 'package:whatsapp/salesforce/screens/confige_listing_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_campaign_listing_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_darwer.dart';
import 'package:whatsapp/salesforce/screens/sf_notification_screen.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:flutter/material.dart' as badges;
import 'package:whatsapp/utils/notification_utils.dart';
import 'package:whatsapp/views/widgets/home_page_cards.dart';

class SfHomeScreen extends StatefulWidget {
  const SfHomeScreen({super.key});

  @override
  State<SfHomeScreen> createState() => _SfHomeScreenState();
}

class _SfHomeScreenState extends State<SfHomeScreen> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    callAllApis();
    _tooltipBehavior = TooltipBehavior(enable: true);
    
    super.initState();
  }

  callAllApis() {
    Future.delayed(const Duration(milliseconds: 1500), () async {
      DashBoardController drProvider = Provider.of(context, listen: false);
NotificationUtil.registerToken();
      drProvider.getDasBoardReportApiCall();
      drProvider.drawerApiCall();
      drProvider.getProfileApiCall();
    });
  }

  List<Color> areaColor = [
    AppColor.navBarIconColor,
    const Color.fromARGB(255, 205, 244, 247),
    Colors.blue,
    Colors.green
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColor.navBarIconColor,
      onRefresh: () {
        DashBoardController dasbController =
            Provider.of(context, listen: false);
        dasbController.sfNotificationHistoryApiCall();
        dasbController.getDasBoardReportApiCall();
        // dasbController.drawerApiCall();
        return Future<void>.delayed(const Duration(seconds: 1));
      },
      child: FocusDetector(
        onFocusGained: () {
          DashBoardController dasbController =
              Provider.of(context, listen: false);
          dasbController.sfNotificationHistoryApiCall();
          dasbController.getDasBoardReportApiCall();
          dasbController.drawerApiCall();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          drawer: const SfAppDrawerWidget(),
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
                        builder: (context) => SfNotificationScreen(),
                      ),
                    );
                  },
                  icon: Consumer<DashBoardController>(
                      builder: (context, dbctrl, child) {
                    return Stack(
                      children: [
                        const Icon(
                          Icons.notifications,
                          size: 28,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: badges.Badge(
                            isLabelVisible: true,
                            label: Text(
                              dbctrl.sfNoticationList.length.toString(),
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
                    );
                  })),
              Consumer<BusinessNumberController>(
                  builder: (context, busNumCtrl, child) {
                return PopupMenuButton<BusinessNumberModel>(
                  position: PopupMenuPosition.under,
                  icon: const Icon(Icons.phone, size: 23, color: Colors.white),
                  itemBuilder: (BuildContext context) {
                    return busNumCtrl.businessNumbers.map((number) {
                      final isSelected = number.isDefault == "true";
                      return PopupMenuItem<BusinessNumberModel>(
                        value: number,
                        child: Text(
                          "${number.whasappSettingName} ${number.whasappSettingNumber} ",
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  onSelected: (value) async {
                    await busNumCtrl.setBusinessNumberApiCall(
                        busNumber: value.whasappSettingNumber ?? "");

                    await busNumCtrl.getBusinessNumberApiCall();
                  },
                );
              })
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Consumer<DashBoardController>(
                  builder: (context, dbController, child) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Row(
                        children: [
                          HomePageCard(
                            title: "All Campaigns",
                            subtitle: dbController.totalCamp,
                            icon: Icons.leaderboard_rounded,
                            polygonAsset: "assets/images/home_polygon.png",
                            tap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SfCampaignScreen()),
                              );
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          dbController.drawerItems.isEmpty
                              ? SizedBox()
                              : HomePageCard(
                                  title: dbController
                                          .drawerItems.first.sObjectName ??
                                      "",
                                  subtitle: dbController.totalLead,
                                  icon: Icons.bolt,
                                  polygonAsset:
                                      "assets/images/home_polygon.png",
                                  tap: () {
                                    // dbController.setSelectedTitle("Lead");
                                    dbController.drawerListApiCall(
                                        type: dbController.drawerItems.first
                                                .sObjectName ??
                                            "");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ConfigListingScreen(
                                                type: dbController.drawerItems
                                                        .first.sObjectName ??
                                                    ""),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    dbController.totalCamp == "0"
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(
                                bottom: 20.0, left: 5, right: 5),
                            child: Container(
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
                                      series: <PieSeries<SalesData, String>>[
                                        PieSeries<SalesData, String>(
                                            legendIconType:
                                                LegendIconType.circle,
                                            radius: '100',
                                            dataSource:
                                                dbController.sfCampaignData,
                                            enableTooltip: true,
                                            pointColorMapper: (SalesData sales,
                                                    int index) =>
                                                areaColor[
                                                    index % areaColor.length],
                                            xValueMapper:
                                                (SalesData sales, _) =>
                                                    sales.status,
                                            yValueMapper:
                                                (SalesData sales, _) =>
                                                    sales.count)
                                      ])
                                ],
                              ),
                            ),
                          ),
                    dbController.totalLead == "0"
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: Container(
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
                                    'Templates',
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
                                      series: <DoughnutSeries<Templatedata,
                                          String>>[
                                        DoughnutSeries<Templatedata, String>(
                                            radius: '100',
                                            dataSource:
                                                dbController.sfTemplatedata,
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
                          ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.status, this.count);

  final String status;
  final int count;
}

class Templatedata {
  Templatedata(this.status, this.count);
  final String status;
  final int count;
}
