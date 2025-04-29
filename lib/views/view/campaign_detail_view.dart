import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/models/campaign_model/record.dart';
import 'package:whatsapp/views/view/campaign_add_update_view.dart'
    show CampaignAddUpdateView;

import '../../utils/app_color.dart';
import '../../view_models/user_data_list_vm.dart' show UserDataListViewModel;
import 'message_history_view.dart';

class CampaignDetailView extends StatefulWidget {
  final Record? record;
  const CampaignDetailView({super.key, this.record});

  @override
  _CampaignDetailViewState createState() => _CampaignDetailViewState();
}

class _CampaignDetailViewState extends State<CampaignDetailView> {
  String? dateformat;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        actions: [
          if (widget.record?.campaignStatus != 'Completed')
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 23, color: Colors.white),
              onSelected: (value) async {
                if (value == 'edit') {
                  if (widget.record != null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CampaignAddUpdateView(model: widget.record),
                      ),
                    );
                    if (result == true) {
                      print("result on detailesss:::: ");
                      Navigator.pop(context, true);
                    }
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                ];
              },
            ),
        ],
      ),
      body: _pageBody(record),
    );
  }

  void _deleteUser() {
    String? recordId = record?.campaignId;
    UserDataListViewModel(context).deleteUser(recordId).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Campaign deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting campaign.'),
          backgroundColor: Colors.red,
        ),
      );
    });
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

    return Container(
      color: Colors.white38,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
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
