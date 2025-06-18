import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
import 'package:whatsapp/salesforce/model/campaign_history_model.dart';
import 'package:whatsapp/utils/app_color.dart';

class CampaignHistoryList extends StatefulWidget {
  const CampaignHistoryList({super.key});

  @override
  State<CampaignHistoryList> createState() => _CampaignHistoryListState();
}

class _CampaignHistoryListState extends State<CampaignHistoryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
        title: const Text(
          "Message History",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: _pageBody(),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  _pageBody() {
    return Consumer<SfcampaignController>(
        builder: (context, campController, child) {
      return Column(
        children: [
          Expanded(
            child: campController.campHistoryLoader
                ? const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : campController.sfCampHistoryList.isEmpty
                    ? const Center(
                        child: Text(
                          "No Message History Available..",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListView.builder(
                                itemCount:
                                    campController.sfCampHistoryList.length,
                                itemBuilder: (context, index) {
                                  return campHistListItem(
                                      campController.sfCampHistoryList[index],
                                      index + 1);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      );
    });
  }

  campHistListItem(SfCampaignHistoryModel sfCampHistoryList, int indx) {
    Color statusColor;
    statusColor = Colors.lightBlue.withOpacity(0.7);
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: statusColor,
              width: 5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 3,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: InkWell(
            onTap: () async {
              // showBlurOnlyLoaderDialog(context);
              // SfcampaignController campController =
              //     Provider.of(context, listen: false);
              // campController.setSelectedCampaign(sfCampaignList);
              // Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => SfCampaignDetailScreen()));
            },
            child: Row(
              children: [
                // const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${sfCampHistoryList.whatsAppCustomerName}",
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "+${sfCampHistoryList.whatsAppCustomerNumber}",
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            sfCampHistoryList.deliveryStatus!.isEmpty
                                ? SizedBox()
                                : Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: sfCampHistoryList.deliveryStatus!
                                                    .toLowerCase() ==
                                                "failed"
                                            ? Colors.red.shade500
                                            : Colors.green),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 7),
                                        child: Text(
                                          sfCampHistoryList.deliveryStatus ??
                                              "",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  )
                          ],
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 2.0),
                        //   child: RichText(
                        //     text: TextSpan(
                        //       children: [
                        //         const TextSpan(
                        //           text: 'Template Name : ',
                        //           style: TextStyle(
                        //             fontSize: 13,
                        //             fontWeight: FontWeight.w600,
                        //             color: Colors.black,
                        //           ),
                        //         ),
                        //         TextSpan(
                        //           text: sfCampHistoryList.templateName ?? '',
                        //           style: const TextStyle(
                        //             fontSize: 13,
                        //             fontWeight: FontWeight.w400,
                        //             color: Colors.black,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        sfCampHistoryList.errorMsg!.isEmpty
                            ? SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "${sfCampHistoryList.errorMsg}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.red),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
