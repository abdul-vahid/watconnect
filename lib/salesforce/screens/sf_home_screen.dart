import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as badges;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/model/business_number_model.dart';
import 'package:whatsapp/salesforce/screens/confige_listing_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_campaign_listing_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_darwer.dart';
import 'package:whatsapp/salesforce/widget/sf_dashboard_card.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/views/view/NotificationPage.dart';

class SfHomeScreen extends StatefulWidget {
  const SfHomeScreen({super.key});

  @override
  State<SfHomeScreen> createState() => _SfHomeScreenState();
}

class _SfHomeScreenState extends State<SfHomeScreen> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    DashBoardController drProvider = Provider.of(context, listen: false);

    drProvider.getDasBoardReportApiCall();
    drProvider.drawerApiCall();
    drProvider.getProfileApiCall();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  List<Color> areaColor = [
    AppColor.navBarIconColor,
    const Color.fromARGB(255, 205, 244, 247),
    Colors.blue,
    Colors.green
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SfAppDrawerWidget(),
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
                  Positioned(
                    right: 0,
                    top: 0,
                    child: badges.Badge(
                      isLabelVisible: true,
                      label: Text(
                        0.toString(),
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
              )),
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
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                  );
                }).toList();
              },
              onSelected: (value) async {
                await busNumCtrl.setBusinessNumberApiCall(
                    busNumber: value.whasappSettingNumber ?? "");
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
                Row(
                  children: [
                    DashboardCardItem(
                      icon: Icons.leaderboard,
                      countText: "${dbController.totalCamp} / Total",
                      title: "Campaigns",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SfCampaignScreen()),
                        );
                      },
                    ),
                    DashboardCardItem(
                      icon: Icons.bolt,
                      countText: "${dbController.totalLead} / Total",
                      title: "Leads",
                      onTap: () {
                        dbController.setSelectedTitle("Lead");
                        dbController.drawerListApiCall("Lead");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ConfigListingScreen(type: "Lead"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                dbController.totalCamp == "0"
                    ? SizedBox()
                    : Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColor.navBarIconColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
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
                              series: <PieSeries<SalesData, String>>[
                                PieSeries<SalesData, String>(
                                    legendIconType: LegendIconType.circle,
                                    radius: '100',
                                    dataSource: dbController.sfCampaignData,
                                    enableTooltip: true,
                                    pointColorMapper:
                                        (SalesData sales, int index) =>
                                            areaColor[index % areaColor.length],
                                    xValueMapper: (SalesData sales, _) =>
                                        sales.status,
                                    yValueMapper: (SalesData sales, _) =>
                                        sales.count)
                              ])
                        ],
                      ),
                dbController.totalLead == "0"
                    ? SizedBox()
                    : Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColor.navBarIconColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            height: 50,
                            child: const Center(
                              child: Text(
                                'Leads',
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
                                    dataSource: dbController.sfTemplatedata,
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
              ],
            );
          }),
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
