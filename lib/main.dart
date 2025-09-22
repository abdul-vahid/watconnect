// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:whatsapp/models/lead_model.dart';
import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
import 'package:whatsapp/salesforce/controller/template_controller.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
import 'package:whatsapp/services/notifications/local_notification_service.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/view_models/approved_template_vm.dart';
import 'package:whatsapp/view_models/call_view_model.dart';
import 'package:whatsapp/view_models/campaign_chart_vm.dart';
import 'package:whatsapp/view_models/groups_view_model.dart';
import 'package:whatsapp/view_models/lead_controller.dart';
import 'package:whatsapp/view_models/message_controller.dart';
import 'package:whatsapp/view_models/message_list_vm.dart'
    show MessageViewModel;
import 'package:whatsapp/view_models/auto_response_vm.dart';
import 'package:whatsapp/view_models/campaign_count_vm.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/view_models/message_history_vm.dart';
import 'package:whatsapp/view_models/tags_list_vm.dart';
import 'package:whatsapp/view_models/templete_list_vm.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/view_models/user_data_list_vm.dart';
import 'package:whatsapp/view_models/wallet_controller.dart';
import 'package:whatsapp/views/view/whatsapp_chat_screen.dart';
import 'firebase_options.dart';
import 'view_models/campaign_vm.dart';
import 'view_models/chart_list_vm.dart';
import 'view_models/get_user_vm.dart';
import 'view_models/lead_count_vm.dart';
import 'view_models/whatsapp_setting_vm.dart';
import 'views/view/splash_view.dart';

import 'dart:core';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  tz.initializeTimeZones();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Center(
      child: Text(
        "Something went wrong",
        style: TextStyle(color: Colors.red, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  };

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

       
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    // onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
    //   // Handle iOS foreground notification tap here
    //   print("iOS Notification received: $payload");
    // },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null && response.payload!.isNotEmpty) {
        print(
            "onDidReceiveNotificationResponse:::::::::    ${response.payload}");
        _handleSfNotification(_decodePayload(response.payload!));
      }
    },
  );

  runApp(const MyApp());
}




class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColor.navBarIconColor,
    ));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ApprovedTemplateViewModel(context)),
        ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
        ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
        ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
        ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
        ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
        ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
        ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
        ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
        ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
        ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
        ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
        ChangeNotifierProvider(
            create: (_) => WhatsappSettingViewModel(context)),
        ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
        ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
        ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
        ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
        ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
        ChangeNotifierProvider(create: (_) => MessageController()),
        ChangeNotifierProvider(create: (_) => DashBoardController()),
        ChangeNotifierProvider(create: (_) => TemplateController()),
        ChangeNotifierProvider(create: (_) => BusinessNumberController()),
        ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
        ChangeNotifierProvider(
          create: (_) => ChatMessageController(),
        ),
        ChangeNotifierProvider(create: (_) => SfcampaignController()),
        ChangeNotifierProvider(create: (_) => WalletController()),
        ChangeNotifierProvider(create: (_) => LeadController()),
        ChangeNotifierProvider(create: (_) => SfFileUploadController())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        navigatorObservers: [routeObserver],
        title: 'Watconnect',
        theme: ThemeData(
          textTheme: GoogleFonts.kohSantepheapTextTheme(),
          primaryColor: AppColor.navBarIconColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColor.navBarIconColor,
          ),
        ),
        builder: EasyLoading.init(),
        home: const SplashView(),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("message firebaseMessagingBackgroundHandler::: ");
  debug("Background FCM: $message ${message.notification}");

  if (message.notification != null) {
    await Future.delayed(const Duration(milliseconds: 50));
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  LocalNotificationService.displayNotification(message);
}

void _setupInteractedMessage() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    LocalNotificationService.displayNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("onMessageOpenedApp::::   ${message.data}");
    _handleSfNotification(message.data);
  });

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      print("getInitialMessage::::   ${message.data}");
      _handleSfNotification(message.data);
    }
  });
}

Map<String, dynamic> _decodePayload(String payload) {
  payload = payload.replaceAll(RegExp(r'^{|}$'), '');
  final Map<String, dynamic> data = {};
  for (final part in payload.split(',')) {
    final kv = part.split(':');
    if (kv.length == 2) {
      data[kv[0].trim()] = kv[1].trim();
    }
  }
  return data;
}

Future<void> _handleSfNotification(Map<String, dynamic> finalJson) async {
  for (var key in finalJson.keys) {
    print("Key: $key  ->  Value: ${finalJson[key]}");
  }

  final finJson = cleanMap(finalJson);

  print("finalJson:::::::::  $finJson");

  print("finalJson:::::::::  ${finJson['lead_id']}");

  if (finJson.containsKey('lead_id')) {
    String leadId = finJson['lead_id'];
    final ctx = navigatorKey.currentContext;

    // if (ctx!.mounted) return;

    final leadlistvm = Provider.of<LeadListViewModel>(ctx!, listen: false);
    LeadModel? matchedModel;
    final List<LeadModel> pinnedLeads = [];

    // Find pinned leads and matching lead
    for (var viewModel in leadlistvm.viewModels) {
      final leadmodel = viewModel.model;

      if (leadmodel?.records != null) {
        for (var record in leadmodel!.records!) {
          print("record.id::::::::  ${record.id}");
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
      ctx,
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
    // }
  } else {
    final finJson = cleanMap(finalJson);

    print("finJson:::: $finJson");
    final leadId = finJson['RecordId'] ?? "";
    final objName = finJson['sObjectName'] ?? "";

    print(
        "finJson['RecordId']   $finJson     ${finJson.runtimeType}    :: ${finJson['sObjectName']}");

    final ctx = navigatorKey.currentContext;
    log("ctx::::::::: $finJson   $leadId   $objName   ");

    for (var key in finJson.keys) {
      print("Key: $key  ->  Value: ${finJson[key]}");
    }

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
}

Map<String, dynamic> cleanMap(Map raw) {
  final Map<String, dynamic> result = {};

  raw.forEach((key, value) {
    // Clean key
    final newKey = key.toString().replaceAll('"', '');

    // Clean value
    if (value is String) {
      // remove extra quotes if present
      final newValue = value.replaceAll('"', '');
      result[newKey] = newValue;
    } else if (value is Map) {
      // handle nested maps
      result[newKey] = cleanMap(value);
    } else if (value is List) {
      // handle list of maps/strings
      result[newKey] = value.map((e) {
        if (e is Map) return cleanMap(e);
        if (e is String) return e.replaceAll('"', '');
        return e;
      }).toList();
    } else {
      result[newKey] = value;
    }
  });

  return result;
}
