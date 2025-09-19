// ignore_for_file: avoid_print, use_build_context_synchronously

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
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/views/view/whatsapp_chat_screen.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    debugPrint("Local notifications initialized");

    const androidInit = AndroidInitializationSettings("@mipmap/ic_launcher");
    const iOSInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  static Future<void> _onNotificationResponse(
      NotificationResponse details) async {
    debugPrint("Notification tapped: ${details.payload}");

    if (details.payload == null || details.payload!.isEmpty) {
      return;
    }

    Map<String, dynamic> finJson;
    try {
      finJson = jsonDecode(details.payload!);
    } catch (e) {
      debugPrint("Failed to decode payload: $e");
      return;
    }

    debugPrint("Notification payload: $finJson");

    try {
      if (finJson.containsKey('lead_id')) {
        await _handleLeadNotification(finJson);
      } else {
        await _handleSfNotification(finJson);
      }
    } catch (e, stackTrace) {
      debugPrint("Error handling notification response: $e, $stackTrace");
    }
  }

  static Future<void> _handleLeadNotification(
      Map<String, dynamic> finJson) async {
    final leadId = finJson['lead_id']?.toString() ?? '';
    if (leadId.isEmpty) {
      debugPrint("No lead_id found in payload.");
      return;
    }

    final ctx = navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      await Provider.of<LeadListViewModel>(ctx, listen: false).fetch();
      NavigationFunc(leadId, ctx);
    }
  }

  static Future<void> _handleSfNotification(
      Map<String, dynamic> finJson) async {
    final leadId = finJson['RecordId'];
    final objName = finJson['sObjectName'];

    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    final dashBoardController =
        Provider.of<DashBoardController>(ctx, listen: false);
    await dashBoardController.drawerListApiCall(type: objName);

    final pinnedConfigItems = dashBoardController.drawerListItems
        .where((item) => item.isPinned == true)
        .toList();

    final matchedItem = dashBoardController.drawerListItems.firstWhere(
      (item) => item.id == leadId,
    );

    if (ctx.mounted) {
      final cmProvider = Provider.of<ChatMessageController>(ctx, listen: false);
      final dbProvider = Provider.of<DashBoardController>(ctx, listen: false);

      final phNum =
          "${matchedItem.countryCode ?? ""}${matchedItem.whatsappNumber ?? ""}";
      dbProvider.setSelectedContaactInfo(matchedItem);
      await cmProvider.messageHistoryApiCall(userNumber: phNum);

      if (ctx.mounted) {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (context) =>
                SfMessageChatScreen(pinnedLeadsList: pinnedConfigItems),
          ),
        );
      }
    }
  }

  static Future<void> displayNotification(RemoteMessage message) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      BigPictureStyleInformation? bigPictureStyle;

      final imageUrl = message.data['fileUrl'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final filePath = await _downloadAndSaveFile(imageUrl, 'notif_img.jpg');
        if (filePath != null) {
          bigPictureStyle = BigPictureStyleInformation(
            FilePathAndroidBitmap(filePath),
            largeIcon: FilePathAndroidBitmap(filePath),
            contentTitle: message.notification?.title ?? "",
            summaryText: message.notification?.body ?? "",
          );
        }
      }

      final notificationDetails = NotificationDetails(
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

      await _notificationsPlugin.show(
        id,
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? '',
        notificationDetails,
        payload: jsonEncode(message.data),
      );

      debugPrint("Notification displayed successfully");
    } catch (e, stackTrace) {
      debugPrint("Error displaying notification: $e, $stackTrace");
    }
  }

  static Future<String?> _downloadAndSaveFile(
      String url, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }

      debugPrint(
          "Failed to download image. Status Code: ${response.statusCode}");
      return null;
    } catch (e) {
      debugPrint("Error downloading image: $e");
      return null;
    }
  }

  static FlutterLocalNotificationsPlugin get instance => _notificationsPlugin;

  static void NavigationFunc(String leadId, BuildContext cntxt) {
    debug("NavigationFunc called with leadId: $leadId");

    if (!cntxt.mounted) return;

    final leadlistvm = Provider.of<LeadListViewModel>(cntxt, listen: false);
    LeadModel? matchedModel;
    final List<LeadModel> pinnedLeads = [];

    // Find pinned leads and matching lead
    for (var viewModel in leadlistvm.viewModels) {
      final leadmodel = viewModel.model;

      if (leadmodel?.records != null) {
        for (var record in leadmodel!.records!) {
          if (record.pinned == true) {
            pinnedLeads.add(record);
          }
          if (record.id.toString() == leadId) {
            matchedModel = record;
          }
        }
      }
    }

    if (matchedModel == null) {
      debug("No matching lead found for ID: $leadId");
      return;
    }

    final wpNumber = matchedModel.whatsappNumber ?? "";
    final formattedWpNumber = wpNumber.contains("+")
        ? wpNumber
        : "${matchedModel.countryCode}$wpNumber";

    Navigator.push(
      cntxt,
      MaterialPageRoute(
        builder: (_) => WhatsappChatScreen(
          pinnedLeads: pinnedLeads,
          leadName:
              "${matchedModel?.firstname ?? ""} ${matchedModel?.lastname ?? ""}",
          wpnumber: formattedWpNumber,
          id: matchedModel?.id,
          model: matchedModel,
        ),
      ),
    );
  }
}
