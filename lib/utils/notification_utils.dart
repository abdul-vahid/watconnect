// notification_util.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/views/view/whatsapp_message_view.dart';
import '../models/lead_model.dart';
import '../services/notifications/local_notification_service.dart';
import '../view_models/lead_list_vm.dart';
import '../view_models/user_list_vm.dart';

import 'function_lib.dart';

class NotificationUtil {
  static FirebaseMessaging? _firebaseMessaging;
  BuildContext context;
  static bool isInitialized = false;

  NotificationUtil(this.context);

  void initialize() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    LocalNotificationService.initialize();

    registerToken();
    if (isInitialized) return;

    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging?.requestPermission();

    _firebaseMessaging
        ?.getInitialMessage()
        .then((RemoteMessage? remoteMessage) async {
      debug(
          "getInitialMessage triggered (terminated satae)${remoteMessage?.data}");
      if (remoteMessage != null) {
        final leadId = remoteMessage.data['lead_id'];
        if (leadId != null) {
          await Provider.of<LeadListViewModel>(context, listen: false)
              .fetch()
              .then((val) {
            NavigationFunc(leadId.toString(), context);
          });
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) async {
      debug("Foreground  received >>> ${remoteMessage?.data} ");
      // if (remoteMessage != null) {
      //   final leadId = remoteMessage.data['lead_id'];
      //   if (leadId != null) {
      //     await Provider.of<LeadListViewModel>(context, listen: false)
      //         .fetch()
      //         .then((val) {
      //       NavigationFunc(leadId.toString(), context);
      //     });
      //   }
      // }
    });

    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage? remoteMessage) async {
      debug("onMessageOpenedApp triggered (background)");
      final leadId = remoteMessage?.data['lead_id'];
      if (leadId != null) {
        await Provider.of<LeadListViewModel>(context, listen: false)
            .fetch()
            .then((val) {
          NavigationFunc(leadId.toString(), context);
        });
      }
    });

    isInitialized = true;
  }

  static Future<void> onMessageReceived(RemoteMessage remoteMessage) async {
    debug("remote value => $remoteMessage");
    LocalNotificationService.displayNotification(remoteMessage);
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

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    debug("Background FCM: ${message.notification?.title}");
    LocalNotificationService.displayNotification(message);
  }

  void NavigationFunc(String leadId, BuildContext cntxt) {
    debug("NavigationFunc called with leadId: $leadId");
    LeadModel? matchedModel;
    var leadlistvm = Provider.of<LeadListViewModel>(cntxt, listen: false);

    for (var viewModel in leadlistvm.viewModels) {
      debug("Found lead ID: \${viewModel.model.id}");
      if (viewModel.model.id.toString() == leadId) {
        matchedModel = viewModel.model;
        break;
      }
    }

    if (matchedModel == null) {
      debug("No matching lead found for ID: \$leadId");
      return;
    }

    Navigator.push(
      cntxt,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          leadName: matchedModel?.firstname ??
              matchedModel?.lastname ??
              "No Name Available",
          wpnumber: matchedModel!.whatsapp_number!.contains("+")
              ? matchedModel.whatsapp_number ?? ""
              : "${matchedModel.countryCode}${matchedModel.whatsapp_number ?? ""}",
          model: matchedModel,
        ),
      ),
    );
  }

  static Future<void> deleteFCMTokenOnLogout() async {
    try {
      await _firebaseMessaging?.deleteToken();
    } catch (e) {
      debugPrint("Failed to delete FCM token: $e");
    }
  }
}
