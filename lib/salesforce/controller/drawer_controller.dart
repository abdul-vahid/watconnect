import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/salesforce/api/api_helper.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
import 'package:whatsapp/salesforce/model/drawer_model.dart';
import 'package:whatsapp/salesforce/model/sf_profile_model.dart';
import 'package:whatsapp/salesforce/model/sf_recent_chat_model.dart';
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

  String selectedTitle = "";
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
      String apiUrl = "${AppConstants.sfRecentChat}?businessnumber=${busNum}";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
      );

      log("headers:::: ${"Bearer $token"}    ${AppConstants.sfRecentChat}");
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
}
