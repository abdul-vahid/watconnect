import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/view_models/approved_template_vm.dart';
import 'package:whatsapp/view_models/campaign_chart_vm.dart';
import 'package:whatsapp/view_models/groups_view_model.dart';
import 'package:whatsapp/view_models/message_controller.dart';
import 'package:whatsapp/view_models/message_list_vm.dart'
    show MessageViewModel;
import 'package:whatsapp/view_models/auto_response_vm.dart';
import 'package:whatsapp/view_models/campaign_count_vm.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/view_models/message_history_vm.dart';
import 'package:whatsapp/view_models/templete_list_vm.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/view_models/user_data_list_vm.dart';
import 'firebase_options.dart';
import 'view_models/campaign_vm.dart';
import 'view_models/chart_list_vm.dart';

import 'view_models/get_user_vm.dart';
import 'view_models/lead_count_vm.dart';

import 'view_models/whatsapp_setting_vm.dart';
import 'views/view/splash_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   return Center(
  //     child: Text(
  //       'Something went wrong!',
  //       style: TextStyle(color: Colors.red),
  //     ),
  //   );
  // };

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColor.navBarIconColor,
    ));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ApprovedTemplateViewModel(context)),
        ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
        ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
        ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
        ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
        ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
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
        ChangeNotifierProvider(create: (_) => MessageController())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
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
