import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
import 'package:whatsapp/salesforce/screens/campaign_history_list.dart';
import 'package:whatsapp/salesforce/screens/sf_campaign_listing_screen.dart';
import 'package:whatsapp/utils/app_color.dart';

class SfCampaignDetailScreen extends StatefulWidget {
  const SfCampaignDetailScreen({super.key});

  @override
  State<SfCampaignDetailScreen> createState() => _SfCampaignDetailScreenState();
}

class _SfCampaignDetailScreenState extends State<SfCampaignDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
          child: InkWell(
            onTap: () {
              SfcampaignController campCtrol =
                  Provider.of(context, listen: false);
              campCtrol.getCampMsgHisApiCall();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CampaignHistoryList()));
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColor.navBarIconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      style: TextStyle(fontSize: 18),
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(
                              FontAwesomeIcons.message,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          TextSpan(
                              text: '  Message History',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 17,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        appBar: AppBar(
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
          centerTitle: true,
          elevation: 2,
          backgroundColor: AppColor.navBarIconColor,
          title: const Text(
            "Campaign Details",
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
        body: Container(
          color: Colors.white38,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Consumer<SfcampaignController>(
                  builder: (context, campController, child) {
                var selectedCampData = campController.selectedCampaign;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),

                      buildRow("Campaign Name",
                          value: selectedCampData?.name ?? ""),

                      buildRow("Campaign Status",
                          value: selectedCampData?.status ?? ""),

                      // _buildRow(
                      //   "Campaign Type",
                      // ),

                      buildRow("Template Name",
                          value: "${selectedCampData?.templateName ?? ""}"),

                      buildRow("Business Number",
                          value: selectedCampData?.bussinessNumber ?? ""),

                      buildRow(
                        "Time",
                        value:
                            "${campDate(selectedCampData?.startDateTime ?? "")}",
                      ),

                      buildRow(
                        "Sent",
                        value: selectedCampData?.sent ?? "",
                      ),

                      buildRow(
                        "Delivered",
                        value: selectedCampData?.delivered ?? "",
                      ),

                      buildRow(
                        "Read",
                        value: selectedCampData?.read ?? "-",
                      ),

                      buildRow(
                        "Total Failed",
                        value: selectedCampData?.totalFail ?? "-",
                      ),

                      buildRow(
                        "Total Delivered",
                        value: selectedCampData?.totalDelivered ?? "",
                      ),

                      buildRow(
                        "Total Read",
                        value: selectedCampData?.totalRead ?? "-",
                      ),
                      buildRow(
                        "Total Response",
                        value: selectedCampData?.totalResponse ?? "-",
                      ),

                      buildRow(
                        "Response Rate",
                        value: selectedCampData?.responseRate ?? "-",
                      ),

                      // const Divider(),
                      const SizedBox(height: 15),
                      // _messageHistoryRow(),
                    ],
                  ),
                );
              }),
            ),
          ),
        ));
  }
}

Widget buildRow(String label, {dynamic value = ""}) {
  String displayValue = "";

  if (value is List) {
    displayValue = value.map((item) => item['name'].toString()).join(", ");
  } else {
    displayValue = value?.toString() ?? "";
  }
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 7,
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Divider()
    ],
  );
}
