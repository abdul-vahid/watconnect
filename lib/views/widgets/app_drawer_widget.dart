// ignore_for_file: prefer_const_constructors, avoid_print, deprecated_member_use

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/react_side/dashboard/dashboard.dart';
import 'package:whatsapp/react_side/lead/page/all_leads_page.dart';
import 'package:whatsapp/react_side/template/screen/template_list.dart';
import 'package:whatsapp/views/view/balance_transaction_list_screen.dart';
import 'package:whatsapp/views/view/call_history_screen.dart';
import 'package:whatsapp/views/view/lead/lead_list_view.dart';
import 'package:whatsapp/views/view/tags_list_view.dart';
import 'package:whatsapp/views/view/templete_list_view.dart';
import 'package:whatsapp/views/view/whatsap_setting_view.dart';
import 'package:whatsapp/views/widgets/bottomnavigatonbar.dart';
import '../../models/user_model/user_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../utils/app_constants.dart';
import '../../utils/function_lib.dart';
import '../view/campaign_list_view.dart';

class AppDrawerWidget extends StatefulWidget {
  const AppDrawerWidget({super.key});

  @override
  State<AppDrawerWidget> createState() => _AppDrawerWidgetState();
}

class _AppDrawerWidgetState extends State<AppDrawerWidget> {
  String? profileUrl;
  UserModel? userModel;

  void getProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userModel = AppUtils.getSessionUser(prefs);
    });
    debug("userModel?.companyname  ${userModel?.companyname}");
    debug("userModel?.companyname  ${userModel?.username}");
  }

  @override
  void initState() {
    getAvailableModules();
    getProfileData();
    super.initState();
  }

  List<String> modules = [];
  bool hasWallet = false;
  bool hasCalls = false;

  Future<void> getAvailableModules() async {
    final prefs = await SharedPreferences.getInstance();
    modules =
        prefs.getStringList(SharedPrefsConstants.userAvailableMoulesKey) ?? [];
    hasWallet = prefs.getBool(SharedPrefsConstants.hasWalletKey) ?? false;
    hasCalls = prefs.getBool(SharedPrefsConstants.hasCallsKey) ?? false;

    setState(() {});

    print("modules:::: $modules");
  }

  @override
  Widget build(BuildContext context) {
    debug('userdetails===${userModel?.username}');
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          InkWell(
            onTap: () {},
            child: DrawerHeader(
              // decoration: BoxDecoration(color: AppColor.navBarIconColor),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/whatsapp.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: AppColor.navBarIconColor,
            ),
            title: Text(
              "Home",
              // style: TextStyle(
              //   fontFamily: 'CenturySchoolbook',
              //   fontWeight: FontWeight.bold,
              //   fontSize: 20,
              // ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashBoard()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.bolt,
              color: AppColor.navBarIconColor,
            ),
            title: Text(
              'Leads',
              // style: GoogleFonts.montserrat(
              //   fontWeight: FontWeight.bold,
              // ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllLeadsPage(),
                ),
              );
            },
          ),
          modules.contains("Campaign") || modules.contains("Campaigns")
              ? Divider()
              : SizedBox(),
          modules.contains("Campaign") || modules.contains("Campaigns")
              ? ListTile(
                  leading: Icon(
                    FontAwesomeIcons.bandcamp,
                    color: AppColor.navBarIconColor,
                  ),
                  title: Text(
                    'Campaign',
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CampaignListView()));
                  },
                )
              : SizedBox(),
          // Divider(),
          // ListTile(
          //   leading: Icon(
          //     Icons.group,
          //     color: AppColor.navBarIconColor,
          //   ),
          //   title: Text(
          //     'Groups',
          //     // style: GoogleFonts.montserrat(
          //     //   fontWeight: FontWeight.bold,
          //     // ),
          //   ),
          //   onTap: () {
          //     // Navigator.push(
          //     //   context,
          //     //   MaterialPageRoute(
          //     //       builder: (context) => MultiProvider(
          //     //             providers: [
          //     //               ChangeNotifierProvider(
          //     //                   create: (_) => LeadListViewModel(context))
          //     //             ],
          //     //             child: ProductListView(),
          //     //           )),
          //     // );
          //   },
          // ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.add,
              color: AppColor.navBarIconColor,
            ),
            title: Text(
              'Templete',
              // style: GoogleFonts.montserrat(
              //   fontWeight: FontWeight.bold,
              // ),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TempleteListPage()));
            },
          ),
          // Divider(),
          // ListTile(
          //   leading: Icon(
          //     FontAwesomeIcons.whatsapp,
          //     color: AppColor.navBarIconColor,
          //   ),
          //   title: Text(
          //     'WhatsApp Chat',
          //     style: GoogleFonts.montserrat(
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => WhatsappChatListView()));
          //   },
          // ),
          // Divider(),
          // ListTile(
          //   leading: Icon(
          //     FontAwesomeIcons.solidMessage,
          //     color: AppColor.navBarIconColor,
          //   ),
          //   title: Text(
          //     'Auto Response Message',
          //     // style: GoogleFonts.montserrat(
          //     //   fontWeight: FontWeight.bold,
          //     // ),
          //   ),
          //   onTap: () {
          //     // Navigator.push(
          //     //   context,
          //     //   MaterialPageRoute(builder: (context) => AddTaskView()),
          //     // );
          //   },
          // ),

          // Divider(),

          modules.contains("Tag") || modules.contains("Tags")
              ? Divider()
              : SizedBox(),
          modules.contains("Tags") || modules.contains("Tag")
              ? ListTile(
                  leading: Icon(
                    FontAwesomeIcons.tags,
                    color: AppColor.navBarIconColor,
                  ),
                  title: Text(
                    'Tags',
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TagsListView()));
                  },
                )
              : SizedBox(),

          hasWallet ? Divider() : SizedBox(),
          hasWallet
              ? ListTile(
                  leading: Icon(
                    FontAwesomeIcons.wallet,
                    color: AppColor.navBarIconColor,
                  ),
                  title: Text(
                    'My Wallet',
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BalanceTransactionListScreen()));
                  },
                )
              : SizedBox(),

          Divider(),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.gear,
              color: AppColor.navBarIconColor,
            ),
            title: Text(
              'WhatsApp Setting',
              // style: GoogleFonts.montserrat(
              //   fontWeight: FontWeight.bold,
              // ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WhatsapSettingView()));
            },
          ),
          modules.contains("Calls") ? Divider() : SizedBox(),
          modules.contains("Calls")
              ? ListTile(
                  leading: Icon(
                    Icons.ring_volume_rounded,
                    color: AppColor.navBarIconColor,
                  ),
                  title: Text(
                    'Calls',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CallHistoryScreen()),
                    );
                  },
                )
              : SizedBox(),

          // ListTile(
          //   leading: Icon(
          //     Icons.person,
          //     color: AppColor.navBarIconColor,
          //   ),
          //   title: Text(
          //     'Profile',
          //     // style: GoogleFonts.montserrat(
          //     //   fontWeight: FontWeight.bold,
          //     // ),
          //   ),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => ProfileView()),
          //     );
          //     /* AppUtils.launchTab(context,
          //         selectedIndex: HomeTabsOptions.profile.index); */
          //   },
          // ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.share,
              color: AppColor.navBarIconColor,
            ),
            title: Text(
              'Share App',
              // style: GoogleFonts.montserrat(
              //   fontWeight: FontWeight.bold,
              // ),
            ),
            onTap: () {
              Share.share(AppConstants.appUrlPath, subject: 'Welcome Message');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: AppColor.navBarIconColor,
            ),
            title: Text(
              'Logout',
              // style: GoogleFonts.montserrat(
              //   fontWeight: FontWeight.bold,
              // ),
            ),
            onTap: () {
              showAlertDialog();
            },
          ),

          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  Future<void> logoutUser() async {
    print("LOGGING OUT....");
    AppUtils.logout(context);
  }

  void showAlertDialog() {
  showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95, 
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.navBarIconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.exit_to_app,
                color: AppColor.navBarIconColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Logout",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Are you sure you want to logout?",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.navBarIconColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await logoutUser();
                    },
                    child: const Text("Logout"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
);
  }

  // showAlertDialog() {
  //   Widget noButton = TextButton(
  //     child: Text(
  //       "No",
  //       style: GoogleFonts.montserrat(color: AppColor.navBarIconColor),
  //     ),
  //     onPressed: () {
  //       // debug("No");
  //       Navigator.pop(context);
  //     },
  //   );
  //   // set up the buttons
  //   Widget yesButton = TextButton(
  //     child: Text(
  //       "Yes",
  //       style: GoogleFonts.montserrat(color: AppColor.navBarIconColor),
  //     ),
  //     onPressed: () {
  //       Navigator.pop(context);
  //       AppUtils.logout(context);
  //     },
  //   );

  //   AlertDialog alert = AlertDialog(
  //     title: Text(
  //       "Logout",
  //         ,
  //     ),
  //     content: Text(
  //       "Are you sure you want to Logout",
  //         ,
  //     ),
  //     actions: [
  //       noButton,
  //       yesButton,
  //     ],
  //   );

  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }
}
