import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/salesforce/api/api_helper.dart';
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
    try {
      final response = await AppApi().commonGetMethod(
        AppConstants.getDrawerItemsApi,
        sendToken: true,
      );

      if (response is List) {
        drawerItems = response.map((e) => SfDrawerModel.fromJson(e)).toList();
        print("drawerItems:::: $drawerItems");
      } else {
        print("Unexpected response type: $response");
      }
    } catch (e) {
      print("Error in chat history api: $e");
    }

    notifyListeners();
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

  Future<void> drawerListApiCall(String type) async {
    try {
      setConfigListLoader(true);
      final response = await AppApi().commonGetMethod(
        "${AppConstants.sfGetDrawerList}${type}",
        sendToken: true,
      );

      print("congig resposne:::: ${response}   ");

      List temp = response["data"];

      drawerListItems = temp.map((e) => SfDrawerItemModel.fromJson(e)).toList();
      tempDrawerListItems = drawerListItems;
      print("drawerItems:::: $drawerItems");

      setConfigListLoader(false);
      notify();
    } catch (e) {
      setConfigListLoader(false);
      print("Error in drawerApiCall: $e");
    }

    notifyListeners();
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
    try {
      final prefs = await SharedPreferences.getInstance();

      String apiUrl = "${AppConstants.sfGetProfile}";
      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log("headers:::: ${"Bearer $token"}    ${apiUrl}");
      print(
          "get sfGetProfile response :: ${response.runtimeType}  ${response.statusCode} ${response}");

      if (response.statusCode == 200) {
        sfUserData = SfProfileModel.fromJson(jsonDecode(response.body));
        sfDeviceTokenApiCall(sfUserData?.userId ?? "");
        notify();
        log("Fetched ${sfUserData?.name ?? ""}  get sfGetProfile .");
      } else {
        log(" get sfGetProfile API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      print("Error in profile api: $e");
    }

    notifyListeners();
  }

  bool recentChatListLoader = false;

  setRecentChatListLoader(bool val) {
    recentChatListLoader = val;
    notify();
  }

  List<SfDrawerItemModel> sfRecentChatList = [];
  List<SfDrawerItemModel> tempsfRecentChatList = [];

  Future<void> recentChatListApiCall() async {
    try {
      setRecentChatListLoader(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
      final busNum =
          prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      String apiUrl =
          "${AppConstants.sfRecentChat}?businessnumber=${busNum}&recordlimit=5000&objectname=${selectedTitle}";
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
      );
      log("headers:::: ${"Bearer $token"}    ${apiUrl}");
      print(
          " Recent Chat response :: ${response.runtimeType}  ${response.statusCode} ${response}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        sfRecentChatList
          ..clear()
          ..addAll(data.map((e) => SfDrawerItemModel.fromJson(e)));
        tempsfRecentChatList = sfRecentChatList;
        setRecentChatListLoader(false);
      } else {
        setRecentChatListLoader(false);
        log("SF Recent Chat failed [${response.statusCode}]: ${response.body}");
      }

      notify();
    } catch (e) {
      setRecentChatListLoader(false);
      print("Error in Recent Chat: $e");
    }

    notifyListeners();
  }

  Future<void> resentUnreadCountApiCall(String custNum,
      {bool isFromChat = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
      final busNum =
          prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      String apiUrl = "${AppConstants.sfRecentChat}";
      Map body = {"Business Number": busNum, "Customer Number": custNum};
      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            "Content-Type": "application/json"
          },
          body: jsonEncode(body));
      log("headers:::: ${"Bearer $token"}    ${AppConstants.sfRecentChat}");
      print(
          " reset Un read response :: ${response.runtimeType}  ${response.statusCode} ${response}");
      if (response.statusCode == 200) {
        if (isFromChat) {
          recentChatListApiCall();
        } else {
          sfNotificationHistoryApiCall();
        }
      } else {
        log("SF reset Un read failed [${response.statusCode}]: ${response.body}");
      }
      notify();
    } catch (e) {
      setRecentChatListLoader(false);
      print("Error in Recent Chat: $e");
    }
    notifyListeners();
  }

  TemplateStatsModel? tempStatus;
  CampaignStatsModel? campStatus;
  String totalLead = "";
  String totalCamp = "";

  Future<void> getDasBoardReportApiCall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final busNum =
          prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      String apiUrl =
          "${AppConstants.sfDashBoardReport}businessnumber=${busNum}";
      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log("headers:::: ${"Bearer $token"}    ${apiUrl}");
      print(
          "get dashboard Report response :: ${response.runtimeType}  ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
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
        notify();
      } else {
        log(" get dashboard Report API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      print("Error in dashboard Report api: $e");
    }

    notifyListeners();
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
    try {
      final prefs = await SharedPreferences.getInstance();

      String apiUrl = "${AppConstants.sfDeviceToken}";
      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? fcmtoken = await messaging.getToken();
      Map body = {
        "userId": usrId,
        "deviceId": sfDeviceTokn,
        "fcmToken": fcmtoken
      };
      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body));

      log("headers:::: ${"Bearer $token"}    ${apiUrl}    ${body}");
      print(
          "get sf device token response :: ${response.runtimeType}  ${response.statusCode} ${response}");

      if (response.statusCode == 200) {
        notify();
      } else {
        log(" sf device token API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      print("Error in sf device token  api: $e");
    }

    notifyListeners();
  }

  bool sfNotificationListLoader = false;

  setSfNotificationListLoader(bool val) {
    sfNotificationListLoader = val;
    notify();
  }

  List<SfDrawerItemModel> sfNoticationList = [];
  List<SfDrawerItemModel> tempSfNotificationList = [];

  Future<void> sfNotificationHistoryApiCall() async {
    try {
      setSfNotificationListLoader(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
      final busNum =
          prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      String apiUrl =
          "${AppConstants.sfNotificationHistory}?businessnumber=${busNum}";
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
      );
      log("headers:::: ${"Bearer $token"}    ${apiUrl}");
      print(
          "SF Notification List response :: ${response.runtimeType}  ${response.statusCode} ${response}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        sfNoticationList
          ..clear()
          ..addAll(data.map((e) => SfDrawerItemModel.fromJson(e)));
        tempSfNotificationList = sfNoticationList;
        setSfNotificationListLoader(false);
      } else {
        setSfNotificationListLoader(false);
        log("SF Notification List  failed [${response.statusCode}]: ${response.body}");
      }

      notify();
    } catch (e) {
      setRecentChatListLoader(false);
      print("Error in SF Notification List: $e");
    }

    notifyListeners();
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
