import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:whatsapp/salesforce/api/api_helper.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:whatsapp/utils/app_constants.dart';

class ChatMessageController extends ChangeNotifier {
  final List<SfChatHistoryModel> chatHistoryList = [];

  bool _sendMsgLoader = false;
  bool _chatHistoryLoader = false;

  bool get sendMsgLoader => _sendMsgLoader;
  bool get chatHistoryLoader => _chatHistoryLoader;

  void _setSendMsgLoader(bool val) {
    _sendMsgLoader = val;
    notifyListeners();
  }

  void _setChatHistoryLoader(bool val) {
    _chatHistoryLoader = val;
    notifyListeners();
  }

  Future<void> messageHistoryApiCall({
    required String? userNumber,
    bool isFirstTime = true,
  }) async {
    if (userNumber == null || userNumber.isEmpty) {
      log("User number is missing");
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

    if (isFirstTime) _setChatHistoryLoader(true);

    final String url =
        "${AppConstants.sfMessageHistoryApi}businessnumber=${busNum}&userwhatsappnumber=$userNumber&sortby=createdDate";

    try {
      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      log("headers:::: ${"Bearer $token"}    ${url}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        chatHistoryList
          ..clear()
          ..addAll(data.map((e) => SfChatHistoryModel.fromJson(e)));
        log("Fetched ${chatHistoryList.length} chat messages.");
      } else {
        log("History API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      log("Error in messageHistoryApiCall: $e");
    }

    if (isFirstTime) _setChatHistoryLoader(false);
  }

  Future<void> sendMessageApiCall({
    required String msg,
    required String usrNumber,
    required String code,
  }) async {
    final fullNum = "$code$usrNumber";
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

    final Map<String, dynamic> body = {
      "businessNumber": "${busNum}",
      "userWhatsAppNumber": fullNum,
      "messageBody": msg,
    };

    _setSendMsgLoader(true);

    try {
      final response = await AppApi().commonPostMethod(
        AppConstants.sfSendMessageApi,
        body,
        sendToken: true,
      );

      if (response?.statusCode == 200) {
        await messageHistoryApiCall(userNumber: fullNum, isFirstTime: false);
      } else {
        log("Send message failed [${response?.statusCode}]: ${response?.body}");
      }
    } catch (e) {
      log("Error in sendMessageApiCall: $e");
    } finally {
      _setSendMsgLoader(false);
    }
  }

  Future<bool> getSfAccessTokenApiApiCall(Map<String, dynamic> body) async {
    try {
      final encodedBody = Uri(queryParameters: body).query;

      final response = await http.post(
        Uri.parse(AppConstants.getToken),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: encodedBody,
      );

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        final accessToken = parsedJson["access_token"] ?? "";

        if (accessToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              SharedPrefsConstants.sfAccessToken, accessToken);
          log("Access token stored successfully.");
          return true;
        }
      } else {
        log("Token fetch failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      log("Error in getSfAccessTokenApiApiCall: $e");
    }

    return false;
  }

  Future<void> deleteHistoryApiCall(String wpNum) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final busNum =
          prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      String apiUrl =
          "${AppConstants.sfDeleteMsgHistory}businessNumber=${busNum}&whatsAppNumber=${wpNum}";

      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      log("headers:::: ${"Bearer $token"}    ${apiUrl}");
      print(
          "delete history response :: ${response.runtimeType}  ${response.statusCode} ${response}");

      if (response.statusCode == 200) {
        EasyLoading.showToast("Chat History Deleted Successfully");
        await messageHistoryApiCall(userNumber: wpNum, isFirstTime: false);
      } else {
        log("delete history  API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      print("Error in chat history delete api: $e");
    }
    notifyListeners();
  }
}
