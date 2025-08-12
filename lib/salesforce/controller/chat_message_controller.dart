import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/salesforce/controller/network_Services.dart';

import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:whatsapp/salesforce/model/sfCall_history_model.dart';
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

  void _setCallHistoryLoader(bool val) {
    notifyListeners();
  }

  Future<void> notify() async {
    await Future.delayed(Duration.zero);
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
    final url =
        "${AppConstants.sfMessageHistoryApi}businessnumber=$busNum&userwhatsappnumber=$userNumber&sortby=createdDate";
    final response = await NetworkService.makeRequest(
      url: url,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      chatHistoryList
        ..clear()
        ..addAll(data.map((e) => SfChatHistoryModel.fromJson(e)));
      log("Fetched ${chatHistoryList.length} chat messages.");
      notify();
    }

    _setChatHistoryLoader(false);

    final uploadController = Provider.of<SfFileUploadController>(
      navigatorKey.currentContext!,
      listen: false,
    );
    uploadController.resetFileUpload();
    setPlayPreviewStatus(false);
    setRecordingStatus(false);
    setSelectedFile(null);
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
      "businessnumber": busNum,
      "userWhatsAppNumber": fullNum,
      "messageBody": msg,
    };
    _setSendMsgLoader(true);
    const url = (AppConstants.sfSendMessageApi);
    final response =
        await NetworkService.makeRequest(url: url, method: 'POST', body: body);

    if (response != null && response.statusCode == 200) {
      await messageHistoryApiCall(userNumber: fullNum, isFirstTime: false);
      notify();
    }

    _setSendMsgLoader(false);
  }

  // Future<void> sendMessageApiCall({
  //   required String msg,
  //   required String usrNumber,
  //   required String code,
  // }) async {
  // final fullNum = "$code$usrNumber";
  // final prefs = await SharedPreferences.getInstance();
  // final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

  // final Map<String, dynamic> body = {
  //   "businessnumber": busNum,
  //   "userWhatsAppNumber": fullNum,
  //   "messageBody": msg,
  // };

  // _setSendMsgLoader(true);

  // try {
  //   final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
  //   final response = await http.post(
  //     Uri.parse(AppConstants.sfSendMessageApi),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(body),
  //   );

  //   if (response.statusCode == 200) {
  //     await messageHistoryApiCall(userNumber: fullNum, isFirstTime: false);
  //   } else {
  //     log("Send message failed [${response.statusCode}]: ${response.body}");
  //   }
  // } catch (e) {
  //   log("Error in sendMessageApiCall: $e");
  // } finally {
  //   _setSendMsgLoader(false);
  // }
  // }

  Future<bool> getSfAccessTokenApiCall(Map<String, dynamic> body) async {
    try {
      final encodedBody = Uri(queryParameters: body).query;

      final response = await http.post(
        Uri.parse(AppConstants.getToken),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: encodedBody,
      );

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        // print("parsedJson:::::::   $parsedJson");
        final accessToken = parsedJson["access_token"] ?? "";
        final refreshToken = parsedJson['refresh_token'] ?? "";

        if (accessToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              SharedPrefsConstants.sfAccessToken, accessToken);

          await prefs.setString(
              SharedPrefsConstants.sfRefreshToken, refreshToken);
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
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    String apiUrl =
        "${AppConstants.sfDeleteChatHistory}businessnumber=$busNum&whatsAppNumber=$wpNum";

    // final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

    final response = await NetworkService.makeRequest(
      url: apiUrl,
      method: 'DELETE',
    );

    if (response != null && response.statusCode == 200) {
      EasyLoading.showToast("Chat History Deleted Successfully");
      await messageHistoryApiCall(userNumber: wpNum, isFirstTime: false);
      notify();
    }
  }

  // Future<void> deleteHistoryApiCall(String wpNum) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final busNum =
  //         prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
  //     String apiUrl =
  //         "${AppConstants.sfDeleteChatHistory}businessnumber=${busNum}&whatsAppNumber=${wpNum}";

  //     final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

  //     final response = await http.delete(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     log("headers:::: ${"Bearer $token"}    ${apiUrl}");
  //     print(
  //         "delete history response :: ${response.runtimeType}  ${response.statusCode} ${response}");

  //     if (response.statusCode == 200) {
  //       EasyLoading.showToast("Chat History Deleted Successfully");
  //       await messageHistoryApiCall(userNumber: wpNum, isFirstTime: false);
  //     } else {
  //       log("delete history  API failed [${response.statusCode}]: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error in chat history delete api: $e");
  //   }
  //   notifyListeners();
  // }

  Future<void> chatMsgDeleteApiCall(String wpNum) async {
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    String ids = msgDeleteList.join(",");
    String apiUrl =
        "${AppConstants.sfDeleteChatMsg}businessnumber=$busNum&whatsAppNumber=$wpNum&metaMessageId=$ids";

    // final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

    final response = await NetworkService.makeRequest(
      url: apiUrl,
      method: 'DELETE',
    );

    if (response != null && response.statusCode == 200) {
      EasyLoading.showToast("Chat Messages Deleted Successfully");
      resetMsgDeleteList();
      await messageHistoryApiCall(userNumber: wpNum, isFirstTime: false);

      notify();
    }
  }

  // Future<void> chatMsgDeleteApiCall(String wpNum) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final busNum =
  //         prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

  //     String ids = msgDeleteList.join(",");

  //     String apiUrl =
  //         "${AppConstants.sfDeleteChatMsg}businessnumber=${busNum}&whatsAppNumber=${wpNum}&metaMessageId=$ids";

  //     final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

  //     final response = await http.delete(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     log("headers:::: ${"$token"}    ${apiUrl}");
  //     print(
  //         "delete msg response :: ${response.runtimeType}  ${response.statusCode} ${response}");

  //     if (response.statusCode == 200) {
  //       await messageHistoryApiCall(userNumber: wpNum, isFirstTime: false);
  //       EasyLoading.showToast("Chat Messages Deleted Successfully");
  //       resetMsgDeleteList();
  //       await messageHistoryApiCall(userNumber: wpNum, isFirstTime: false);
  //     } else {
  //       log("delete msg  API failed [${response.statusCode}]: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error in chat msg delete api: $e");
  //   }
  //   notifyListeners();
  // }

  List<String> msgDeleteList = [];

  setMsgDeleteList(String id) {
    if (msgDeleteList.contains(id)) {
      msgDeleteList.remove(id);
    } else {
      msgDeleteList.add(id);
    }

    log("ids to delete::::::    $msgDeleteList");
    notify();
  }

  resetMsgDeleteList() {
    msgDeleteList.clear();
    notify();
  }

  bool createFileLoader = false;

  void setCreateFileLoader(bool val) {
    createFileLoader = val;
    notifyListeners();
  }

  bool isRecording = false;
  bool isPlayingPreview = false;

  setRecordingStatus(bool val) {
    isRecording = val;
    notify();
  }

  setPlayPreviewStatus(bool val) {
    isPlayingPreview = val;
    notify();
  }

  bool isImage = false;
  bool isVideo = false;
  bool isDoc = false;
  bool isAudio = false;

  File? selectedFile;
  setSelectedFile(File? fil) {
    selectedFile = fil;
    if (fil == null) {
      isImage = false;
      isVideo = false;
      isDoc = false;
      isAudio = false;
    } else {
      final extension = path.extension(fil.path).toLowerCase();

      if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
          .contains(extension)) {
        isImage = true;
        isVideo = false;
        isDoc = false;
        isAudio = false;
      } else if (['.mp4', '.mov', '.avi', '.mkv', '.webm']
          .contains(extension)) {
        isImage = false;
        isVideo = true;
        isDoc = false;
        isAudio = false;
      } else if ([
        '.aac',
      ].contains(extension)) {
        isImage = false;
        isVideo = true;
        isDoc = false;
        isAudio = true;
      } else {
        isImage = false;
        isAudio = false;
        isVideo = false;
        isDoc = true;
      }
    }

    notify();
  }

  List<SfCallHistoryModel> callHistoryList = [];

  Future<void> callHistoryApiCall({
    String? userNumber,
  }) async {
    _setCallHistoryLoader(true);
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

    final url =
        "${AppConstants.sfCallHistoryApi}waNumber=$userNumber&businessNumber=$busNum";
    final response = await NetworkService.makeRequest(
      url: url,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      callHistoryList
        ..clear()
        ..addAll(data.map((e) => SfCallHistoryModel.fromJson(e)));
      log("Fetched ${callHistoryList.length} call history.");
      notify();
    }

    _setCallHistoryLoader(false);
  }
}
