// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:whatsapp/models/message_history_model/message_history_model.dart';
// import '../../utils/app_color.dart';
// import '../../utils/function_lib.dart';
// import '../../view_models/message_history_vm.dart';

// class MessageHistorytView extends StatefulWidget {
//   MessageHistoryModel? model;
//   String? parentId;
//   MessageHistorytView({super.key, this.model, this.parentId});

//   @override
//   State<MessageHistorytView> createState() => _MessageHistorytView();
// }

// class _MessageHistorytView extends State<MessageHistorytView> {
//   var baseViewModals;
//   get model => widget.model;
//   String? tcount = '';
//   String? failed = '';
//   String? success = '';
//   @override
//   void initState() {
//     super.initState();

//     Provider.of<MeesageHistoryViewModel>(context, listen: false)
//         .fetchMessageHistory(widget.parentId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     debug("Account=====  ${widget.parentId}");
//     baseViewModals = Provider.of<MeesageHistoryViewModel>(context);
//     for (var viewModel in baseViewModals.viewModels) {
//       MessageHistoryModel model = viewModel.model;
//       for (var record in model.records ?? []) {
//         if (widget.parentId == record.parentId) {
//           // print("widget.parentId${widget.parentId}");
//           // print("model.records${model.records}");
//           tcount = record?.totalRecords ?? "";
//           // print("tcode$tcount");
//           success = record?.successCount ?? "";
//           failed = record?.failedCount ?? "";
//         }
//       }
//     }
//     return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back,
//                 color: Color.fromARGB(255, 255, 255, 255)),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           centerTitle: true,
//           elevation: 0,
//           title: const Text(
//             'Message History',
//             style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
//           ),
//         ),
//         bottomNavigationBar: Wrap(
//           children: [
//             SizedBox(
//               height: 70,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildColoredText(
//                       'Total Records: $tcount', AppColor.containerBoxColor),
//                   _buildColoredText(
//                       'Success: $success', AppColor.navBarIconColor),
//                   _buildColoredText(
//                       'Failed: $failed', AppColor.motivationCar1Color),
//                 ],
//               ),
//             )
//           ],
//         ),
//         body: _pageBody(model));
//   }

//   Widget _pageBody(model) {
//     return Column(
//       children: [
//         Expanded(
//             child: ListView(
//           children: getLeadWidgets(),
//         ))
//       ],
//     );
//   }

//   List<Widget> getLeadWidgets() {
//     List<Widget> widgets = [];

//     if (baseViewModals.viewModels.isNotEmpty) {
//       for (var viewModel in baseViewModals.viewModels) {
//         MessageHistoryModel model = viewModel.model;
//         for (var record in model.records ?? []) {
//           if (widget.parentId == record.parentId) {
//             widgets.addAll(contactRecordList(model));
//           }
//         }
//       }

//       if (widgets.isEmpty) {
//         widgets.add(
//           const Center(
//             child: Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text(
//                 "Record Not Found",
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.black54,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }

//       return widgets;
//     } else {
//       return [
//         const Padding(
//           padding: EdgeInsets.only(top: 8.0),
//           child: Center(
//             child: Text(
//               "Record Not Found",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.black54,
//               ),
//             ),
//           ),
//         ),
//       ];
//     }
//   }

//   List<Widget> contactRecordList(MessageHistoryModel model) {
//     List<Widget> widgets = [];

//     for (var record in model.records ?? []) {
//       Color borderColor = _getBorderColor(record.deliveryStatus ?? "");

//       widgets.add(Container(
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           border: Border(
//             left: BorderSide(
//               color: borderColor,
//               width: 4,
//             ),
//           ),
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: InkWell(
//           onTap: () {},
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       record.name ?? "",
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       record.number ?? "",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     Text(
//                       record.deliveryStatus ?? "",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               _buildStatusBadge(record.deliveryStatus ?? ""),
//             ],
//           ),
//         ),
//       ));
//     }

//     return widgets;
//   }

//   Widget _buildStatusBadge(String deliveryStatus) {
//     Color badgeColor;
//     String label;

//     switch (deliveryStatus.toLowerCase()) {
//       case "read":
//         badgeColor = Colors.green;
//         label = "read";
//         break;
//       case "failed":
//         badgeColor = AppColor.motivationCar1Color;
//         label = "Failed";
//         break;
//       case "sent":
//         badgeColor = AppColor.navBarIconColor;
//         label = "sent";
//         break;
//       case "delivered":
//         badgeColor = AppColor.navBarIconColor;
//         label = "delivered";
//         break;
//       default:
//         badgeColor = Colors.grey;
//         label = "Unknown";
//         break;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: badgeColor,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontSize: 12,
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Color _getBorderColor(String deliveryStatus) {
//     switch (deliveryStatus.toLowerCase()) {
//       case "read":
//         return AppColor.navBarIconColor;
//       case "failed":
//         return AppColor.motivationCar1Color;
//       case "sent":
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _buildColoredText(String text, Color color) {
//     return Container(
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: color,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/models/message_history_model/message_history_model.dart';
import '../../utils/app_color.dart';
import '../../utils/function_lib.dart';
import '../../view_models/message_history_vm.dart';

class MessageHistorytView extends StatefulWidget {
  MessageHistoryModel? model;
  String? parentId;
  MessageHistorytView({super.key, this.model, this.parentId});

  @override
  State<MessageHistorytView> createState() => _MessageHistorytView();
}

class _MessageHistorytView extends State<MessageHistorytView> {
  var baseViewModals;
  get model => widget.model;
  String? tcount = '';
  String? failed = '';
  String? success = '';

  @override
  void initState() {
    super.initState();
    // Fetch message history when the widget is initialized
    Provider.of<MeesageHistoryViewModel>(context, listen: false)
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
          'Message History',
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: Wrap(
        children: [
          SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColoredText(
                    'Total Records: $tcount', AppColor.containerBoxColor),
                _buildColoredText(
                    'Success: $success', AppColor.navBarIconColor),
                _buildColoredText(
                    'Failed: $failed', AppColor.motivationCar1Color),
              ],
            ),
          )
        ],
      ),
      body: _pageBody(model),
    );
  }

  Widget _pageBody(model) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: getLeadWidgets(),
          ),
        ),
      ],
    );
  }

  // Function to get unique widgets based on parentId
  List<Widget> getLeadWidgets() {
    List<Widget> widgets = [];
    Set<String> uniqueParentIds = {}; // Set to track unique parentIds

    if (baseViewModals.viewModels.isNotEmpty) {
      for (var viewModel in baseViewModals.viewModels) {
        MessageHistoryModel model = viewModel.model;

        // Loop through each record and check if it's unique based on parentId
        for (var record in model.records ?? []) {
          if (widget.parentId == record.parentId &&
              !uniqueParentIds.contains(record.parentId)) {
            uniqueParentIds.add(
                record.parentId); // Add parentId to the set to avoid duplicates
            widgets.addAll(
                contactRecordList(model)); // Add widgets for unique records
          }
        }
      }

      if (widgets.isEmpty) {
        widgets.add(
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Record Not Found",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        );
      }
    } else {
      widgets = [
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Center(
            child: Text(
              "Record Not Found",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ];
    }

    return widgets;
  }

  // Function to return the record list widgets
  List<Widget> contactRecordList(MessageHistoryModel model) {
    List<Widget> widgets = [];

    for (var record in model.records ?? []) {
      Color borderColor = _getBorderColor(record.deliveryStatus ?? "");

      widgets.add(Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: borderColor,
              width: 4,
            ),
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 255, 56, 56),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(record.deliveryStatus ?? ""),
            ],
          ),
        ),
      ));
    }

    return widgets;
  }

  // Function to build the status badge
  Widget _buildStatusBadge(String deliveryStatus) {
    Color badgeColor;
    String label;

    switch (deliveryStatus.toLowerCase()) {
      case "read":
        badgeColor = Colors.green;
        label = "read";
        break;
      case "failed":
        badgeColor = const Color.fromARGB(255, 255, 56, 56);
        label = "Failed";
        break;
      case "sent":
        badgeColor = AppColor.navBarIconColor;
        label = "sent";
        break;
      case "delivered":
        badgeColor = AppColor.navBarIconColor;
        label = "delivered";
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
        borderRadius: BorderRadius.circular(20),
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
  Color _getBorderColor(String deliveryStatus) {
    switch (deliveryStatus.toLowerCase()) {
      case "read":
        return Colors.green;
      case "failed":
        return const Color.fromARGB(255, 255, 56, 56);
      case "sent":
        return AppColor.navBarIconColor;
      case "delivered":
        return AppColor.navBarIconColor;
      default:
        return Colors.grey;
    }
  }

  // Function to build colored text in the bottom navigation bar
  Widget _buildColoredText(String text, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
