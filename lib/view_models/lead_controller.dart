import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/models/lead_list_model.dart';
import 'package:whatsapp/utils/app_constants.dart';

class LeadController extends ChangeNotifier {
  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  List<LeadListModel> leadList = [];
  List<LeadListModel> tempLeadList = [];

  bool leadLoader = false;

  setLeadLoader(bool val) {
    leadLoader = val;
    notify();
  }

  Future<void> getLeadListApiCall({bool showLoader = true}) async {
    try {
      if (showLoader) {
        setLeadLoader(true);
      }
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPrefsConstants.accessTokenKey) ?? "";

      final response = await http.get(
        Uri.parse(AppConstants.leadAPIPath),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log("headers::::  ${AppConstants.leadAPIPath}");
      print(
          "check balance response :: ${response.runtimeType}  ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var rec = data['records'];
        leadList
          ..clear()
          ..addAll(rec.map((e) => LeadListModel.fromJson(e)));

        tempLeadList = leadList;
        notify();
      } else {}

      setLeadLoader(false);
    } catch (e) {
      setLeadLoader(false);
    }
  }
}
