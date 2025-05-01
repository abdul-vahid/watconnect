import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/unread_msg_model/unread_msg_model.dart';
import '../../models/user_model/user_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../view_models/campaign_vm.dart';
import '../../view_models/unread_count_vm.dart';
import 'campaign_add_update_view.dart';
import 'campaign_detail_view.dart';

class MessageCountListView extends StatefulWidget {
  const MessageCountListView({super.key});

  @override
  State<MessageCountListView> createState() => _MessageCountListView();
}

class _MessageCountListView extends State<MessageCountListView> {
  // double? _progress;
  final List<String> _paymentterms = [];
  UnreadMsgModel? campginmodel;
  UnreadCountVm? campaign;
  List<CampaignViewModel> campginModelList = [];
  List<CampaignViewModel> tempcampginModelList = [];
  TextEditingController textController = TextEditingController();
  late UnreadCountVm campaignlistvm;
  bool isRefresh = false;
  String? number;
  List<CampaignViewModel> tempLeadModelList = [];
  String? selectedcampaign;
  void getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      UserModel? userModel = AppUtils.getSessionUser(prefs);
    });
  }

  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');
    Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number ?? "");
  }
  // Future<void> saveNumberData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   number = prefs.getString('phoneNumber');
  //   Provider.of<CampaignViewModel>(context, listen: false)
  //       .fetchCampaign(number: number ?? "");
  // }

  @override
  void initState() {
    _getUnreadCount();
    getProfileData();
    tempLeadModelList = campginModelList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    campaignlistvm = Provider.of<UnreadCountVm>(context);

    for (var viewModel in campaignlistvm.viewModels) {
      var campginmodel = viewModel.model;
      if (campginmodel?.records != null) {
        for (var record in campginmodel!.records!) {
          if (record.unreadMsgCount != null) {
            _paymentterms.add(record.unreadMsgCount!);
            print("Record Campaign Status: ${record.unreadMsgCount}");
          }
        }
      }
    }

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
              // onChanged: _filterLeads,
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
                  child: IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: Color.fromARGB(255, 0, 0, 0),
                      size: 20,
                    ),
                    onPressed: () {
                      _showFilterBottomSheet(context);
                    },
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
              ),
            ),
          ),
        ),
      ),
      body: AppUtils.getAppBody(campaignlistvm, _pageBody),
    );
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
            print("uniqq=>$uniquePaymentTerms");
            return Container(
              height: 220,
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
                      child: DropdownButtonFormField<String>(
                        hint: const Text('Select Status'),
                        items: uniquePaymentTerms.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedcampaign = newValue;
                          });
                        },
                        value: selectedcampaign,
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _filterLeads(selectedcampaign);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.navBarIconColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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
              ),
            );
          },
        );
      },
    );
  }

  void _filterLeads(String? filter) {
    campginModelList = tempLeadModelList;

    if (filter == null || filter.isEmpty) return;
    setState(() {
      campginModelList = tempLeadModelList
          .where((lead) =>
              lead.record?.unreadMsgCount?.toLowerCase() ==
              filter.toLowerCase())
          .toList();
      print("cammam$campginModelList");
    });
  }

  Widget _pageBody() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: getContactWidgets(),
          ),
        ),
      ],
    );
  }

  List<Widget> getContactWidgets() {
    List<Widget> widgets = [];
    for (var viewModel in campaignlistvm.viewModels) {
      UnreadMsgModel model = viewModel.model;
      if (model.records?.isNotEmpty ?? false) {
        widgets.addAll(contactRecordList(model));
      }
    }
    return widgets;
  }

  List<Widget> contactRecordList(UnreadMsgModel model) {
    List<Widget> widgets = [];

    for (var record in model.records ?? []) {
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
                              record.unreadMsgCount ?? "",
                              style: const TextStyle(
                                fontSize: 12,
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
                      //     print("working....");

                      //     setState(() {
                      //       _progress = 0.0;
                      //     });

                      //     FileDownloader.downloadFile(
                      //       downloadDestination:
                      //           DownloadDestinations.publicDownloads,
                      //       notificationType: NotificationType.all,
                      //       url:
                      //           'https://crm.usam.co.in/ibs/api/files/${record.campaignId}/download',
                      //       onProgress: (name, progress) {
                      //         print("onprogresssss button clicked");
                      //         setState(() {
                      //           _progress = progress;
                      //         });
                      //       },
                      //       onDownloadCompleted: (value) {
                      //         print("onDownloadCompleted button clicked");
                      //         print('path $value');
                      //         setState(() {
                      //           _progress = null;
                      //         });

                      //         AlertDialog alert = AlertDialog(
                      //           title: Text("Download"),
                      //           content: Text('path: $value'),
                      //           actions: [
                      //             TextButton(
                      //               child: const Text(
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
                      //         // return showDialog(
                      //         //   context: context,
                      //         //   builder: (context) {
                      //         //     return alert;
                      //         //   },
                      //         // );
                      //       },
                      //     );
                      //     print("workingggg===");
                      //   },
                      //   child: Container(
                      //     child: Image.asset(
                      //       'assets/images/download.png',
                      //       height: 30,
                      //       width: 30,
                      //     ),
                      //   ),
                      // ),
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

//   List<Widget> contactRecordList(CampaignModel model) {
//     List<Widget> widgets = [];
//     for (var record in model.records ?? []) {
//       Color statusColor = Colors.red;
//       String statusText = "";
//       if (record.campaignStatus?.trim().toUpperCase() == 'Pending') {
//         statusColor = const Color.fromARGB(255, 46, 198, 69);
//         statusText = "Pending";
//       } else if (record.campaignStatus?.trim().toUpperCase() == 'Completed') {
//         statusColor = Colors.red;
//         statusText = "Completed";
//       } else {
//         statusColor = Colors.grey;
//         statusText = "";
//       }
//       widgets.add(
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//               border: const Border(
//                 left: BorderSide(color: AppColor.navBarIconColor, width: 5),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 2,
//                   spreadRadius: 2,
//                   offset: const Offset(2, 4),
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.only(top: 1, bottom: 2),
//               child: InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CampaignDetailView(record: record),
//                     ),
//                   );
//                 },
//                 child: ListTile(
//                   title: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               record.campaignName ?? "",
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               record.campaignType ?? "",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.lightBlue.withOpacity(0.7),
//                               ),
//                             ),
//                             Text(
//                               record.campaignStatus ?? "",
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       GestureDetector(
//                         onTap: () {
//                           print("working....");
//                           setState(() {
//                             _progress = 0.0;
//                           });

//                           FileDownloader.downloadFile(
//                             downloadDestination:
//                                 DownloadDestinations.publicDownloads,
//                             notificationType: NotificationType.all,
//                             url:
//                                 'https://crm.usam.co.in/ibs/api/files/${record.id}/download',
//                             onProgress: (name, progress) {
//                               setState(() {
//                                 _progress = progress;
//                               });
//                             },
//                             onDownloadCompleted: (value) {
//                               print('path $value');
//                               setState(() {
//                                 _progress = null;
//                               });

//                               AlertDialog alert = AlertDialog(
//                                 title: Text("Download"),
//                                 content: Text('path: $value'),
//                                 actions: [
//                                   TextButton(
//                                     child: const Text(
//                                       "Ok",
//                                       style: TextStyle(
//                                           color: AppColor.navBarIconColor),
//                                     ),
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                     },
//                                   ),
//                                 ],
//                               );

//                               // return showDialog(
//                               //   context: context,
//                               //   builder: (context) {
//                               //     return alert;
//                               //   },
//                               // );
//                             },
//                           );
//                         },
//                         child: Container(
//                           child: Image.asset(
//                             'assets/images/download.png',
//                             height: 30,
//                             width: 30,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//     return widgets;
//   }
// }
}
