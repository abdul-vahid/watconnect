// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:whatsapp/utils/app_fonts.dart';
import 'package:whatsapp/views/view/call_history_screen.dart'
    show formatDateTime, formatDuration;
import '../../../models/call_history_model.dart';

void showCallDialog(
  BuildContext context,
  List<CallHistoryData> callHistoryList,
  VoidCallback onCallPressed,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Call History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onCallPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Call", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: callHistoryList.isEmpty
                    ? const Center(
                        child: Text(
                        "No Call History Availabe...",
                        style: TextStyle(
                            fontFamily: AppFonts.medium, fontSize: 15),
                        textAlign: TextAlign.center,
                      ))
                    : ListView.separated(
                        itemCount: callHistoryList.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Colors.grey),
                        itemBuilder: (context, index) {
                          final call = callHistoryList[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            leading: Transform.rotate(
                              angle: call.status == "Incoming" ? 45 : 180,
                              child: Icon(
                                FontAwesomeIcons.arrowDown,
                                color: call.status == "Incoming"
                                    ? Colors.green
                                    : Colors.red,
                                size: 16,
                              ),
                            ),
                            title: Text(
                              call.name ?? call.whatsappNumber ?? "",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "${formatDateTime(int.tryParse(call.startTime ?? "") ?? 0)} - "
                              "${(call.endTime?.isNotEmpty ?? false) ? formatDateTime(int.tryParse(call.endTime!) ?? 0) : "Not Answered"}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                            trailing: Text(
                              formatDuration(call.duration ?? 0),
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
