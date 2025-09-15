// ignore_for_file: avoid_print, use_build_context_synchronously, non_constant_identifier_names

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/views/view/whatsapp_chat_screen.dart';

import 'function_lib.dart';
import '../models/lead_model.dart';
import '../services/notifications/local_notification_service.dart';
import '../view_models/lead_list_vm.dart';
import '../view_models/user_list_vm.dart';

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
          "getInitialMessage triggered (terminated state)   ${remoteMessage?.notification} ${remoteMessage?.data}");
      if (remoteMessage != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String sfAccessToken =
            prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
        if (sfAccessToken.isEmpty) {
          final leadId = remoteMessage.data['lead_id'];
          if (leadId != null) {
            await Provider.of<LeadListViewModel>(navigatorKey.currentContext!,
                    listen: false)
                .fetch()
                .then((val) {
              NavigationFunc(leadId.toString(), navigatorKey.currentContext!);
            });
          }
        } else {
          final leadId = remoteMessage.data['user_id'];
          final objName = remoteMessage.data['sObjectName'];

          DashBoardController dashBoardController =
              Provider.of(context, listen: false);
          await dashBoardController.drawerListApiCall(type: objName);
          List<SfDrawerItemModel> pinnedConfigItems = [];
          pinnedConfigItems.addAll(
            dashBoardController.drawerListItems
                .where((item) => item.isPinned == true),
          );
          for (var item in dashBoardController.drawerListItems) {
            if (item.id == leadId) {
              var drawerListItem = item;

              ChatMessageController cmProvider =
                  Provider.of(context, listen: false);
              DashBoardController dbProvider =
                  Provider.of(context, listen: false);
              String phNum =
                  "${drawerListItem.countryCode ?? ""}${drawerListItem.whatsappNumber ?? ""}";
              dbProvider.setSelectedContaactInfo(drawerListItem);
              await cmProvider.messageHistoryApiCall(
                userNumber: phNum,
              );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SfMessageChatScreen(
                            pinnedLeadsList: pinnedConfigItems,
                          )));

              return;
            }
          }
        }
      } else {
        // print("remote messha eos is nullllllllllllll");
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

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String sfAccessToken =
          prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      if (sfAccessToken.isEmpty) {
        final leadId = remoteMessage?.data['lead_id'];

        if (leadId != null) {
          await Provider.of<LeadListViewModel>(navigatorKey.currentContext!,
                  listen: false)
              .fetch()
              .then((val) {
            NavigationFunc(leadId.toString(), navigatorKey.currentContext!);
          });
        }
      } else {
        final leadId = remoteMessage?.data['user_id'];
        final objName = remoteMessage?.data['sObjectName'];

        DashBoardController dashBoardController =
            Provider.of(context, listen: false);
        await dashBoardController.drawerListApiCall(type: objName);
        List<SfDrawerItemModel> pinnedConfigItems = [];
        pinnedConfigItems.addAll(
          dashBoardController.drawerListItems
              .where((item) => item.isPinned == true),
        );
        for (var item in dashBoardController.drawerListItems) {
          if (item.id == leadId) {
            var drawerListItem = item;

            ChatMessageController cmProvider =
                Provider.of(context, listen: false);
            DashBoardController dbProvider =
                Provider.of(context, listen: false);
            String phNum =
                "${drawerListItem.countryCode ?? ""}${drawerListItem.whatsappNumber ?? ""}";
            dbProvider.setSelectedContaactInfo(drawerListItem);
            await cmProvider.messageHistoryApiCall(
              userNumber: phNum,
            );
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SfMessageChatScreen(
                          pinnedLeadsList: pinnedConfigItems,
                        )));

            return;
          }
        }
      }
    });

    isInitialized = true;
  }

  static Future<void> registerToken() async {
    try {
      final token = await _firebaseMessaging?.getToken();

      debug("registerToken value => $token");

      if (token == null) {
        debug("FCM token is null");
        return;
      }
      String deviceId = await getDeviceId();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString(SharedPrefsConstants.deviceId, deviceId);

      final context = navigatorKey.currentContext;
      if (context == null) {
        debug("Navigator context is null");
        return;
      }

      final drProvider =
          Provider.of<DashBoardController>(context, listen: false);

      if (drProvider.fromSalesForce) {
        drProvider.setSfFcmToken(token);
        drProvider.setSfDeviceToken(deviceId);
        debug("Skipping FCM registration due to fromSalesForce flag");
      } else {
        await UserListViewModel().registerFCMToken(token, deviceId);
        debug("FCM token registered to backend => $token");
      }
    } catch (e, stackTrace) {
      debug("Error in registerToken: $e   $stackTrace");
    }
  }

  List pinnedLeads = [];
  void NavigationFunc(String leadId, BuildContext cntxt) {
    debug("NavigationFunc called with leadId: $leadId");
    LeadModel? matchedModel;
    var leadlistvm = Provider.of<LeadListViewModel>(cntxt, listen: false);
    for (var viewModel in leadlistvm.viewModels) {
      var leadmodel = viewModel.model;
      print("leadmodel:::::   ::   $leadmodel");
      print(
          "leadmodel?.records:::::::::: ${leadmodel?.records}  ${leadmodel?.records.length}");
      pinnedLeads = [];

      if (leadmodel?.records != null) {
        for (var record in leadmodel!.records!) {
          if (record.pinned == true) {
            pinnedLeads.add(record);
          }
        }
      }
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
    }
    Navigator.push(
      cntxt,
      MaterialPageRoute(
        builder: (_) => WhatsappChatScreen(
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

  print("tmage notification is hsown here");

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
