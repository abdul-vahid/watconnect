// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/models/lead_model.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/view_models/user_list_vm.dart';

class NotificationUtil {
  static FirebaseMessaging? _firebaseMessaging;
  final BuildContext context;
  static bool isInitialized = false;

  NotificationUtil(this.context);

  void initialize() {
    if (isInitialized) return;

    // LocalNotificationService.initialize();
    registerToken();

    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging?.requestPermission();

    // _setupMessageHandlers();
    // isInitialized = true;
  }

  // void _setupMessageHandlers() {
  //   _firebaseMessaging?.getInitialMessage().then(_handleInitialMessage);

  //   FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

  //   FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  // }

  // Future<void> _handleInitialMessage(RemoteMessage? remoteMessage) async {
  //   debug(
  //       "getInitialMessage triggered (terminated state) ${remoteMessage?.data}");

  //   if (remoteMessage != null) {
  //     await _processMessage(remoteMessage);
  //   }
  // }

  // Future<void> _handleForegroundMessage(RemoteMessage remoteMessage) async {
  //   debugPrint("Foreground received >>> ${remoteMessage.data}");

  //   final imageUrl = remoteMessage.data['fileUrl'];

  //   try {
  //     if (imageUrl != null && imageUrl.isNotEmpty) {
  //       final filePath =
  //           await downloadAndSaveImage(imageUrl, 'notif_image.jpg');
  //       await showImageNotification(remoteMessage, filePath);
  //     } else {
  //       // LocalNotificationService.displayNotification(remoteMessage);
  //     }
  //   } catch (e) {
  //     debugPrint("Image download failed, fallback to text notification: $e");
  //     // LocalNotificationService.displayNotification(remoteMessage);
  //   }
  // }

  // Future<void> _handleBackgroundMessage(RemoteMessage? remoteMessage) async {
  //   debugPrint(
  //       "onMessageOpenedApp triggered (background) ${remoteMessage?.data}");

  //   if (remoteMessage != null) {
  //     await _processMessage(remoteMessage);
  //   }
  // }

  // Future<void> _processMessage(RemoteMessage remoteMessage) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final sfAccessToken =
  //       prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

  //   if (sfAccessToken.isEmpty) {
  //     await _handleNonSfUser(remoteMessage);
  //   } else {
  //     await _handleSfUser(remoteMessage);
  //   }
  // }

  // Future<void> _handleNonSfUser(RemoteMessage remoteMessage) async {
  //   final leadId = remoteMessage.data['lead_id'];
  //   if (leadId != null) {
  //     final ctx = navigatorKey.currentContext;
  //     if (ctx != null && ctx.mounted) {
  //       await Provider.of<LeadListViewModel>(ctx, listen: false).fetch();
  //       NavigationFunc(leadId.toString(), ctx);
  //     }
  //   }
  // }

  // Future<void> _handleSfUser(RemoteMessage remoteMessage) async {
  //   final leadId = remoteMessage.data['user_id'];
  //   final objName = remoteMessage.data['sObjectName'];
  //   print("Salesforce leadId:::::  $leadId");

  //   if (leadId == null) return;

  //   try {
  //     final dashBoardController =
  //         Provider.of<DashBoardController>(context, listen: false);
  //     await dashBoardController.drawerListApiCall(type: objName);

  //     final pinnedConfigItems = dashBoardController.drawerListItems
  //         .where((item) => item.isPinned == true)
  //         .toList();

  //     final matchedItem = dashBoardController.drawerListItems.firstWhere(
  //       (item) => item.id == leadId,
  //     );

  //     if (context.mounted) {
  //       final cmProvider =
  //           Provider.of<ChatMessageController>(context, listen: false);
  //       final dbProvider =
  //           Provider.of<DashBoardController>(context, listen: false);

  //       final phNum =
  //           "${matchedItem.countryCode ?? ""}${matchedItem.whatsappNumber ?? ""}";
  //       dbProvider.setSelectedContaactInfo(matchedItem);
  //       await cmProvider.messageHistoryApiCall(userNumber: phNum);

  //       if (context.mounted) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) =>
  //                 SfMessageChatScreen(pinnedLeadsList: pinnedConfigItems),
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint("Error handling SF user: $e, $stackTrace");
  //   }
  // }

  static Future<void> registerToken() async {
    try {
      final token = await _firebaseMessaging?.getToken();
      debug("registerToken value => $token");

      if (token == null) {
        debug("FCM token is null");
        return;
      }

      final deviceId = await getDeviceId();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedPrefsConstants.deviceId, deviceId);

      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        debug("Navigator context is null or not mounted");
        return;
      }

      final drProvider =
          Provider.of<DashBoardController>(context, listen: false);

      if (drProvider.fromSalesForce) {
        drProvider.setSfFcmToken(token);
        drProvider.setSfDeviceToken(deviceId);
        await UserListViewModel().registerFCMToken(token, deviceId);
        debug("Skipping FCM registration due to fromSalesForce flag");
      } else {
        await UserListViewModel().registerFCMToken(token, deviceId);
        debug("FCM token registered to backend => $token");
      }
    } catch (e, stackTrace) {
      debug("Error in registerToken: $e, $stackTrace");
    }
  }

  // void NavigationFunc(String leadId, BuildContext cntxt) {
  //   debug("NavigationFunc called with leadId: $leadId");

  //   if (!cntxt.mounted) return;

  //   final leadlistvm = Provider.of<LeadListViewModel>(cntxt, listen: false);
  //   LeadModel? matchedModel;
  //   final List<LeadModel> pinnedLeads = [];

  //   // Find pinned leads and matching lead
  //   for (var viewModel in leadlistvm.viewModels) {
  //     final leadmodel = viewModel.model;

  //     if (leadmodel?.records != null) {
  //       for (var record in leadmodel!.records!) {
  //         if (record.pinned == true) {
  //           pinnedLeads.add(record);
  //         }
  //         if (record.id.toString() == leadId) {
  //           matchedModel = record;
  //         }
  //       }
  //     }
  //   }

  //   if (matchedModel == null) {
  //     debug("No matching lead found for ID: $leadId");
  //     return;
  //   }

  //   final wpNumber = matchedModel.whatsappNumber ?? "";
  //   final formattedWpNumber = wpNumber.contains("+")
  //       ? wpNumber
  //       : "${matchedModel.countryCode}$wpNumber";

  //   Navigator.push(
  //     cntxt,
  //     MaterialPageRoute(
  //       builder: (_) => WhatsappChatScreen(
  //         pinnedLeads: pinnedLeads,
  //         leadName:
  //             "${matchedModel?.firstname ?? ""} ${matchedModel?.lastname ?? ""}",
  //         wpnumber: formattedWpNumber,
  //         id: matchedModel?.id,
  //         model: matchedModel,
  //       ),
  //     ),
  //   );
  // }

  static Future<void> deleteFCMTokenOnLogout() async {
    try {
      debug("Deleting FCM token");
      await _firebaseMessaging?.deleteToken();
      debug("Token deleted successfully");
    } catch (e) {
      debugPrint("Failed to delete FCM token: $e");
    }
  }
}

@pragma('vm:entry-point')
Future<String> downloadAndSaveImage(String url, String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    }
    throw Exception('Failed to download image: ${response.statusCode}');
  } catch (e) {
    debugPrint("Error downloading image: $e");
    rethrow;
  }
}

// @pragma('vm:entry-point')
// Future<void> showImageNotification(
//     RemoteMessage message, String filePath) async {
//   try {
//     // final bigPictureStyleInformation = BigPictureStyleInformation(
//     //   FilePathAndroidBitmap(filePath),
//     //   largeIcon: FilePathAndroidBitmap(filePath),
//     //   contentTitle: message.notification?.title ?? '',
//     //   summaryText: message.notification?.body ?? '',
//     // );

//     // final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//     //   'spark',
//     //   'Spark',
//     //   channelDescription: 'spark',
//     //   styleInformation: bigPictureStyleInformation,
//     //   importance: Importance.max,
//     //   priority: Priority.high,
//     // );

//     // final platformChannelSpecifics =
//     //     NotificationDetails(android: androidPlatformChannelSpecifics);

//     // await LocalNotificationService.instance.show(
//     //   0,
//     //   message.notification?.title,
//     //   message.notification?.body,
//     //   platformChannelSpecifics,
//     // );
//   } catch (e) {
//     debugPrint("Error showing image notification: $e");
//     // Fallback to regular notification
//     // LocalNotificationService.displayNotification(message);
//   }
// }
