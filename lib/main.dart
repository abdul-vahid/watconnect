import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
import 'package:whatsapp/salesforce/controller/template_controller.dart';
import 'package:whatsapp/services/notifications/local_notification_service.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/utils/notification_utils.dart';
import 'package:whatsapp/view_models/approved_template_vm.dart';
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
import 'firebase_options.dart';
import 'view_models/campaign_vm.dart';
import 'view_models/chart_list_vm.dart';

import 'view_models/get_user_vm.dart';
import 'view_models/lead_count_vm.dart';

import 'view_models/whatsapp_setting_vm.dart';
import 'views/view/splash_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   return const Center(
  //     child: Text(
  //       'Something went wrong!',
  //       style: TextStyle(color: Colors.red),
  //     ),
  //   );
  // };
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // await LocalNotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  debug(
      "Background FCM:  ${message}   ${message.notification}   ${message.notification?.title}");

  if (message.notification != null) {
    debugPrint(
        "Firebase default notification bhi dikh rahi hogi. Cancel karte hain...");
    await Future.delayed(Duration(milliseconds: 50)); // chhota delay
    await FlutterLocalNotificationsPlugin().cancelAll(); // Default hataya
  }

  final imageUrl = message.data['fileUrl'];

  if (imageUrl != null && imageUrl.isNotEmpty) {
    try {
      LocalNotificationService.displayNotification(message);
      // final filePath = await downloadAndSaveImage(imageUrl, 'notif_image.jpg');
      // print("filePath:  remoteMessage:: ${filePath}   ${message}");
      // await showImageNotification(message, filePath);
    } catch (e) {
      debugPrint("Image download failed, fallback to text notification: $e");
      LocalNotificationService.displayNotification(message);
    }
  } else {
    print("inside the elsee::::");
    LocalNotificationService.displayNotification(message);
  }
}
