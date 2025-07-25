// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/models/campaign_model/record.dart';
import 'package:whatsapp/view_models/campaign_vm.dart';
import 'package:whatsapp/views/view/lead_add_update_view.dart';

import '../../utils/app_color.dart';
import 'message_history_view.dart';

class CampaignDetailView extends StatefulWidget {
  final Record? record;
  const CampaignDetailView({super.key, this.record});

  @override
  // ignore: library_private_types_in_public_api
  _CampaignDetailViewState createState() => _CampaignDetailViewState();
}

class _CampaignDetailViewState extends State<CampaignDetailView> {
  String? dateformat;
  late CampaignViewModel campaignlistvm;
  get record => widget.record;

  @override
  void initState() {
    super.initState();
    if (record != null) {
      var createdDate = record!.startDate;
      var parsedDate = DateTime.parse(createdDate.toString());
      dateformat = DateFormat('dd/MM/yyyy hh:mm a').format(parsedDate);
    }
  }

  // Future<void> _showDeleteDialog() async {
  //   await showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text(
  //               'Are you sure you want to delete this campaign?',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             const SizedBox(height: 15),
  //             const Divider(),
  //             const SizedBox(height: 15),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 TextButton(
  //                   style: TextButton.styleFrom(
  //                     foregroundColor: Colors.grey,
  //                     backgroundColor: Colors.grey[200],
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 20, vertical: 12),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: const Text(
  //                     'No',
  //                     style: TextStyle(fontSize: 14),
  //                   ),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                 ),
  //                 const SizedBox(width: 20),
  //                 TextButton(
  //                   style: TextButton.styleFrom(
  //                     foregroundColor: Colors.white,
  //                     backgroundColor: AppColor.navBarIconColor,
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 20, vertical: 12),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: const Text(
  //                     'Yes',
  //                     style: TextStyle(fontSize: 14),
  //                   ),
  //                   onPressed: () {
  //                     // Navigator.push(
  //                     //   context,
  //                     //   MaterialPageRoute(
  //                     //     builder: (context) => CampaignListView(),
  //                     //   ),
  //                     // );
  //                     _deleteUser();
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _deleteUser() {
  //   String? campaignidd = widget.record?.campaignId;
  //   print("campaigniddcampaignidd$campaignidd");
  //   if (campaignidd == null || campaignidd.isEmpty) {
  //     print("Error: leadidd is null or empty");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Error: Lead ID is invalid.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }

  //   try {
  //     campaignidd = campaignidd.trim();
  //     print("campaignidd ID: $campaignidd");
  //   } catch (e) {
  //     print("Invalid UTF-16 string: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Error: Invalid lead ID format.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }
  //   CampaignViewModel(context).deleteById(campaignidd).then((value) async {
  //     print("working enter");

  //     EasyLoading.showToast("Deleted Succeffuly");

  //     campaignlistvm = Provider.of<CampaignViewModel>(context, listen: false);

  //     final prefs = await SharedPreferences.getInstance();
  //     var number = prefs.getString('phoneNumber');
  //     await Provider.of<CampaignViewModel>(context, listen: false)
  //         .fetchCampaign(number: number ?? "")
  //         .then((onValue) {
  //       Future.delayed(const Duration(milliseconds: 100), () {
  //         if (mounted && Navigator.canPop(context)) {
  //           Navigator.pop(context);
  //           Navigator.pushAndRemoveUntil(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => MultiProvider(
  //                 providers: [
  //                   ChangeNotifierProvider(
  //                     create: (_) => CampaignViewModel(context),
  //                   ),
  //                 ],
  //                 child: const CampaignListView(),
  //               ),
  //             ),
  //             (Route<dynamic> route) => route.isFirst,
  //           );
  //         }
  //       });
  //     });
  //   }).catchError((error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Error deleting campaign.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // actions: [
        // if (widget.record?.campaignStatus != 'Completed')
        // PopupMenuButton<String>(
        //   icon: const Icon(Icons.more_vert, size: 23, color: Colors.white),
        //   onSelected: (value) async {
        //     if (value == 'edit') {
        //       if (widget.record != null) {
        //         final result = await Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) =>
        //                 CampaignAddUpdateView(model: widget.record),
        //           ),
        //         );
        //         if (result == true) {
        //           print("result on detailesss:::: ");
        //           Navigator.pop(context, true);
        //         }
        //       }
        //     }

        //     PopupMenuButton<String>(
        //       icon: const Icon(Icons.more_vert,
        //           size: 23, color: Colors.white),
        //       onSelected: (value) async {
        //         if (value == 'edit') {
        //           // _navigateToEdit();
        //           if (widget.record != null) {
        //             final result = await Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                 builder: (context) =>
        //                     CampaignAddUpdateView(model: widget.record),
        //               ),
        //             );
        //             if (result == true) {
        //               print("result on detailesss:::: ");
        //               Navigator.pop(context, true);
        //             }
        //           }
        //         }
        //         print("Vallallalla=>${value}");
        //         if (value == 'delete') {
        //           print("shhsjhjsh");
        //         }
        //       },
        //       itemBuilder: (BuildContext context) {
        //         return [
        //           const PopupMenuItem<String>(
        //             value: 'edit',
        //             child: Text('Edit'),
        //           ),
        //           const PopupMenuItem<String>(
        //             value: 'delete',
        //             child: Text('delete'),
        //           ),
        //         ];
        //       },
        //     );
        //   },
        //   itemBuilder: (BuildContext context) {
        //     return [
        //       const PopupMenuItem<String>(
        //         value: 'edit',
        //         child: Text('Edit'),
        //       ),
        //       const PopupMenuItem<String>(
        //         value: 'delete',
        //         child: Text('Delete'),
        //       ),
        //     ];
        //   },
        // ),
        // PopupMenuButton<String>(
        //   icon: const Icon(Icons.more_vert, size: 23, color: Colors.white),
        //   onSelected: (value) async {
        //     if (value == 'edit') {
        //       if (widget.record != null) {
        //         final result = await Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) =>
        //                 CampaignAddUpdateView(model: widget.record),
        //           ),
        //         );
        //         if (result == true) {
        //           print("Edit successful, returning to previous screen.");
        //           Navigator.pop(context, true);
        //         }
        //       }
        //     } else if (value == 'delete') {
        //       print("wowoowowowowowo");
        //       _showDeleteDialog();
        //     }
        //   },
        //   itemBuilder: (BuildContext context) {
        //     return [
        //       const PopupMenuItem<String>(
        //         value: 'edit',
        //         child: Text('Edit'),
        //       ),
        //       const PopupMenuItem<String>(
        //         value: 'delete',
        //         child: Text('Delete'),
        //       ),
        //     ];
        //   },
        // ),
        // ],
      ),
      body: _pageBody(record),
    );
  }

  // void _deleteUser() {
  //   String? recordId = record?.campaignId;
  //   UserDataListViewModel(context).deleteUser(recordId).then((value) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Campaign deleted successfully.'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //     Navigator.pop(context);
  //   }).catchError((error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Error deleting campaign.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   });
  // }

  // Future<void> _showDeleteDialog() async {
  //   await showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text(
  //               'Are you sure you want to delete this campaign?',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             const SizedBox(height: 15),
  //             const Divider(),
  //             const SizedBox(height: 15),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 TextButton(
  //                   style: TextButton.styleFrom(
  //                     foregroundColor: Colors.grey,
  //                     backgroundColor: Colors.grey[200],
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 20, vertical: 12),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: const Text(
  //                     'No',
  //                     style: TextStyle(fontSize: 14),
  //                   ),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                 ),
  //                 const SizedBox(width: 20),
  //                 TextButton(
  //                   style: TextButton.styleFrom(
  //                     foregroundColor: Colors.white,
  //                     backgroundColor: AppColor.navBarIconColor,
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 20, vertical: 12),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: const Text(
  //                     'Yes',
  //                     style: TextStyle(fontSize: 14),
  //                   ),
  //                   onPressed: () {
  //                     _deleteUser();
  //                     Navigator.of(context).pop();
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _pageBody(model) {
    String? formattedDate;
    if (widget.record?.startDate != null) {
      formattedDate =
          DateFormat('M/d/yyyy, h:mm:ss a').format(widget.record!.startDate!);
    } else {
      formattedDate = 'N/A';
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5,
                    spreadRadius: 3,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  detailsHeading(
                    title: "Campaign Information",
                  ),
                  const SizedBox(height: 15),
                  _buildRow("Campaign Name", widget.record?.campaignName),
                  const Divider(),
                  _buildRow("Campaign Status", widget.record?.campaignStatus),
                  const Divider(),
                  _buildRow("Campaign Type", widget.record?.campaignType),
                  const Divider(),
                  _buildRow("Template Name", widget.record?.templateName),
                  const Divider(),
                  _buildRow("Group Name", widget.record?.groups),
                  const Divider(),
                  _buildRow("Time", formattedDate),

                  // const Divider(),
                  const SizedBox(height: 15),
                  _messageHistoryRow(),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, dynamic value) {
    String displayValue = "";

    if (value is List) {
      displayValue = value.map((item) => item['name'].toString()).join(", ");
    } else {
      displayValue = value?.toString() ?? "";
    }
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 9.0, left: 7.0, right: 7.0, top: 2.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          Expanded(
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
    );
  }

  Widget _messageHistoryRow() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageHistorytView(
              parentId: widget.record?.campaignId,
            ),
          ),
        );
      },
      child: const Padding(
        padding: EdgeInsets.all(12.0),
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
                      color: AppColor.navBarIconColor,
                      size: 24,
                    ),
                  ),
                  TextSpan(
                    text: '  Message History',
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}
