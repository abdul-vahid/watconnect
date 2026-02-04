// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/network_Services.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/utils/notification_utils.dart';

class SfFileUploadController extends ChangeNotifier {
  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  String fileDocId = "";
  setFileDocId(String docId) {
    fileDocId = docId;
    log("file upload doc id::::::   $fileDocId");
    notify();
  }

  String fileMimeType = "";
  setFileMimeType(String mimeType) {
    fileMimeType = mimeType;
    log("file fileMimeType::::::   $fileMimeType");
    notify();
  }

  bool fileUploadLoader = false;

  setFileUploadLoader(bool val) {
    fileUploadLoader = val;
    notify();
  }

  resetFileUpload() {
    setPublicUrlId("");
    setFileUploadLoader(false);
    setFileMimeType("");
    setFileDocId("");
    // print(
    //     "reseting all:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
    notify();
  }

  String filePubUrl = "";

  setPublicUrlId(String? title) async {
    if (title == null || title.isEmpty) {
      log("❌ Title is null/empty. URL not set.");
      return;
    }

    final encodedTitle = Uri.encodeComponent(title);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(SharedPrefsConstants.sfNodeTennatCode) ?? "";
    final nodeBaseUrlSf =
        prefs.getString(SharedPrefsConstants.sfNodeBaseUrl) ?? "";
    String baseImgUrl = nodeBaseUrlSf.contains('sandbox.watconnect')
        ? "https://sandbox.watconnect.com/"
        : "https://admin.watconnect.com/";

    filePubUrl = "${baseImgUrl}public/$token/attachment/$encodedTitle";

    log("file upload public url:::::: $filePubUrl");

    notify();
  }

  Future<void> getReactCredApiCall() async {
    // String apiUrl = AppConstants.sfGetReactLoginCredApi;

    String apiUrl =
        await AppUtils.getSFUrl(AppConstants.sfGetReactLoginCredApi);
    final response = await NetworkService.makeRequest(
      url: apiUrl,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      var body = jsonDecode(response.body);
      print(
          "response  sfGetReactLoginCredApi      ${response.body}  $body  ${body['password']}");

      final prefs = await SharedPreferences.getInstance();

      bool isSandbox =
          body['endpoint'].toString().contains('sandbox.watconnect');
      prefs.setString(
          SharedPrefsConstants.sfNodeBaseUrl, body['endpoint'].toString());
      sfNodeLoginRequest(
        body['username'],
        body['password'],
        body['company_name'],
        body['endpoint'],
      );
    }
    notify();
  }

  Future<bool> sfNodeLoginRequest(
      String username, String password, String tcode, String baseUrl) async {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(username)) {
      EasyLoading.showToast("Please enter a valid email address");
      return false;
    }
    EasyLoading.show();
    String url = "$baseUrl/auth/login";
    // AppUtils.getUrl(AppConstants.loginAPIPath);
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'email': username,
      'password': password,
      'tcode': tcode,
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      log(" login api in SF response.statusCode:::::: $url   ${response.statusCode}  $body  ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        print("jsonResponse['success']::: $jsonResponse");

        if (jsonResponse['success'] == false) {
          EasyLoading.showToast(jsonResponse['errors']);
          return false;
        } else {
          var authToken = jsonResponse['authToken'];
          var refreshToken = jsonResponse['refreshToken'];
          print('Success: $jsonResponse    authToken::   $authToken');

          Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);
          print(
              "decodedToken::::::  $decodedToken      tenantcode     ${decodedToken['tenantcode'] ?? ""}");

          SharedPreferences.getInstance().then((prefs) async {
            await prefs.setString(
              SharedPrefsConstants.sfNodeToken,
              authToken ?? '',
            );

            await prefs.setString(
              SharedPrefsConstants.sfNodeRefreshToken,
              refreshToken ?? '',
            );

            await prefs.setString(
              SharedPrefsConstants.sfNodeTennatCode,
              decodedToken['tenantcode'] ?? "",
            );

            final token =
                prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
            log("get token after set ytoken:::::::::::    $token");
          });

          NotificationUtil.registerToken();

          EasyLoading.dismiss();
          return true;
        }
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Body: ${response.body}');
        final jsonResponse = jsonDecode(response.body);
        EasyLoading.dismiss();
        EasyLoading.showToast(jsonResponse['errors']);
        return false;
      }
    } catch (e) {
      print('Error during POST: $e');
      EasyLoading.dismiss();
      return false;
    }
  }

  Future<void> refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String baseUrl = prefs.getString(SharedPrefsConstants.sfNodeBaseUrl) ?? "";
    String refreshTokenUrl = baseUrl + AppConstants.refreshTokenAPIPath;
    // AppUtils.getUrl(AppConstants.refreshTokenAPIPath);
    try {
      var refshtokn = prefs.getString(
            SharedPrefsConstants.sfNodeRefreshToken,
          ) ??
          "";
      Map<String, String> body = {"refreshToken": refshtokn};

      final response = await http.post(
        Uri.parse(refreshTokenUrl),
        // headers: headers,
        body: body,
      );
      print(
          "  refresh token api  $refreshTokenUrl response.statusCode:::::: ${response.statusCode}   ${response.body}");
      var jsonResponse = jsonDecode(response.body);

      var authToken = jsonResponse['authToken'];
      var refreshToken = jsonResponse['refreshToken'];
      await prefs.setString(SharedPrefsConstants.sfNodeToken, authToken);
      await prefs.setString(SharedPrefsConstants.refreshTokenKey, refreshToken);
      EasyLoading.showToast("Retry again......");
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> uploadFiledb(
    File file,
    String cntryCode,
    String txtMsg,
    String ursNo, {
    bool isFromTemplate = false,
  }) async {
    setFileUploadLoader(true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
    print("sf node token:::   ${token}");
    if (token.isEmpty) {
      setFileUploadLoader(false);
      throw Exception("No token found");
    }

    final url = Uri.parse("${AppConstants.baseUrl}/api/whatsapp/files/null");
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    setFileMimeType(mimeType);

    final fileStream = http.ByteStream(file.openRead());
    final length = await file.length();

    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: file.path.split('/').last,
      contentType: MediaType.parse(mimeType),
    );

    final request = http.MultipartRequest("POST", url)
      ..files.add(multipartFile)
      ..headers.addAll({
        "Authorization": token,
        "Content-Type": "multipart/form-data",
      });

    try {
      final streamedResponse = await request.send();
      debug("streamedResponse${streamedResponse.statusCode}");
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        setFileUploadLoader(false);
        final map = jsonDecode(responseBody);
        log("map['records']: ${map['records'][0]['id']}");
        log("map['rezzzzzzzzzcords']: $map");
        // setPublicUrlId(map['records'][0]['title']);
        final title = map['records']?[0]?['title'];

        if (title != null && title.toString().isNotEmpty) {
          setPublicUrlId(title);
        } else {
          log("❌ Title missing in response");
        }
        await uploadFile(file, cntryCode, txtMsg, ursNo,
            isTemplate: isFromTemplate);
        return responseBody;
      } else if (streamedResponse.statusCode == 401 ||
          streamedResponse.statusCode == 403) {
        setFileUploadLoader(false);

        _handleAuthError();

        throw HttpException("Unauthorized or Forbidden", uri: url);
      } else {
        print(
            "streamedResponse.statusCode:::    ${streamedResponse.statusCode}   ${streamedResponse.stream}");
        setFileUploadLoader(false);
        throw HttpException(
            "Unexpected server response: ${streamedResponse.statusCode}",
            uri: url);
      }
    } catch (e) {
      setFileUploadLoader(false);
      rethrow;
    }
  }

  Future<dynamic> uploadFile(File file, String code, String mesg, String numbr,
      {required bool isTemplate}) async {
    debug("uploadFileuploadFileuploadFile");
    setFileUploadLoader(true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";

    if (token.isEmpty) {
      debug("Missing token!");
      return null;
    }

    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    final url = Uri.parse(
      "${AppConstants.baseUrl}/api/webhook_template/documentId?whatsapp_setting_number=$busNum",
    );
    debug("upload file url::::::   $url");
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final fileStream = http.ByteStream(file.openRead());
    final length = await file.length();
    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: file.path.split('/').last,
      contentType: MediaType.parse(mimeType),
    );
    final request = http.MultipartRequest("POST", url)
      ..files.add(multipartFile)
      ..headers.addAll({
        "Authorization": token,
        // No need to add Content-Type for multipart
      });

    log("Uploading file to $url");

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    debug("File uploaded successfully: webhook_template $responseBody");
    debug(
        "File uploaded successfully: webhook_template $responseBody.statusCode ${response.statusCode}");
    if (response.statusCode == 200) {
      debug("File uploaded successfully: webhook_template $responseBody");
      setFileUploadLoader(false);
      // debug("File uploaded successfully: webhook_template $responseBody");
      var mp = jsonDecode(responseBody);
      debug("mp['id']:sssssssss::::${mp}");
      debug("mp['id']::::::${mp['id']}");
      setFileDocId(mp['id']);

      if (isTemplate) {
      } else {
        sendFileApiCall(code: code, fil: file, msg: mesg, usrNumber: numbr);
      }

      return responseBody;
    } else {
      setFileUploadLoader(false);
      debug(
          "File upload failed: ${response.statusCode} - ${response.reasonPhrase}");
      return null;
    }
  }

  Future<void> sendFileApiCall({
    required String msg,
    required String usrNumber,
    required String code,
    required File fil,
  }) async {
    setFileUploadLoader(true);

    final fullNum = "$code$usrNumber";
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    String fileName = path.basename(fil.path);
    String ext = path.extension(fil.path).replaceFirst('.', '');
    String? mimeType = lookupMimeType(fil.path);
    String type = "";
    if (mimeType!.startsWith('image/')) {
      type = "image";
    } else if (mimeType.startsWith('audio/')) {
      type = "audio";
    } else if (mimeType.startsWith('video/')) {
      type = "video";
    } else {
      type = "document";
    }

    final Map<String, dynamic> body = {
      "businessnumber": busNum,
      "userWhatsAppNumber": fullNum,
      "url": filePubUrl,
      "content_type": mimeType,
      "document_id": fileDocId,
      "smsBody": msg,
      "fileExtension": ext,
      "fileName": fileName,
      "document_type": type
    };

    log("send file api request body::::  $body");
    String apiUrl = await AppUtils.getSFUrl(AppConstants.sfSendFileApi);

    final response = await NetworkService.makeRequest(
        url: apiUrl, method: 'POST', body: body);
    if (response != null && response.statusCode == 200) {
      ChatMessageController chatMessageController =
          Provider.of(navigatorKey.currentContext!, listen: false);
      await chatMessageController.messageHistoryApiCall(
          userNumber: fullNum, isFirstTime: false);
    }
    setFileUploadLoader(false);
    notify();
  }

  void _handleAuthError() {
    refreshToken();
  }
}
