// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/models/call_history_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/utils/function_lib.dart';
import '../core/models/base_list_view_model.dart';

// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

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

  Future<dynamic> uploadRecFiledb(File file) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";

    if (token.isEmpty) {
      print("❌ No token found");
      return null;
    }

    // Check if your base URL is correct
    var url = Uri.parse("${AppConstants.baseUrl}/api/whatsapp/files/null");
    print("🔗 Request URL: $url");

    var request = http.MultipartRequest("POST", url);

    // Detect MIME type for audio file
    final mimeType = 'audio/mp4'; // or 'audio/m4a' for m4a files
    final fileStream = http.ByteStream(file.openRead());
    final length = await file.length();

    // Attach file
    var multipartFile = http.MultipartFile(
      'file', // Make sure this field name matches what your backend expects
      fileStream,
      length,
      filename:
          'recording_${DateTime.now().millisecondsSinceEpoch}.m4a', // Better filename
      contentType: MediaType.parse(mimeType),
    );

    request.files.add(multipartFile);

    // Add headers - remove Content-Type for multipart requests as it's set automatically
    request.headers.addAll({
      "Authorization": "Bearer $token", // Add Bearer if required
    });

    // Debug information
    print("📋 Request Headers: ${request.headers}");
    print("📁 File: ${file.path.split('/').last} (${length ~/ 1024} KB)");
    print(
        "🔑 Token: ${token.substring(0, 20)}..."); // Log first 20 chars for security

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("📡 Response Status: ${response.statusCode}");
      print("📄 Response Body: $responseBody");

      if (response.statusCode == 200) {
        print("✅ File uploaded successfully");
        return responseBody;
      } else {
        print(
            "❌ Failed to upload file: ${response.statusCode} - ${response.reasonPhrase}");
        print("🔍 Response body: $responseBody");
        return null;
      }
    } catch (e, stackTrace) {
      print("💥 Error occurred during file upload: $e");
      print("📝 Stack trace: $stackTrace");
      return null;
    }
  }
}
