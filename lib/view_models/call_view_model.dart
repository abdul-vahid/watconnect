// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/models/call_history_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:flutter/material.dart';
import '../core/models/base_list_view_model.dart';

class CallsViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  CallsViewModel(this.context);

  get record => null;

  Future<String?> getCallHistory() async {
    final prefs = await SharedPreferences.getInstance();
    var businessNumber = prefs.getString('phoneNumber') ?? "";
    String url = AppUtils.getUrl(
        AppConstants.callHistoryApi.replaceAll('{}', businessNumber));
    var res = await get(url: url, baseModel: callHistoryModel());
    print("response::::::of call history api:::::::   $res");
    return res;
  }

  Future<String?> callAcceptApi(Map<String, dynamic> body) async {
    String url = AppUtils.getUrl(AppConstants.callAcceptApi);
    var res = await post(url: url, body: jsonEncode(body));
    print("response::::::of call accept api::::::: ${res.runtimeType}  $res");
    return jsonEncode(res);
  }

  Future<String?> outgoingCallApi(Map<String, dynamic> body) async {
    String url = AppUtils.getUrl(AppConstants.outgoingCall);
    var res = await post(url: url, body: jsonEncode(body));
    print("response::::::of call outgoingCallApi api:::::::   $res");
    return res.toString();
  }

  Future<String?> callRejectApi(Map<String, dynamic> body) async {
    String url = AppUtils.getUrl(AppConstants.callRejectApi);
    var res = await post(url: url, body: jsonEncode(body));
    print(
        "response::::::of call history callRejectApi api:::::::   $res          ${res.runtimeType}");
    return jsonEncode(res);
  }

  Future<String?> startCallApi(String busNum, String num) async {
    String url = AppUtils.getUrl(
      AppConstants.initiateCallApi
          .replaceAll("{business_number}", busNum)
          .replaceAll("{whatsapp_number}", num.replaceAll("+", '')),
    );

    var res = await get(url: url, baseModel: callHistoryModel());
    print("response::::::of start call api:::::::   $res");
    return res;
  }
}
