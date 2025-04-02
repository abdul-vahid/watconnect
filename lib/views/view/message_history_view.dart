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

    Provider.of<MeesageHistoryViewModel>(context, listen: false)
        .fetchMessageHistory(widget.parentId);
  }

  @override
  Widget build(BuildContext context) {
    debug("Account=====  ${widget.parentId}");
    baseViewModals = Provider.of<MeesageHistoryViewModel>(context);
    for (var viewModel in baseViewModals.viewModels) {
      MessageHistoryModel model = viewModel.model;
      for (var record in model.records ?? []) {
        if (widget.parentId == record.parentId) {
          // print("widget.parentId${widget.parentId}");
          // print("model.records${model.records}");
          tcount = record?.totalRecords ?? "";
          // print("tcode$tcount");
          success = record?.successCount ?? "";
          failed = record?.failedCount ?? "";
        }
      }
    }
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Message History',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
        body: _pageBody(model));
  }

  Widget _pageBody(model) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColor.navBarIconColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Color.fromRGBO(0, 0, 0, 0.16),
              )
            ],
            border: Border(
              bottom: BorderSide(
                width: 1.8,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          padding: const EdgeInsets.only(top: 12, bottom: 15),
          child: const Row(children: []),
        ),
        Expanded(
            child: ListView(
          children: getLeadWidgets(),
        ))
      ],
    );
  }

  List<Widget> getLeadWidgets() {
    List<Widget> widgets = [];

    if (baseViewModals.viewModels.isNotEmpty) {
      for (var viewModel in baseViewModals.viewModels) {
        MessageHistoryModel model = viewModel.model;
        for (var record in model.records ?? []) {
          if (widget.parentId == record.parentId) {
            widgets.addAll(contactRecordList(model));
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

      return widgets;
    } else {
      return [
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
  }

  List<Widget> contactRecordList(MessageHistoryModel model) {
    List<Widget> widgets = [];

    for (var record in model.records ?? []) {
      Color borderColor = _getBorderColor(record.status ?? "");

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
                  ],
                ),
              ),
              _buildStatusBadge(record.status ?? ""), // Status Badge
            ],
          ),
        ),
      ));
    }

    return widgets;
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String label;

    switch (status.toLowerCase()) {
      case "success":
        badgeColor = AppColor.navBarIconColor;
        label = "Success";
        break;
      case "failed":
        badgeColor = AppColor.motivationCar1Color;
        label = "Failed";
        break;
      case "pending":
        badgeColor = AppColor.selectedItemColor;
        label = "Pending";
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

  Color _getBorderColor(String status) {
    switch (status.toLowerCase()) {
      case "success":
        return AppColor.navBarIconColor;
      case "failed":
        return AppColor.motivationCar1Color;
      case "pending":
        return AppColor.selectedItemColor;
      default:
        return Colors.grey;
    }
  }

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
