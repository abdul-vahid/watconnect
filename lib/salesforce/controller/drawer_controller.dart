import 'package:flutter/material.dart';
import 'package:whatsapp/salesforce/api/api_helper.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
import 'package:whatsapp/salesforce/model/drawer_model.dart';
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
}
