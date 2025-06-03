import 'package:flutter/material.dart';
import 'package:whatsapp/salesforce/api/api_helper.dart';
import 'package:whatsapp/salesforce/model/drawer_model.dart';
import 'package:whatsapp/utils/app_constants.dart';

class DashBoardController extends ChangeNotifier {
  List<SfDrawerModel> drawerItems = [];

  /// Refresh UI manually
  Future<void> notify() async {
    await Future.delayed(Duration.zero); // Cleaner than Duration(seconds: 0)
    notifyListeners();
  }

  bool fromSalesForce = false;

  setLoginType(bool from) {
    fromSalesForce = from;
    notify();
  }

  /// Call API and update drawerItems list
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
      print("Error in drawerApiCall: $e");
    }

    notifyListeners();
  }
}
