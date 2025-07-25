// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/controller/network_Services.dart';
import 'package:whatsapp/salesforce/model/business_number_model.dart';
import 'package:whatsapp/utils/app_constants.dart';

class BusinessNumberController extends ChangeNotifier {
  List<BusinessNumberModel> businessNumbers = [];

  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> getBusinessNumberApiCall() async {
    String apiUrl = AppConstants.sfGetBusinessNumbs;
    final response = await NetworkService.makeRequest(
      url: apiUrl,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      businessNumbers
        ..clear()
        ..addAll(data.map((e) => BusinessNumberModel.fromJson(e)));
      final prefs = await SharedPreferences.getInstance();

      final defaultNumber = businessNumbers.firstWhere(
        (b) => b.isDefault == "true",
        orElse: () => businessNumbers.first,
      );
      await prefs.setString(
        SharedPrefsConstants.sfBusinessNumber,
        defaultNumber.whasappSettingNumber ?? "",
      );
      setBusinessNumberApiCall(
        busNumber: defaultNumber.whasappSettingNumber ?? "",
      );
    }
    notify();
  }

  Future<void> setBusinessNumberApiCall({required String busNumber}) async {
    String apiUrl = "${AppConstants.sfSetBusinessNumb}${busNumber}";
    final response = await NetworkService.makeRequest(
      url: apiUrl,
      method: 'POST',
    );
    if (response != null && response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedPrefsConstants.sfBusinessNumber, busNumber);
      EasyLoading.showToast("Business Number set Successfully");
      DashBoardController dbController =
          Provider.of(navigatorKey.currentContext!, listen: false);
      dbController.getDasBoardReportApiCall();
    }
    notify();
  }
}
