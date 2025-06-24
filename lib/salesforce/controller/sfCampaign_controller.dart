import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/salesforce/model/campaign_history_model.dart';
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
  List<SfCampaignModel> sfTempCampaignList = [];

  SfCampaignModel? selectedCampaign;

  setSelectedCampaign(SfCampaignModel camp) {
    selectedCampaign = camp;
    notify();
  }

  List<String> campaignStatusList = [];
  setCampStatusList(List<String> selCampStatus) {
    campaignStatusList = selCampStatus;
    notify();
  }

  removeFromCampStatusList(String campStatus) {
    campaignStatusList.remove(campStatus);
    notify();
  }

  resetCampStatusList() {
    campaignStatusList.clear();
    notify();
  }

  Future<void> getCampaignApiCall() async {
    try {
      setGetCampLoader(true);
      final prefs = await SharedPreferences.getInstance();
      final busNum =
          prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      String apiUrl = "${AppConstants.sfGetCampaign}businessnumber=${busNum}";
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

        sfTempCampaignList = sfCampaignList;

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

  bool campHistoryLoader = false;

  setCampHistoryLoader(bool val) {
    campHistoryLoader = val;
    notify();
  }

  List<SfCampaignHistoryModel> sfCampHistoryList = [];

  Future<void> getCampMsgHisApiCall() async {
    try {
      setCampHistoryLoader(true);

      final prefs = await SharedPreferences.getInstance();
      final busNum =
          prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      String apiUrl =
          "${AppConstants.sfGetCampaignHistory}bussinesnumber=${busNum}&campaignid=${selectedCampaign?.id ?? ""}";
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
          " campaing history response :: ${response.runtimeType}  ${response.statusCode} ${response}");

      if (response.statusCode == 200) {
        setCampHistoryLoader(false);
        final List<dynamic> data = jsonDecode(response.body);
        sfCampHistoryList
          ..clear()
          ..addAll(data.map((e) => SfCampaignHistoryModel.fromJson(e)));

        notify();
        log("Fetched ${sfCampHistoryList.length}  history campaign .");
      } else {
        setCampHistoryLoader(false);
        log("  campaign history  API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      setCampHistoryLoader(false);
      print("Error in  campaign history api: $e");
    }
    notifyListeners();
  }

  bool addCampLoader = false;

  setAddCampLoader(bool val) {
    addCampLoader = val;
    notify();
  }

  Future<bool> sfAddCampaignCall(List body) async {
    setAddCampLoader(true);
    try {
      final encodedBody = jsonEncode(body);

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      final response = await http.post(
        Uri.parse(AppConstants.sfAddCampaign),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
        body: encodedBody,
      );

      log("headers:::: ${"Bearer $token"}  $encodedBody  ${AppConstants.sfAddCampaign}");
      print(
          " campaing add response :: ${response.runtimeType}  ${response.statusCode} ${response}");

      if (response.statusCode == 200) {
        setAddCampLoader(false);
        getCampaignApiCall();
      } else {
        setAddCampLoader(false);
        log("SF ADD CAMP failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      setAddCampLoader(false);
      log("Error in SF ADD CAMP: $e");
    }

    return false;
  }

  searchCamp(String searchVal) {
    if (searchVal.isEmpty) {
      sfCampaignList = sfTempCampaignList;
    } else {
      sfCampaignList = sfTempCampaignList.where((e) {
        return e.name!.toLowerCase().contains(searchVal.toLowerCase());
      }).toList();
    }
    notify();
  }

  filterCamp() {
    if (campaignStatusList.isEmpty || campaignStatusList.contains('All')) {
      sfCampaignList = sfTempCampaignList;
    } else {
      sfCampaignList = sfTempCampaignList.where((e) {
        return campaignStatusList.contains(e.status);
      }).toList();
    }
    notify();
  }
}
