// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:whatsapp/salesforce/model/sfCall_history_model.dart';

void showSfCallDialog(
  String leadname,
  BuildContext context,
  List<SfCallHistoryModel> sfcallHistoryList,
  VoidCallback onCallPressed,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      leadname,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.black),
                  )
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Call History",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.call, color: Colors.white),
                label:
                    const Text("Call", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: onCallPressed,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: sfcallHistoryList.isEmpty
                    ? const Center(
                        child: Text(
                          "No Call History Available",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      )
                    : ListView.separated(
                        itemCount: sfcallHistoryList.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: Colors.grey.shade300),
                        itemBuilder: (context, index) {
                          final call = sfcallHistoryList[index];

                          bool isIncoming = call.statusC == "Incoming";
                          IconData icon = isIncoming
                              ? FontAwesomeIcons.arrowDown
                              : FontAwesomeIcons.arrowUp;

                          Color iconColor =
                              isIncoming ? Colors.green : Colors.red;

                          bool hasAudioUrl = call.audioUrl != null &&
                              call.audioUrl!.isNotEmpty;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: iconColor.withOpacity(0.1),
                              child: Icon(icon, size: 16, color: iconColor),
                            ),
                            title: Text(
                              isIncoming ? "Incoming Call" : "Outgoing Call",
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              "${sfFromatCallDate(call.startTime ?? "")} - "
                              "${(call.endTime?.isNotEmpty ?? false) ? sfFromatCallDate(call.endTime!) : "Not Answered"}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!hasAudioUrl && (call.duration ?? 0) > 0)
                                  Text(
                                    "${formatDuration(call.duration ?? 0)}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                if (hasAudioUrl)
                                  IconButton(
                                    icon: const Icon(Icons.download,
                                        size: 22, color: Colors.blue),
                                    onPressed: () async {
                                      await _downloadAndOpenAudio(
                                          call.audioUrl!);
                                    },
                                  ),
                              ],
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

String formatDuration(int seconds) {
  debugPrint("Duration seconds: $seconds");

  if (seconds == null || seconds <= 0) {
    return "0s";
  }

  final duration = Duration(seconds: seconds);

  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final secs = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return "${hours}h ${twoDigits(minutes)}m ${twoDigits(secs)}s";
  } else if (minutes > 0) {
    return "${minutes}m ${twoDigits(secs)}s";
  } else {
    return "${secs}s";
  }
}

String sfFromatCallDate(String isoString) {
  try {
    DateTime dateTime = DateTime.parse(isoString).toLocal();
    return DateFormat("d MMM, h:mm").format(dateTime);
  } catch (e) {
    return isoString;
  }
}

Future<void> _downloadAndOpenAudio(String url) async {
  try {
    Directory directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw Exception("Unsupported platform");
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    String fileName = url.split('/').last;
    String filePath = '${directory.path}/$fileName';

    Dio dio = Dio();
    await dio.download(url, filePath, onReceiveProgress: (received, total) {
      if (total != -1) {
        debugPrint(
            'Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
      }
    });

    await OpenFilex.open(filePath);
  } catch (e) {
    debugPrint("Download error: $e");
  }
}
