import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/lead_model.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/views/view/whatsapp_message_view.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    print("inititalise is called");

    const androidInit = AndroidInitializationSettings("@mipmap/ic_launcher");
    const iOSInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) async {
        debugPrint("Notification tapped");
        debugPrint(
            "Payload:   ${details}  ${details.data} ${details.payload}   ${details.payload.runtimeType} ");
        debugPrint("Action ID: ${details.actionId}   ${details.data}");
        debugPrint("Notification ID: ${details.id}");

        if (details.payload == null || details.payload!.isEmpty) {
          return;
        }

        Map<String, dynamic> finJson = {};
        try {
          finJson = jsonDecode(details.payload!);
        } catch (e) {
          debugPrint("Failed to decode payload: $e");
          return;
        }

        debugPrint("finJson::::: $finJson");

        String leadId = finJson['lead_id']?.toString() ?? '';
        if (leadId.isEmpty) {
          debugPrint("No lead_id found in payload.");
          return;
        }

        final ctx = navigatorKey.currentContext!;
        await Provider.of<LeadListViewModel>(ctx, listen: false)
            .fetch()
            .then((val) {
          NavigationFunc(leadId, ctx);
        });
      },
    );
  }

  static Future<void> displayNotification(RemoteMessage message) async {
    print("is this called once::::::::::::::::::::");
    try {
      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      String? imageUrl;
      BigPictureStyleInformation? bigPictureStyle;

      if (message.data.containsKey('fileUrl')) {
        try {
          var urls = (message.data['fileUrl']);
          if (urls.isNotEmpty) {
            imageUrl = urls;
          }
        } catch (e) {
          debugPrint("Error decoding image URL: $e");
        }
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        final String? filePath =
            await _downloadAndSaveFile(imageUrl, 'notif_img.jpg');

        if (filePath != null) {
          bigPictureStyle = BigPictureStyleInformation(
            FilePathAndroidBitmap(filePath),
            largeIcon: FilePathAndroidBitmap(filePath),
            contentTitle: message.notification?.title ?? "",
            summaryText: message.notification?.body ?? "",
          );
        } else {
          debugPrint("Image download failed or returned null.");
        }
      }

      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'spark',
          'Spark',
          channelDescription: 'Spark',
          playSound: true,
          priority: Priority.high,
          importance: Importance.max,
          channelShowBadge: true,
          visibility: NotificationVisibility.public,
          styleInformation: bigPictureStyle,
        ),
        iOS: const DarwinNotificationDetails(),
      );

      print("message>>> data>>> ${message.data}");
      await _notificationsPlugin.show(
        id,
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? '',
        notificationDetails,
        payload: jsonEncode(message.data),
      );

      debugPrint("Notification shown ");
    } catch (e) {
      debugPrint("Error displaying notinfication: $e");
    }
  }

  static Future<String?> _downloadAndSaveFile(
      String url, String fileName) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        debugPrint(
            "Failed to download image. Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Error downloading image: $e");
      return null;
    }
  }

  static FlutterLocalNotificationsPlugin get instance => _notificationsPlugin;

  static List pinnedLeads = [];
  static void NavigationFunc(String leadId, BuildContext cntxt) {
    print("NavigationFunc ::: 1");
    debug("NavigationFunc called with leadId dsfcsf: $leadId");
    LeadModel? matchedModel;
    var leadlistvm = Provider.of<LeadListViewModel>(cntxt, listen: false);

    pinnedLeads = [];

    for (var viewModel in leadlistvm.viewModels) {
      var leadmodel = viewModel.model;
      print("leadmodel:::::   ::   ${leadmodel}");
      print(
          "leadmodel?.records:::::::::: ${leadmodel?.records}  ${leadmodel?.records.length}");
      if (leadmodel?.records != null) {
        for (var record in leadmodel!.records!) {
          if (record.pinned == true) {
            pinnedLeads.add(record);
          }
        }
      }
    }

    for (var viewModel in leadlistvm.viewModels) {
      var leadmodel = viewModel.model;
      print("leadmodel:::::   ::   ${leadmodel}");
      print(
          "leadmodel?.records:::::::::: ${leadmodel?.records}  ${leadmodel?.records.length}");
      if (leadmodel?.records != null) {
        for (var record in leadmodel!.records!) {
          if (record.id.toString() == leadId) {
            matchedModel = record;
            break;
          }
        }
      }
    }

    if (matchedModel == null) {
      debug("No matching lead found for ID: $leadId");
      return;
    } else {
      print("model found::::::::::: ${matchedModel.firstname}");
    }
    print("From Page ::: 1");
    Navigator.push(
      cntxt,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          pinnedLeads: pinnedLeads,
          leadName:
              "${matchedModel!.firstname ?? ""} ${matchedModel.lastname ?? ""}",
          wpnumber: matchedModel.whatsappNumber!.contains("+")
              ? matchedModel.whatsappNumber ?? ""
              : "${matchedModel.countryCode}${matchedModel.whatsappNumber ?? ""}",
          id: matchedModel.id,
          model: matchedModel,
        ),
      ),
    );
  }
}
