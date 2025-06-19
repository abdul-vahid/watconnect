import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/screens/sf_campaign_detail.dart';
import 'package:whatsapp/utils/app_color.dart';

class SfProfileScreen extends StatefulWidget {
  const SfProfileScreen({super.key});

  @override
  State<SfProfileScreen> createState() => _SfProfileScreenState();
}

class _SfProfileScreenState extends State<SfProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
        title: const Text(
          "Profile",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      body: Container(
        color: Colors.white38,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Consumer<DashBoardController>(
                builder: (context, dashBoardController, child) {
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: AppColor.navBarIconColor,
                        borderRadius: BorderRadius.circular(08)),
                    height: 40,
                    width: double.infinity,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Profile Information',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 15),
                        buildRow("Full Name",
                            value: dashBoardController.sfUserData?.name ?? ""),
                        buildRow("User Name",
                            value:
                                dashBoardController.sfUserData?.username ?? ""),
                        buildRow("Email",
                            value: dashBoardController.sfUserData?.email ?? ""),
                        buildRow("Phone Number",
                            value: dashBoardController.sfUserData?.phone ?? ""),
                        buildRow("Role",
                            value:
                                dashBoardController.sfUserData?.userRole ?? ""),
                        buildRow("Profile",
                            value:
                                dashBoardController.sfUserData?.profile ?? ""),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
