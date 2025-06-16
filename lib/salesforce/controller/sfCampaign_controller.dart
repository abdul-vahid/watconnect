import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/salesforce/model/campaign_model.dart';
import 'package:whatsapp/utils/app_constants.dart';

class SfcampaignController extends ChangeNotifier {
  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  bool getCampLoader = false;

  setGetCampLoader(bool val) {
    getCampLoader = val;
    notify();
  }

  List<SfCampaignModel> sfCampaignList = [];

  Future<void> getCampaignApiCall() async {
    try {
      setGetCampLoader(true);

      final prefs = await SharedPreferences.getInstance();
      final busNum =
          prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      String apiUrl = "${AppConstants.sfGetCampaign}businessNumber=${busNum}";
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
          "get campaing response :: ${response.runtimeType}  ${response.statusCode} ${response}");

      if (response.statusCode == 200) {
        setGetCampLoader(false);
        final List<dynamic> data = jsonDecode(response.body);
        sfCampaignList
          ..clear()
          ..addAll(data.map((e) => SfCampaignModel.fromJson(e)));

        notify();
        log("Fetched ${sfCampaignList.length}  get campaign .");
      } else {
        setGetCampLoader(false);
        log(" get campaign  API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      setGetCampLoader(false);
      print("Error in get campaign api: $e");
    }
    notifyListeners();
  }

  bool getCampHistoryLoader = false;

  setGetCampHistoryLoader(bool val) {
    getCampHistoryLoader = val;
    notify();
  }
}
