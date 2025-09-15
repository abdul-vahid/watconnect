// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/models/call_history_model.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_fonts.dart';
import 'package:whatsapp/view_models/call_view_model.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  List<CallHistoryData> callHistoryList = [];
  bool showLoading = false;
  bool updateLoader = false;
  // ignore: prefer_typing_uninitialized_variables
  var callHistoryVm;
  @override
  void initState() {
    historyApiCall();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    callHistoryVm = Provider.of<CallsViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
        title: const Text(
          "Call History",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      body: updateLoader
          ? const Center(child: CircularProgressIndicator())
          : callHistoryList.isEmpty
              ? const Center(
                  child: Text(
                    "No Call History Available...",
                    style: TextStyle(fontFamily: AppFonts.medium, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 28.0),
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
                    child: ListView.separated(
                      itemCount: callHistoryList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: Transform.rotate(
                              angle: callHistoryList[index].status == "Incoming"
                                  ? 45
                                  : 180,
                              child: Icon(
                                FontAwesomeIcons.arrowDown,
                                color:
                                    callHistoryList[index].status == "Incoming"
                                        ? Colors.green
                                        : Colors.red,
                                size: 16,
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  callHistoryList[index].name ??
                                      callHistoryList[index].whatsappNumber ??
                                      "",
                                  style: const TextStyle(
                                    fontFamily: AppFonts.semiBold,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  "${formatDateTime(int.parse(callHistoryList[index].startTime ?? ""))} - ${callHistoryList[index].endTime?.isNotEmpty == true ? formatDateTime(int.parse(callHistoryList[index].endTime!)) : "Not Answered"}",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                              ],
                            ),
                            trailing: Text(formatDuration(
                                callHistoryList[index].duration ?? 0)),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
    );
  }

  Future<void> historyApiCall() async {
    await Provider.of<CallsViewModel>(context, listen: false)
        .getCallHistory()
        .then((onValue) {
      setState(() {
        updateLoader = true;
      });

      callHistoryList = [];

      for (var viewModel in callHistoryVm.viewModels) {
        var leadmodel = viewModel.model;
        print("leadmodel:::::::  $leadmodel   ${leadmodel.records}");
        if (leadmodel?.records != null) {
          for (var record in leadmodel!.records!) {
            callHistoryList.add(record);
          }
        }
      }

      setState(() {
        updateLoader = false;
      });
    });
  }
}

String formatDuration(int seconds) {
  if (seconds < 60) {
    return "$seconds sec";
  } else if (seconds < 3600) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes min${remainingSeconds > 0 ? " $remainingSeconds sec" : ""}";
  } else {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return "$hours hr${minutes > 0 ? " $minutes min" : ""}";
  }
}

String formatDateTime(int timestamp) {
  // Use the timestamp directly (milliseconds)
  final dateTime = DateTime.fromMillisecondsSinceEpoch(
    timestamp * 1000,
  );
  final now = DateTime.now();

  final isToday = dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day;

  final timeFormat = DateFormat('h:mm a');
  final dateFormat = DateFormat('d MMM, h:mm a');

  return isToday ? timeFormat.format(dateTime) : dateFormat.format(dateTime);
}
