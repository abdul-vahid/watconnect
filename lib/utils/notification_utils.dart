import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/main.dart';

import 'function_lib.dart';
import '../models/lead_model.dart';
import '../services/notifications/local_notification_service.dart';
import '../view_models/lead_list_vm.dart';
import '../view_models/user_list_vm.dart';
import '../views/view/whatsapp_message_view.dart';

class NotificationUtil {
  static FirebaseMessaging? _firebaseMessaging;
  BuildContext context;
  static bool isInitialized = false;

  NotificationUtil(this.context);

  void initialize() {
    LocalNotificationService.initialize();
    registerToken();

    if (isInitialized) return;

    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging?.requestPermission();

    _firebaseMessaging
        ?.getInitialMessage()
        .then((RemoteMessage? remoteMessage) async {
      debug(
          "getInitialMessage triggered (terminated state) ${remoteMessage?.data}");
      if (remoteMessage != null) {
        final leadId = remoteMessage.data['lead_id'];
        if (leadId != null) {
          await Provider.of<LeadListViewModel>(navigatorKey.currentContext!,
                  listen: false)
              .fetch()
              .then((val) {
            NavigationFunc(leadId.toString(), navigatorKey.currentContext!);
          });
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) async {
      debugPrint("Foreground received >>> ${remoteMessage?.data}");

      if (remoteMessage != null) {
        final imageUrl = remoteMessage.data['fileUrl'];

        if (imageUrl != null && imageUrl.isNotEmpty) {
          try {
            final filePath =
                await downloadAndSaveImage(imageUrl, 'notif_image.jpg');
            print("filePath: $filePath, remoteMessage: $remoteMessage");
            await showImageNotification(remoteMessage, filePath);
          } catch (e) {
            debugPrint(
                "Image download failed, fallback to text notification: $e");
            LocalNotificationService.displayNotification(remoteMessage);
          }
        } else {
          debugPrint("Displaying text notification");
          LocalNotificationService.displayNotification(remoteMessage);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage? remoteMessage) async {
      debugPrint(
          "onMessageOpenedApp triggered (background)  ${remoteMessage?.data}");
      final leadId = remoteMessage?.data['lead_id'];

      if (leadId != null) {
        await Provider.of<LeadListViewModel>(navigatorKey.currentContext!,
                listen: false)
            .fetch()
            .then((val) {
          NavigationFunc(leadId.toString(), navigatorKey.currentContext!);
        });
      }
    });

    isInitialized = true;
  }

  static void registerToken() async {
    _firebaseMessaging?.getToken().then((token) {
      debug("registerToken value => $token");
      UserListViewModel().registerFCMToken(token!).then((value) {
        debug("FCM token registered to backend => $value");
      }, onError: (error, stackTrace) {
        debug("FCM token registration error => $error");
      });
    }).catchError((e) {
      debug("FCM getToken error => $e");
    });
  }

  void NavigationFunc(String leadId, BuildContext cntxt) {
    debug("NavigationFunc called with leadId: $leadId");
    LeadModel? matchedModel;
    var leadlistvm = Provider.of<LeadListViewModel>(cntxt, listen: false);
    for (var viewModel in leadlistvm.viewModels) {
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

  static Future<void> deleteFCMTokenOnLogout() async {
    try {
      print("deleting the token::::");
      _firebaseMessaging?.deleteToken().then((_) {
        print("Token deleted");
      }).catchError((e) {
        print("Error deleting token: $e");
      });
    } catch (e) {
      debugPrint("Failed to delete FCM token: $e");
    }
  }
}

@pragma('vm:entry-point')
Future<String> downloadAndSaveImage(String url, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  final response = await http.get(Uri.parse(url));
  final file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

@pragma('vm:entry-point')
Future<void> showImageNotification(
    RemoteMessage message, String filePath) async {
  final BigPictureStyleInformation bigPictureStyleInformation =
      BigPictureStyleInformation(
    FilePathAndroidBitmap(filePath),
    largeIcon: FilePathAndroidBitmap(filePath),
    contentTitle: message.notification?.title ?? '',
    summaryText: message.notification?.body ?? '',
  );

  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'spark',
    'Spark',
    channelDescription: 'spark',
    styleInformation: bigPictureStyleInformation,
    importance: Importance.max,
    priority: Priority.high,
  );

  final NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await LocalNotificationService.instance.show(
    0,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
  );
}
