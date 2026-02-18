// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/screens/confige_listing_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_campaign_listing_screen.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/notification_utils.dart';
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

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  void _getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userModel = AppUtils.getSessionUser(prefs);
    });
    debug("userModel?.companyname  ${userModel?.companyname}");
    debug("userModel?.username  ${userModel?.username}");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.78,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<DashBoardController>(
              builder: (context, ref, child) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuSection(ref),
                    _buildFooterSection(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.navBarIconColor.withOpacity(0.9),
            AppColor.navBarIconColor,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo
          Center(
            child: Container(
              width: 80,
              height: 80,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/whatsapp.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 16),

          // User Info
          if (userModel != null) ...[
            Text(
              userModel?.username?.isNotEmpty == true
                  ? 'Hello, ${userModel!.username!}'
                  : 'Welcome!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            if (userModel?.companyname?.isNotEmpty == true)
              Text(
                userModel!.companyname!,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSection(DashBoardController ref) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          for (var category in ref.drawerItems)
            _buildMenuTile(
              icon: _getIconForCategory(category.sObjectName ?? ""),
              title: category.sObjectName ?? "",
              onTap: () {
                _handleMenuTap(ref, category.sObjectName ?? "");
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.navBarIconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColor.navBarIconColor,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey[400],
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          visualDensity: VisualDensity.compact,
          onTap: onTap,
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey[200]),
          ),
      ],
    );
  }

  Widget _buildFooterSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.share_rounded,
            title: "Share App",
            showDivider: false,
            onTap: () {
              Share.share(AppConstants.appUrlPath, subject: 'Welcome Message');
            },
          ),
          _buildMenuTile(
            icon: Icons.logout_rounded,
            title: "Logout",
            // color: Colors.red,
            showDivider: false,
            onTap: _showLogoutDialog,
          ),
          SizedBox(height: 8),
          // Text(
          //   'Version 1.0.0',
          //   style: TextStyle(
          //     color: Colors.grey[600],
          //     fontSize: 12,
          //   ),
          // ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'lead':
      case 'leads':
        return Icons.bolt_rounded;
      case 'campaign':
      case 'campaigns':
        return Icons.campaign_rounded;
      case 'contact':
      case 'contacts':
        return Icons.contact_phone_rounded;
      case 'account':
      case 'accounts':
        return Icons.business_rounded;
      case 'opportunity':
      case 'opportunities':
        return Icons.trending_up_rounded;
      case 'case':
      case 'cases':
        return Icons.cases_rounded;
      case 'task':
      case 'tasks':
        return Icons.task_rounded;
      case 'event':
      case 'events':
        return Icons.event_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  void _handleMenuTap(DashBoardController ref, String sObjectName) {
    if (sObjectName == 'Campaign') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SfCampaignScreen()),
      );
    } else {
      ref.setSelectedTitle(sObjectName);
      ref.drawerListApiCall(type: sObjectName);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfigListingScreen(type: sObjectName),
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),

                // Title
                Text(
                  "Logout?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),

                // Message
                Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel"),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _logoutUser();
                        },
                        child: Text("Logout"),
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

  Future<void> _logoutUser() async {
    
    NotificationUtil.deleteFCMTokenOnLogout();
    AppUtils.logout(context);
  }
}
