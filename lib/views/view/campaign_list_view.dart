// // -----------------End Code of Record List Method-------------------------
// import 'package:flutter_file_downloader/flutter_file_downloader.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/views/view/clone_campaign_view.dart';
import '../../models/campaign_model/campaign_model.dart';
import '../../models/user_model/user_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../view_models/campaign_vm.dart';
import 'campaign_add_update_view.dart';
import 'campaign_detail_view.dart';

class CampaignListView extends StatefulWidget {
  const CampaignListView({super.key});

  @override
  State<CampaignListView> createState() => _CampaignListView();
}

class _CampaignListView extends State<CampaignListView> {
  double? _progress;
  final List<String> _paymentterms = [];
  List allCampaigns = [];

  List tempCampaigns = [];
  List<String> selectCampList = [];
  CampaignModel? campginmodel;
  CampaignViewModel? campaign;
  List<CampaignViewModel> campginModelList = [];
  List<CampaignViewModel> tempcampginModelList = [];
  TextEditingController textController = TextEditingController();
  late CampaignViewModel campaignlistvm;
  bool isRefresh = false;
  String? number;
  List<CampaignViewModel> tempLeadModelList = [];
  String? selectedcampaign;
  bool nomatchescampaign = false;
  String searchcampaign = "";
  void getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      UserModel? userModel = AppUtils.getSessionUser(prefs);
    });
  }

  Future<void> saveNumberData() async {}

  @override
  void initState() {
    saveNumberData();
    getCampignList();
    allCampaigns = [];

    selectCampList = [];

    getProfileData();
    searchcampaign = "";
    tempLeadModelList = campginModelList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColor.navBarIconColor,
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.add,
                  size: 25,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CampaignAddUpdateView(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          'Campaign',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TextField(
              controller: textController,
              onChanged: _searchLeads,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: AppColor.textoriconColor.withOpacity(0.6),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.filter_list,
                          color: Color.fromARGB(255, 0, 0, 0),
                          size: 20,
                        ),
                        onPressed: () {
                          _showFilterBottomSheet(context);
                        },
                      ),
                      selectCampList.isEmpty
                          ? SizedBox()
                          : Container(
                              decoration: BoxDecoration(
                                  color: AppColor.navBarIconColor,
                                  shape: BoxShape.circle),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "${selectCampList.length}",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                    ],
                  ),
                ),

                // suffixIcon: Padding(
                //   padding: const EdgeInsets.all(5.0),
                //   child: Align(
                //     alignment: Alignment.topLeft,
                //     child: Container(
                //       height: 40,
                //       width: 40,
                //       child: FloatingActionButton(
                //         elevation: 0.5,
                //         backgroundColor: AppColor.navBarIconColor,
                //         shape: const CircleBorder(),
                //         tooltip: 'Filter',
                //         onPressed: () {
                //           _showFilterBottomSheet(context);
                //         },
                //         child: const Icon(
                //           Icons.filter_list_rounded,
                //           color: Colors.white,
                //           size: 23,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: AppUtils.getAppBody(campaignlistvm, _pageBody),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    campaign?.viewModels.clear();
    Provider.of<CampaignViewModel>(context, listen: false).fetch();
    campaign = Provider.of<CampaignViewModel>(context, listen: false);
    isRefresh = true;
    return Future<void>.delayed(const Duration(seconds: 2));
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      enableDrag: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<String> uniquePaymentTerms = _paymentterms.toSet().toList();
            if (uniquePaymentTerms.contains("All")) {
            } else {
              uniquePaymentTerms.add("All");
            }

            print("uniqq=>$uniquePaymentTerms");
            return Container(
              // height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppColor.navBarIconColor,
                                borderRadius: BorderRadius.circular(8)),
                            height: 40,
                            width: 350,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Campaign Status Filter',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Payment Term Dropdown
                    Container(
                        decoration: BoxDecoration(
                          // border: Border.all(
                          //   color: Colors.black,
                          //   width: 0.2,
                          // ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MultiSelectDialogField<String>(
                              items: uniquePaymentTerms
                                  .map((e) => MultiSelectItem<String>(e, e))
                                  .toList(),
                              title: Flexible(
                                child: const Text(
                                  "Select Campaign Status",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              buttonText: const Text("Select Campaign Status"),
                              searchable: true,
                              dialogWidth: 300,
                              dialogHeight: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                              onConfirm: (List<String> selected) {
                                setState(() {
                                  // Update selectleadList with the confirmed selections
                                  selectCampList = selected;
                                });
                              },
                              initialValue: [],
                            ),
                            SizedBox(height: 16),
                            Wrap(
                              spacing: 8.0,
                              children: selectCampList.map((selectedItem) {
                                return Chip(
                                  label: Text(selectedItem),
                                  deleteIcon: Icon(Icons.close),
                                  onDeleted: () {
                                    setState(() {
                                      selectCampList.remove(selectedItem);
                                    });
                                  },
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  labelStyle: TextStyle(color: Colors.blue),
                                );
                              }).toList(),
                            ),
                          ],
                        )

                        //  DropdownButtonFormField<String>(
                        //   hint: const Text('Select Status'),
                        //   items: uniquePaymentTerms.map((String value) {
                        //     return DropdownMenuItem<String>(
                        //       value: value,
                        //       child: Text(value),
                        //     );
                        //   }).toList(),
                        //   onChanged: (String? newValue) {
                        //     setState(() {
                        //       selectedcampaign = newValue;
                        //     });
                        //   },
                        //   value: selectedcampaign,
                        // ),
                        ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            selectedcampaign = 'All';
                            selectCampList = [];
                            _filterLeads(selectCampList);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.cardsColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Clear Filters',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _filterLeads(selectCampList);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.cardsColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool noMatchedLeads = false;
  void _searchLeads(String filter) {
    print("filyerL:::: ${filter}");
    searchcampaign = filter.trim().toLowerCase();
    if (searchcampaign.isEmpty) {
      allCampaigns = tempCampaigns;
      noMatchedLeads = false;
      setState(() {});
    } else {
      List matched = [];
      List others = [];

      for (var lead in allCampaigns) {
        var firstName = lead.campaignName?.toLowerCase() ?? '';
        var lastName = lead.campaignType?.toLowerCase() ?? '';
        var leadStatus = lead.campaignStatus?.toLowerCase() ?? '';

        if (firstName.contains(searchcampaign) ||
            lastName.contains(searchcampaign) ||
            leadStatus.contains(searchcampaign)) {
          matched.add(lead);
        } else {
          others.add(lead);
        }
      }
      setState(() {
        allCampaigns = [...matched, ...others];
        noMatchedLeads = matched.isEmpty;
      });
    }
  }

  void _filterLeads(List filter) {
    print(
        "filter:::::${filter}  ${tempCampaigns.length} ${campginModelList.length}  ${allCampaigns.length}  ${allCampaigns.runtimeType}");

    if (filter.contains('All') || filter.isEmpty) {
      allCampaigns = tempCampaigns;
      Navigator.pop(context);

      setState(() {});
      return;
    } else {
      List<dynamic> matchleads = tempCampaigns.where((lead) {
        return filter
            .map((e) => e.toLowerCase())
            .contains(lead.campaignStatus?.toLowerCase());
      }).toList();

      print("matchleads::::::::::::::::::::::::::::::::::::: ${matchleads}");
      setState(() {
        allCampaigns = matchleads;
      });
      print("cammam   ${matchleads.length}");
      Navigator.pop(context);
      return;
    }
  }
//   String getCampaignStatus(String? startDate, String? endDate) {
//   if (startDate == null || endDate == null) return "Unknown";

//   DateTime now = DateTime.now();
//   DateTime start = DateTime.parse(startDate);
//   DateTime end = DateTime.parse(endDate);
//   Duration timeLeft = end.difference(now);

//   if (now.isBefore(start)) {
//     return "Upcoming";
//   } else if (timeLeft.inSeconds > 3) {
//     return "Ongoing";
//   } else if (timeLeft.inSeconds > 0) {
//     return "${timeLeft.inSeconds}";  // Countdown: 3, 2, 1
//   } else {
//     return "Completed";
//   }
// }

  Widget _pageBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        allCampaigns.isEmpty || noMatchedLeads
            ? SizedBox()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${allCampaigns.length} Records Found",
                  textAlign: TextAlign.left,
                ),
              ),
        Expanded(
          child: isLoading
              ? Center(
                  child: Container(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator()))
              : allCampaigns.isEmpty || noMatchedLeads
                  ? Center(
                      child: Text(
                      "No Campaign Found...",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ))
                  : ListView.builder(
                      itemCount: allCampaigns.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 1),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 1, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: const Border(
                                left: BorderSide(
                                    color: AppColor.navBarIconColor, width: 5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 2,
                                  spreadRadius: 2,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 1, bottom: 2),
                              child: InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CampaignDetailView(
                                          record: allCampaigns[index]),
                                    ),
                                  );
                                  if (result == true) {
                                    print("is result getting true.........?");
                                    saveNumberData();
                                    getCampignList();
                                  }
                                },
                                child: ListTile(
                                  title: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  allCampaigns[index]
                                                          .campaignName ??
                                                      "",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  allCampaigns[index]
                                                          .campaignType ??
                                                      "",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.lightBlue
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                                Text(
                                                  allCampaigns[index]
                                                          .campaignStatus ??
                                                      "",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                // Text(
                                                //   getCampaignStatus(
                                                //       allCampaigns[index].startDate,
                                                //       allCampaigns[index].endDate),
                                                //   style: const TextStyle(
                                                //     fontSize: 14,
                                                //     fontWeight: FontWeight.bold,
                                                //     color: Colors.black,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                            Spacer(),
                                            allCampaigns[index]
                                                        .campaignStatus ==
                                                    'Completed'
                                                ? SizedBox()
                                                : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  CampaignCloneview(
                                                                      record: allCampaigns[
                                                                          index]),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 7,
                                                                  vertical: 8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.blue,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Text(
                                                            'Clone',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      allCampaigns[index].fileTitle == null
                                          ? SizedBox()
                                          : GestureDetector(
                                              // onTap: () async {

                                              //   var token =
                                              //       await AppUtils.getToken();
                                              //   FileDownloader.downloadFile(
                                              //     url:
                                              //         "https://sandbox.watconnect.com/swp/api/whatsapp/campaign/download/${allCampaigns[index].fileTitle}",
                                              //     name:
                                              //         allCampaigns[index].fileTitle,
                                              //     headers: {
                                              //       'Authorization': token ?? ""
                                              //     },
                                              //     downloadDestination:
                                              //         DownloadDestinations
                                              //             .publicDownloads,
                                              //     notificationType:
                                              //         NotificationType.all,
                                              //     onDownloadCompleted: (path) {
                                              //       ScaffoldMessenger.of(context)
                                              //           .showSnackBar(
                                              //         const SnackBar(
                                              //           content: Text(
                                              //               'Download Complete'),
                                              //           backgroundColor:
                                              //               Colors.green,
                                              //         ),
                                              //       );
                                              //     },
                                              //     onProgress: (fileName, progress) {
                                              //       ScaffoldMessenger.of(context)
                                              //           .showSnackBar(
                                              //         const SnackBar(
                                              //           content:
                                              //               Text('Downloading..'),
                                              //           backgroundColor:
                                              //               Colors.green,
                                              //         ),
                                              //       );
                                              //     },
                                              //   );

                                              // },
                                              child: Container(
                                                child: Image.asset(
                                                  'assets/images/download.png',
                                                  height: 30,
                                                  width: 30,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          // child: ListView(
          //   children: getContactWidgets(),
          // ),
        ),
      ],
    );
  }

  List<Widget> getContactWidgets() {
    List<Widget> widgets = [];
    for (var viewModel in campaignlistvm.viewModels) {
      CampaignModel model = viewModel.model;
      if (model.records?.isNotEmpty ?? false) {
        widgets.addAll(contactRecordList(model));
      }
    }
    return widgets;
  }

  List<Widget> contactRecordList(CampaignModel model) {
    List<Widget> widgets = [];

    for (var record in model.records ?? []) {
      Color statusColor = Colors.red;
      String statusText = "";
      if (record.campaignStatus?.trim().toUpperCase() == 'Pending') {
        statusColor = const Color.fromARGB(255, 46, 198, 69);
        statusText = "Pending";
      } else if (record.campaignStatus?.trim().toUpperCase() == 'Completed') {
        statusColor = Colors.red;
        statusText = "Completed";
      } else {
        statusColor = Colors.grey;
        statusText = "";
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                left: BorderSide(color: AppColor.navBarIconColor, width: 5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  spreadRadius: 2,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 1, bottom: 2),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CampaignDetailView(record: record),
                    ),
                  );
                },
                child: ListTile(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.campaignName ?? "",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              record.campaignType ?? "",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlue.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              record.campaignStatus ?? "",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // GestureDetector(
                      //   onTap: () {
                      //     print("Download started...");
                      //     CircularProgressIndicator(
                      //         backgroundColor: Colors.amber);
                      //     setState(() {
                      //       _progress = 0.0;
                      //     });

                      //     FileDownloader.downloadFile(
                      //         downloadDestination:
                      //             DownloadDestinations.publicDownloads,
                      //         name: model.records!.first.fileTitle,
                      //         notificationType: NotificationType.all,
                      //         url:
                      //             'https://crm.usam.co.in/ibs/api/files/${model.records!.first.campaignId}/download',
                      //         onProgress: (name, progress) {
                      //           setState(() {
                      //             _progress = progress;
                      //           });
                      //         },
                      //         onDownloadCompleted: (value) {
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             const SnackBar(
                      //               content: Text('Downloadded Complete'),
                      //               backgroundColor: Colors.green,
                      //             ),
                      //           );
                      //           debug('path  $value ');
                      //           setState(() {
                      //             _progress = null;
                      //           });
                      //           AlertDialog alert = AlertDialog(
                      //             title: Text(
                      //               "Download",
                      //             ),
                      //             content: Text(
                      //               'path$value',
                      //             ),
                      //             actions: [
                      //               TextButton(
                      //                 child: Text(
                      //                   "Ok",
                      //                   style: TextStyle(
                      //                       color: AppColor.navBarIconColor),
                      //                   selectionColor:
                      //                       AppColor.navBarIconColor,
                      //                 ),
                      //                 onPressed: () {
                      //                   Navigator.pop(context);
                      //                 },
                      //               ),
                      //             ],
                      //           );
                      //           // return showDialog(
                      //           //   context: context,
                      //           //   builder: (context) {
                      //           //     return alert;
                      //           //   },
                      //           // );
                      //         });

                      //     print("Download request sent...");
                      //   },
                      //   child: Container(
                      //     child: Image.asset(
                      //       'assets/images/download.png',
                      //       height: 30,
                      //       width: 30,
                      //     ),
                      //   ),
                      // )
                      // GestureDetector(
                      //   onTap: () {
                      //     print("Download started...");

                      //     setState(() {
                      //       _progress = 0.0;
                      //     });
                      //     print("file id=>${model.records!.first.fileId}");
                      //     print(
                      //         "file fileSize=>${model.records!.first.fileSize}");
                      //     print("file id=>${model.records!.first.fileId}");
                      //     // Start the download
                      //     FileDownloader.downloadFile(
                      //       downloadDestination:
                      //           DownloadDestinations.publicDownloads,
                      //       name: model.records!.first.fileTitle,
                      //       notificationType: NotificationType.all,
                      //       url:
                      //           'https://sandbox.watconnect.com/swp/api/whatsapp/campaign/download/${model.records!.first.fileTitle}/download',
                      //       onProgress: (name, progress) {
                      //         setState(() {
                      //           _progress = progress;
                      //         });
                      //       },
                      //       onDownloadCompleted: (value) {
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           const SnackBar(
                      //             content: Text('Download Complete'),
                      //             backgroundColor: Colors.green,
                      //           ),
                      //         );

                      //         debug('path  $value ');

                      //         setState(() {
                      //           _progress = null;
                      //         });

                      //         AlertDialog alert = AlertDialog(
                      //           elevation: 1,
                      //           backgroundColor: AppColor.navBarIconColor,
                      //           title: Text(
                      //             "Download Complete",
                      //             style: TextStyle(color: Colors.white),
                      //           ),
                      //           content: Text('File saved at path: $value',
                      //               style: TextStyle(color: Colors.white)),
                      //           actions: [
                      //             TextButton(
                      //               child: Text(
                      //                 "Ok",
                      //                 style: TextStyle(
                      //                     color: AppColor.navBarIconColor),
                      //               ),
                      //               onPressed: () {
                      //                 Navigator.pop(context);
                      //               },
                      //             ),
                      //           ],
                      //         );

                      //         // Show the AlertDialog
                      //         showDialog(
                      //           context: context,
                      //           builder: (context) {
                      //             return alert;
                      //           },
                      //         );
                      //       },
                      //       onDownloadError: (error) {
                      //         setState(() {
                      //           _progress =
                      //               null; // Hide the progress bar if there is an error
                      //         });
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           SnackBar(
                      //             content: Text('Download failed: $error'),
                      //             backgroundColor: Colors.red,
                      //           ),
                      //         );
                      //       },
                      //     );
                      //   },
                      //   child: Container(
                      //     child: Stack(
                      //       children: [
                      //         Image.asset(
                      //           'assets/images/download.png',
                      //           height: 30,
                      //           width: 30,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  bool isLoading = false;
  Future<void> getCampignList() async {
    setState(() {
      isLoading = true;
    });
    campaignlistvm = Provider.of<CampaignViewModel>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');
    await Provider.of<CampaignViewModel>(context, listen: false)
        .fetchCampaign(number: number ?? "");
    print(
        "campaignlistvm.viewModels:: ${campaignlistvm.viewModels}   ${campaignlistvm.viewModels.runtimeType}  ${campaignlistvm.viewModels.length}");
    for (var viewModel in campaignlistvm.viewModels) {
      var campginmodel = viewModel.model;
      print("campginmodel::::${campginmodel}  ${campginmodel.runtimeType}");
      if (campginmodel?.records != null) {
        allCampaigns = [];
        for (var record in campginmodel!.records!) {
          if (record.campaignStatus != null) {
            _paymentterms.add(record.campaignStatus!);
            print("selectedcampaign:::${selectedcampaign}  ${selectCampList}");
            if (selectedcampaign == 'All' ||
                selectCampList.isEmpty ||
                selectedcampaign == '') {
              print("here in 1 condition");
              tempCampaigns.add(record);
              allCampaigns.add(record);
            } else if (selectedcampaign != null) {
              print(
                  "record.campaignStatus.toString()::: ${record.campaignStatus.toString()}");
              if (record.campaignStatus.toString().toLowerCase() ==
                  selectedcampaign?.toLowerCase()) {
                allCampaigns.add(record);
              }
            } else {
              allCampaigns.add(record);
            }

            if (searchcampaign.isNotEmpty) {
              List tempUsers = allCampaigns;
              allCampaigns = [];
              allCampaigns = tempUsers.where((user) {
                var firstName = user.campaignName?.toLowerCase() ?? '';
                print(
                    "Checking user: ${user.campaignName}, Result: ${firstName.contains(searchcampaign)}");
                return firstName.contains(searchcampaign);
              }).toList();
            }
          }
        }

        setState(() {});
        print(
            "Record Campaign allCampaigns: ${allCampaigns.length}   ${allCampaigns.runtimeType}");
      }
    }

    setState(() {
      isLoading = false;
    });
  }
}
