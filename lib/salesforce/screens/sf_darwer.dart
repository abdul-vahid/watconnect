// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/screens/confige_listing_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_campaign_listing_screen.dart';
import 'package:whatsapp/utils/app_constants.dart';

import '../../models/user_model/user_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';

import '../../utils/function_lib.dart';

class SfAppDrawerWidget extends StatefulWidget {
  const SfAppDrawerWidget({super.key});

  @override
  State<SfAppDrawerWidget> createState() => _SfAppDrawerWidgetState();
}

class _SfAppDrawerWidgetState extends State<SfAppDrawerWidget> {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debug('userdetails===${userModel?.username}');
    return Drawer(
      child: Builder(builder: (context) {
        return Consumer<DashBoardController>(builder: (context, ref, child) {
          return ListView(
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

              Column(children: [
                for (var category in ref.drawerItems)
                  Column(
                    children: [
                      ListTile(
                        onTap: () {
                          if (category.sObjectName == 'Campaign') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SfCampaignScreen()),
                            );
                          } else {
                            ref.setSelectedTitle(category.sObjectName ?? "");
                            ref.drawerListApiCall(
                                type: category.sObjectName ?? "");

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConfigListingScreen(
                                          type: category.sObjectName ?? "",
                                        )));
                          }
                        },
                        leading: Icon(
                          category.sObjectName == "Lead"
                              ? Icons.bolt
                              : Icons.contact_emergency,
                          color: AppColor.navBarIconColor,
                        ),
                        title: Text(category.sObjectName ?? ""),
                      ),
                      Divider(),
                    ],
                  ),
              ]),

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
                  Share.share(AppConstants.appUrlPath,
                      subject: 'Welcome Message');
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
                ),
                onTap: () {
                  showAlertDialog();
                },
              ),

              // ref.drawerItems.map((toElement){
              //   return ListTile()
              // })

              // ListTile(
              //   leading: Icon(
              //     Icons.home,
              //     color: AppColor.navBarIconColor,
              //   ),
              //   title: Text(
              //     "Home",
              //     // style: TextStyle(
              //     //   fontFamily: 'CenturySchoolbook',
              //     //   fontWeight: FontWeight.bold,
              //     //   fontSize: 20,
              //     // ),
              //   ),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => FooterNavbarPage()),
              //     );
              //   },
              // ),
              // Divider(),
              // ListTile(
              //   leading: Icon(
              //     Icons.bolt,
              //     color: AppColor.navBarIconColor,
              //   ),
              //   title: Text(
              //     'Leads',
              //     // style: GoogleFonts.montserrat(
              //     //   fontWeight: FontWeight.bold,
              //     // ),
              //   ),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => LeadListView(),
              //       ),
              //     );
              //   },
              // ),
              // modules.contains("Campaign") ? Divider() : SizedBox(),
              // modules.contains("Campaign")
              //     ? ListTile(
              //         leading: Icon(
              //           FontAwesomeIcons.personHarassing,
              //           color: AppColor.navBarIconColor,
              //         ),
              //         title: Text(
              //           'Campaign',
              //           // style: GoogleFonts.montserrat(
              //           //   fontWeight: FontWeight.bold,
              //           // ),
              //         ),
              //         onTap: () {
              //           Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                   builder: (context) => CampaignListView()));
              //         },
              //       )
              //     : SizedBox(),

              // Divider(),
              // ListTile(
              //   leading: Icon(
              //     Icons.add,
              //     color: AppColor.navBarIconColor,
              //   ),
              //   title: Text(
              //     'Templete',
              //     // style: GoogleFonts.montserrat(
              //     //   fontWeight: FontWeight.bold,
              //     // ),
              //   ),
              //   onTap: () {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (context) => TempleteListView()));
              //   },
              // ),

              // Divider(),
              // ListTile(
              //   leading: Icon(
              //     FontAwesomeIcons.gear,
              //     color: AppColor.navBarIconColor,
              //   ),
              //   title: Text(
              //     'WhatsApp Setting',
              //     // style: GoogleFonts.montserrat(
              //     //   fontWeight: FontWeight.bold,
              //     // ),
              //   ),
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => WhatsapSettingView()));
              //   },
              // ),

              // Divider(),
              // ListTile(
              //   leading: Icon(
              //     Icons.share,
              //     color: AppColor.navBarIconColor,
              //   ),
              //   title: Text(
              //     'Share App',

              //   ),
              //   onTap: () {
              //     Share.share(AppConstants.appUrlPath, subject: 'Welcome Message');
              //   },
              // ),
              // Divider(),
            ],
          );
        });
      }),
    );
  }

  Future<void> logoutUser() async {
    AppUtils.logout(context);
  }

  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.all(20),
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
}
