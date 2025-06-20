import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/model/business_number_model.dart';
import 'package:whatsapp/utils/app_constants.dart';

class BusinessNumberController extends ChangeNotifier {
  List<BusinessNumberModel> businessNumbers = [];

  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> getBusinessNumberApiCall() async {
    try {
      String apiUrl = "${AppConstants.sfGetBusinessNumbs}";
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log("headers:::: ${"$token"}    ${apiUrl}");
      print(
          "get getBusinessNumberApiCall response :: ${response.runtimeType} $apiUrl ${response.statusCode} ${response}");

      if (response.statusCode == 200) {
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

        notify();
        log("Fetched ${businessNumbers.length} businessNumbers.");
      } else {
        log("sfGetBusinessNumbs API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      print("Error in sfGetBusinessNumbs api: $e");
    }
  }

  Future<void> setBusinessNumberApiCall({required String busNumber}) async {
    try {
      String apiUrl = "${AppConstants.sfSetBusinessNumb}${busNumber}";
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log("headers:::: ${"$token"}  \n  ${apiUrl} ");

      print(
          "send Template response :: ${response.runtimeType}  ${response.statusCode} ${response}");

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(SharedPrefsConstants.sfBusinessNumber, busNumber);
        EasyLoading.showToast("Business Number set Successfully");
        getBusinessNumberApiCall();
        DashBoardController dbController =
            Provider.of(navigatorKey.currentContext!, listen: false);
        dbController.getDasBoardReportApiCall();
      } else {
        log("send template API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      print("Error in setBusinessNumberApiCall api: $e");
    }
  }
}
