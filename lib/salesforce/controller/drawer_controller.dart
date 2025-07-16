import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/salesforce/controller/network_Services.dart';
import 'package:whatsapp/salesforce/model/config_unread_count_model.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
import 'package:whatsapp/salesforce/model/drawer_model.dart';
import 'package:whatsapp/salesforce/model/sf_profile_model.dart';
import 'package:whatsapp/salesforce/model/sf_report_models.dart';
import 'package:whatsapp/salesforce/screens/sf_home_screen.dart';
import 'package:whatsapp/utils/app_constants.dart';

class DashBoardController extends ChangeNotifier {
  List<SfDrawerModel> drawerItems = [];

  List<SfDrawerItemModel> drawerListItems = [];
  List<SfDrawerItemModel> tempDrawerListItems = [];

  List<SfConfigUnreadCountModel> configUnreadCountList = [];
  List<SfConfigUnreadCountModel> tempConfigUnreadCountList = [];

  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  bool fromSalesForce = false;

  setLoginType(bool from) {
    fromSalesForce = from;
    notify();
  }

  List<SalesData> sfCampaignData = [];
  List<Templatedata> sfTemplatedata = [];

  Future<void> drawerApiCall() async {
    const url = AppConstants.getDrawerItemsApi;
    final response = await NetworkService.makeRequest(
      url: url,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      drawerItems = data.map((e) => SfDrawerModel.fromJson(e)).toList();
      print("drawerItems:::: $drawerItems");
      notify();
    }
  }

  bool configListLoader = false;

  setConfigListLoader(bool val) {
    configListLoader = val;
    notify();
  }

  String selectedTitle = "Lead";
  setSelectedTitle(String val) {
    selectedTitle = val;
    notify();
  }

  SfDrawerItemModel? selectedContactInfo;

  setSelectedContaactInfo(info) {
    selectedContactInfo = info;
    notify();
  }

  Future<void> drawerListApiCall(
      {String type = "Lead", bool showLoading = true}) async {
    drawerListUnreadCountApiCall(type: type);
    if (showLoading) {
      setConfigListLoader(true);
    }
    var url = "${AppConstants.sfGetDrawerList}$type";
    final response = await NetworkService.makeRequest(
      url: url,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      var res = jsonDecode(response.body);
      List temp = res['data'];
      drawerListItems = temp.map((e) => SfDrawerItemModel.fromJson(e)).toList();
      tempDrawerListItems = drawerListItems;
      notify();
    }
    setConfigListLoader(false);
  }

  Future<void> drawerListUnreadCountApiCall({String type = "Lead"}) async {
    // if (showLoading) {
    //   setConfigListLoader(true);
    // }
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    var url =
        "${AppConstants.sfGetDrawerUnreadList}$type&businessnumber=${busNum}&recordlimit=50";
    final response = await NetworkService.makeRequest(
      url: url,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      // var res = jsonDecode(response.body);
      List temp = jsonDecode(response.body);
      configUnreadCountList =
          temp.map((e) => SfConfigUnreadCountModel.fromJson(e)).toList();
      tempConfigUnreadCountList = configUnreadCountList;
      notify();
    }
    setConfigListLoader(false);
  }

  void filterRecs(String value) {
    if (value.isEmpty) {
      drawerListItems = tempDrawerListItems;
    } else {
      drawerListItems = tempDrawerListItems.where((e) {
        return e.name!.toLowerCase().contains(value.toLowerCase()) ||
            e.whatsappNumber!.contains(value);
      }).toList();
    }
    notify();
  }

  SfProfileModel? sfUserData;

  Future<void> getProfileApiCall() async {
    var url = AppConstants.sfGetProfile;
    final response = await NetworkService.makeRequest(
      url: url,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      sfUserData = SfProfileModel.fromJson(jsonDecode(response.body));
      sfDeviceTokenApiCall(sfUserData?.userId ?? "");
      notify();
      log("Fetched ${sfUserData?.name ?? ""}  get sfGetProfile .");
    }
    notify();
  }

  bool recentChatListLoader = false;

  setRecentChatListLoader(bool val) {
    recentChatListLoader = val;
    notify();
  }

  List<SfDrawerItemModel> sfRecentChatList = [];
  List<SfDrawerItemModel> tempsfRecentChatList = [];

  Future<void> recentChatListApiCall() async {
    setRecentChatListLoader(true);
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    String apiUrl =
        "${AppConstants.sfRecentChat}?businessnumber=${busNum}&recordlimit=5000&objectname=${selectedTitle}";
    final response = await NetworkService.makeRequest(
      url: apiUrl,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      sfRecentChatList
        ..clear()
        ..addAll((data
              ..sort((a, b) {
                final at = a['lastMessageTime'];
                final bt = b['lastMessageTime'];

                // Nulls go to the end
                if (at == null && bt == null) return 0;
                if (at == null) return 1;
                if (bt == null) return -1;

                // Descending order
                return bt.compareTo(at);
              }))
            .map((e) => SfDrawerItemModel.fromJson(e)));

      tempsfRecentChatList = sfRecentChatList;
    }
    notify();
    setRecentChatListLoader(false);
  }

  Future<void> resentUnreadCountApiCall(String custNum,
      {bool isFromChat = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    String apiUrl = AppConstants.sfRecentChat;
    Map<String, dynamic> body = {
      "Business Number": busNum,
      "Customer Number": custNum
    };
    final response = await NetworkService.makeRequest(
      url: apiUrl,
      body: body,
      method: 'POST',
    );
    if (response != null && response.statusCode == 200) {
      if (isFromChat) {
        recentChatListApiCall();
      } else {
        sfNotificationHistoryApiCall();
      }
    }
    notify();
  }

  TemplateStatsModel? tempStatus;
  CampaignStatsModel? campStatus;
  String totalLead = "";
  String totalCamp = "";

  Future<void> getDasBoardReportApiCall() async {
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    String apiUrl = "${AppConstants.sfDashBoardReport}businessnumber=${busNum}";

    final response = await NetworkService.makeRequest(
      url: apiUrl,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      var reportList = jsonDecode(response.body);

      print(
          "reportList  ${reportList}['Total Records'].toString():::::: ${reportList[2]['Total Records'].toString()}");

      tempStatus = TemplateStatsModel.fromJson(reportList[0]);

      campStatus = CampaignStatsModel.fromJson(reportList[1]);
      var campCount = campStatus!.completed! +
          campStatus!.inProgress! +
          campStatus!.pending!;

      totalCamp = campCount.toString();
      totalLead = reportList[2]['Total Records'].toString();
      getSfCampWidgets();
      getSfTemplateData();
    }
    notify();
  }

  void getSfCampWidgets() {
    sfCampaignData.clear();
    sfCampaignData.add(SalesData("Pending", campStatus?.pending ?? 0));
    sfCampaignData.add(SalesData("In Progress", campStatus?.inProgress ?? 0));
    sfCampaignData.add(SalesData("Completed", campStatus?.completed ?? 0));
    notify();
  }

  void getSfTemplateData() {
    sfTemplatedata.clear();
    sfTemplatedata.add(Templatedata("Pending", tempStatus?.pending ?? 0));
    sfTemplatedata.add(Templatedata("In Progress", tempStatus?.pending ?? 0));
    sfTemplatedata.add(Templatedata("Approved", tempStatus?.approved ?? 0));
    notify();
  }

  String sfFcm = "";
  setSfFcmToken(String tokn) {
    sfFcm = tokn;
    print(
        "setting the firebase fcm in salesforece:::::::::::::::::::  ${sfFcm}");
    notify();
  }

  String sfDeviceTokn = "";
  setSfDeviceToken(String devTokn) {
    sfDeviceTokn = devTokn;

    print(
        "setting the device id in salesforece::::::::::::::: ${sfDeviceTokn}");

    notify();
  }

  Future<void> sfDeviceTokenApiCall(String usrId) async {
    String apiUrl = "${AppConstants.sfDeviceToken}";

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmtoken = await messaging.getToken();
    Map<String, dynamic> body = {
      "userId": usrId,
      "deviceId": sfDeviceTokn,
      "fcmToken": fcmtoken
    };
    final response = await NetworkService.makeRequest(
      url: apiUrl,
      body: body,
      method: 'POST',
    );
    if (response != null && response.statusCode == 200) {}
    notify();
  }

  bool sfNotificationListLoader = false;

  setSfNotificationListLoader(bool val) {
    sfNotificationListLoader = val;
    notify();
  }

  List<SfDrawerItemModel> sfNoticationList = [];
  List<SfDrawerItemModel> tempSfNotificationList = [];

  Future<void> sfNotificationHistoryApiCall() async {
    setSfNotificationListLoader(true);
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    String apiUrl =
        "${AppConstants.sfNotificationHistory}?businessnumber=${busNum}";
    final response = await NetworkService.makeRequest(
      url: apiUrl,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      final List<dynamic> data =
          response.body.isEmpty ? [] : jsonDecode(response.body) ?? [];
      sfNoticationList
        ..clear()
        ..addAll(data.map((e) => SfDrawerItemModel.fromJson(e)));
      tempSfNotificationList = sfNoticationList;
    }
    setSfNotificationListLoader(false);
    notify();
  }

  List<String> configStatusList = [];
  setConfigStatusList(List<String> selConfigStatus) {
    configStatusList = selConfigStatus;
    notify();
  }

  removeFromConfigStatusList(String configStatus) {
    configStatusList.remove(configStatus);
    notify();
  }

  resetConfigStatusList() {
    configStatusList.clear();
    notify();
  }

  filterConfig() {
    if (configStatusList.isEmpty || configStatusList.contains('All')) {
      drawerListItems = tempDrawerListItems;
    } else {
      drawerListItems = tempDrawerListItems.where((e) {
        return configStatusList.contains(e.status);
      }).toList();
    }
    notify();
  }
}
