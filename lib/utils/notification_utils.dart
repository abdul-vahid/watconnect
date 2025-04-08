import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/views/view/lead_list_view.dart';

import '../services/notifications/local_notification_service.dart';
import '../view_models/user_list_vm.dart';
import 'app_utils.dart';
import 'function_lib.dart';

class NotificationUtil {
  static FirebaseMessaging? _firebaseMessaging;
  static BuildContext? context;
  static bool isInitialized = false;
  void initialize(context) {
    if (isInitialized) {
      return;
    }

    NotificationUtil.context = context;
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging?.requestPermission();
    _firebaseMessaging?.getInitialMessage().then(
      (RemoteMessage? remoteMessage) {
        debug("display notifcation app getInitialMessage");
        if (remoteMessage != null && remoteMessage.notification != null) {
          AppUtils.viewPush(context, LeadListView());
        }
      },
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage? remoteMessage) {
        debug("display notifcation app opened foregroud");
        onMessageReceived(remoteMessage);
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage? remoteMessage) {
        debug("display notifcation app background");

        onMessageReceived(remoteMessage!);
      },
    );

    registerToken();
    if (!isInitialized) {
      isInitialized = true;
    }
  }

  static Future<void> onMessageReceived(RemoteMessage? remoteMessage) {
    print("remote value=>$remoteMessage");
    if (remoteMessage != null) {
      LocalNotificationService.displayNotification(remoteMessage);
    }

    return Future.value();
  }

  static void registerToken() async {
    _firebaseMessaging!.getToken().then((token) {
      debug("registerToken value=> $token");
      UserListViewModel().registerFCMToken(token!).then((value) {
        print("value message notification firebase=>${value}");
      }, onError: (error, stackTrace) {});
    }).catchError((e) {
      debug("Error = $e");
    });
  }
}
