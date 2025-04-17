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

import '../../utils/app_utils.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
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
            "Payload: ${details.payload}   ${details.payload.runtimeType} ");
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

  static void onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    BuildContext? context = AppUtils.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title ?? ""),
          content: Text(body ?? ""),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  static Future<void> displayNotification(RemoteMessage message) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      String? imageUrl;
      BigPictureStyleInformation? bigPictureStyle;

      if (message.data.containsKey('urls')) {
        try {
          List<dynamic> urls = jsonDecode(message.data['urls']);
          if (urls.isNotEmpty && urls[0] != null) {
            imageUrl = urls[0];
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
          'i_digi_school',
          'iDigiSchool',
          channelDescription: 'iDigiSchool Notifications',
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
      debugPrint("Error displaying notification: $e");
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

  static void NavigationFunc(String leadId, BuildContext cntxt) {
    debug("NavigationFunc called with leadId dsfcsf: $leadId");
    LeadModel? matchedModel;
    var leadlistvm = Provider.of<LeadListViewModel>(cntxt, listen: false);

    for (var viewModel in leadlistvm.viewModels) {
      debug("Found lead ID: ${viewModel.model.id}");
      if (viewModel.model.id.toString() == leadId) {
        matchedModel = viewModel.model;
        break;
      }
    }

    if (matchedModel == null) {
      debug("No matching lead found for ID: $leadId");
      return;
    }

    Navigator.push(
      cntxt,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          leadName: "${matchedModel!.firstname} ${matchedModel.lastname}",
          wpnumber: matchedModel.whatsapp_number!.contains("+")
              ? matchedModel.whatsapp_number ?? ""
              : "${matchedModel.countryCode}${matchedModel.whatsapp_number ?? ""}",
          id: matchedModel.id,
        ),
      ),
    );
  }
}
