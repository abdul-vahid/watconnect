// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/models/message_history_model/message_history_model.dart';
import 'package:whatsapp/models/message_history_model/record.dart';
import '../../utils/app_color.dart';
import '../../utils/function_lib.dart';
import '../../view_models/message_history_vm.dart';

// ignore: must_be_immutable
class MessageHistorytView extends StatefulWidget {
  MessageHistoryModel? model;
  String? parentId;
  MessageHistorytView({super.key, this.model, this.parentId});

  @override
  State<MessageHistorytView> createState() => _MessageHistorytView();
}

class _MessageHistorytView extends State<MessageHistorytView> {
  // ignore: prefer_typing_uninitialized_variables
  var baseViewModals;
  get model => widget.model;
  String? tcount = '';
  String? failed = '';
  String? success = '';

  List<HistRecord> msgHistoryList = [];
  List<HistRecord> tempMsgHistoryList = [];

  @override
  void initState() {
    super.initState();

    getMsgHistory();
  }

  getMsgHistory() async {
    await Provider.of<MeesageHistoryViewModel>(context, listen: false)
        .fetchMessageHistory(widget.parentId);
  }

  @override
  Widget build(BuildContext context) {
    debug("Account=====  ${widget.parentId}");
    baseViewModals = Provider.of<MeesageHistoryViewModel>(context);

    // Loop through the records to get the counts
    for (var viewModel in baseViewModals.viewModels) {
      MessageHistoryModel model = viewModel.model;
      for (var record in model.records ?? []) {
        if (widget.parentId == record.parentId) {
          tcount = record?.totalRecords ?? "";
          success = record?.successCount ?? "";
          failed = record?.failedCount ?? "";
        }
      }
    }

    Set<String> uniqueParentIds = {};

    if (baseViewModals.viewModels.isNotEmpty) {
      for (var viewModel in baseViewModals.viewModels) {
        MessageHistoryModel model = viewModel.model;

        for (var record in model.records ?? []) {
          if (widget.parentId == record.parentId &&
              !uniqueParentIds.contains(record.parentId)) {
            print("model::::::::::  ${model.records}   ${model.records?[0]}");
            uniqueParentIds.add(record.parentId);
            // ignore: unused_local_variable
            if (model.records!.isNotEmpty) {
              msgHistoryList.clear();

              for (var rec in model.records ?? []) {
                msgHistoryList.add(rec);
              }
              tempMsgHistoryList = msgHistoryList;
            }
          }
        }
      }
      setState(() {});
    }

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
          'Message History',
          style: TextStyle(color: Colors.white),
        ),
      ),
      // bottomNavigationBar: Wrap(
      //   children: [
      //     SizedBox(
      //       height: 70,
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //         children: [
      //           _buildColoredText(
      //               'Total Records: $tcount', AppColor.containerBoxColor),
      //           _buildColoredText(
      //               'Success: $success', AppColor.navBarIconColor),
      //           _buildColoredText(
      //               'Failed: $failed', AppColor.motivationCar1Color),
      //         ],
      //       ),
      //     )
      //   ],
      // ),
      body: _pageBody(model),
    );
  }

  Widget _pageBody(model) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 3,
              itemBuilder: (context, index) {
                final items = [
                  {
                    'text': 'Total Records: $tcount',
                    'color': AppColor.containerBoxColor
                  },
                  {
                    'text': 'Success: $success',
                    'color': AppColor.navBarIconColor
                  },
                  {
                    'text': 'Failed: $failed',
                    'color': AppColor.motivationCar1Color
                  },
                ];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildColoredText(
                    items[index]['text'] as String,
                    items[index]['color'] as Color,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 5,
                  spreadRadius: 3,
                  offset: const Offset(2, 4),
                ),
              ],
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: msgHistoryList.isEmpty
                  ? const Center(
                      child: Text(
                        "No History Found",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: msgHistoryList.length,
                      itemBuilder: (context, index) {
                        return msgHistItem(msgHistoryList[index]);
                      }),
            ),
          ),
          // child: ListView(
          //   children: getLeadWidgets(),
          // ),
        ),
      ],
    );
  }

  // Function to build the status badge
  Widget _buildStatusBadge(String deliveryStatus) {
    Color badgeColor;
    String label;

    switch (deliveryStatus.toLowerCase()) {
      case "read":
        badgeColor = Colors.green;
        label = "Read";
        break;
      case "failed":
        badgeColor = const Color.fromARGB(255, 255, 56, 56);
        label = "Failed";
        break;
      case "sent":
        badgeColor = AppColor.navBarIconColor;
        label = "Sent";
        break;
      case "delivered":
        badgeColor = AppColor.navBarIconColor;
        label = "Delivered";
        break;
      default:
        badgeColor = Colors.grey;
        label = "Unknown";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Function to get the border color based on the delivery status
  // Color _getBorderColor(String deliveryStatus) {
  //   switch (deliveryStatus.toLowerCase()) {
  //     case "read":
  //       return Colors.green;
  //     case "failed":
  //       return const Color.fromARGB(255, 255, 56, 56);
  //     case "sent":
  //       return AppColor.navBarIconColor;
  //     case "delivered":
  //       return AppColor.navBarIconColor;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  Widget _buildColoredText(String text, Color color) {
    return Container(
      height: 40,
      // margin: const EdgeInsets.symmetric(vertical: 6),
      // padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget msgHistItem(HistRecord record) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: const Border(
          left: BorderSide(
            color: AppColor.navBarIconColor,
            width: 4,
          ),
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 3,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.name ?? "",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.number ?? "",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  // Text(
                  //   record.deliveryStatus ?? "",
                  //   style: TextStyle(
                  //     fontSize: 12,
                  //     color: Colors.grey[600],
                  //   ),
                  // ),
                  Text(
                    record.errormsg ?? "",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 255, 56, 56),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
            _buildStatusBadge(record.deliveryStatus ?? ""),
          ],
        ),
      ),
    );
  }
}
