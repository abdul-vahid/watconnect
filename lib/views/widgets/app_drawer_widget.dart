// ignore_for_file: prefer_const_constructors, avoid_print, deprecated_member_use

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                MaterialPageRoute(builder: (context) => FooterNavbarPage()),
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
                  builder: (context) => LeadListView(),
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
                  MaterialPageRoute(builder: (context) => TempleteListView()));
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
    AppUtils.logout(context);
  }

  // Future<void> showAlertDialog() async {
  //   // Setup the "No" button
  //   Widget noButton = TextButton(
  //     style: TextButton.styleFrom(
  //       foregroundColor: Colors.grey,
  //       backgroundColor: Colors.grey[200],
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //     ),
  //     onPressed: () {
  //       Navigator.pop(context);
  //     },
  //     child: Text(
  //       "No",
  //       // style: TextStyle(color: AppColor.navBarIconColor),
  //     ),
  //   );

  //   Widget yesButton = TextButton(
  //     style: TextButton.styleFrom(
  //       foregroundColor: Colors.white,
  //       backgroundColor: AppColor.navBarIconColor,
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //     ),
  //     child: Text(
  //       'Yes',
  //       style: TextStyle(fontSize: 14),
  //     ),
  //     onPressed: () {
  //       Navigator.pop(context);
  //       AppUtils.logout(context);
  //     },
  //   );

  //   await showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text(
  //               'Are you sure you want to logout?',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             const SizedBox(height: 15),
  //             const Divider(),
  //             const SizedBox(height: 15),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 noButton,
  //                 const SizedBox(width: 20),
  //                 yesButton,
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.navBarIconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.exit_to_app,
                    color: AppColor.navBarIconColor, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                "Logout",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are you sure you want to logout?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancel",
                          style: TextStyle(color: Colors.black87)),
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
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Logout"),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await logoutUser();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
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
