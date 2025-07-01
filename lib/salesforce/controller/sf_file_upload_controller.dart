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
import 'package:whatsapp/core/apis/app_exception.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/salesforce/api/api_helper.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

import 'dart:convert' show jsonEncode;

import 'package:http_parser/http_parser.dart';
import 'package:whatsapp/utils/function_lib.dart';

class SfFileUploadController extends ChangeNotifier {
  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  String fileDocId = "";
  setFileDocId(String docId) {
    fileDocId = docId;
    log("file upload doc id::::::   ${fileDocId}");
    notify();
  }

  String filePubUrl = "";
  setPublicUrlId(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(SharedPrefsConstants.sfNodeTennatCode) ?? "";
    filePubUrl = "${AppConstants.baseImgUrl}public/${token}/attachment/$title";
    log("file upload public url::::::   ${filePubUrl}");

    notify();
  }

  Future<bool> sfNodeLoginRequest(
      String username, String password, String tcode) async {
    // Email regex validation
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(username)) {
      EasyLoading.showToast("Please enter a valid email address");
      return false;
    }
    EasyLoading.show();
    String url = AppUtils.getUrl(AppConstants.loginAPIPath);
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
      log(" login api in SF response.statusCode:::::: ${response.statusCode}   ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        print("jsonResponse['success']::: $jsonResponse");

        if (jsonResponse['success'] == false) {
          EasyLoading.showToast(jsonResponse['errors']);
          return false;
        } else {
          var authToken = jsonResponse['authToken'];
          var refreshToken = jsonResponse['refreshToken'];
          print('Success: $jsonResponse    authToken::   ${authToken}');

          Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);
          print(
              "decodedToken::::::  ${decodedToken}      tenantcode     ${decodedToken['tenantcode'] ?? ""}");

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
                await prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
            log("get token after set ytoken:::::::::::    ${token}");
          });

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

  Future<void> _refreshToken(String url) async {
    String refreshTokenUrl = AppUtils.getUrl(AppConstants.refreshTokenAPIPath);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String refreshToken = "";
      String accessToken = "";
      if (prefs.containsKey(SharedPrefsConstants.sfNodeRefreshToken)) {
        refreshToken =
            prefs.getString(SharedPrefsConstants.sfNodeRefreshToken)!;
      }
      Map<String, String> body = {"refreshToken": refreshToken};

      final response = await http.post(
        Uri.parse(url),
        // headers: headers,
        body: body,
      );
      print(
          "response.statusCode:::::: ${response.statusCode}   ${response.body}");

      await prefs.setString(SharedPrefsConstants.sfNodeToken, accessToken);
      await prefs.setString(SharedPrefsConstants.refreshTokenKey, refreshToken);
      await prefs.setString(
          SharedPrefsConstants.sessionTimeKey, DateTime.now().toString());
    } catch (e) {}
    // on UnauthorisedException {

    //   AppUtils.getAlert(AppUtils.currentContext!, [
    //     "You have been logged out!",
    //   ], onPressed: () {
    //     AppUtils.logout(AppUtils.currentContext);
    //   });
    // } on AppException catch (error) {
    //   exception = error;
    //   status = "Error";
    //   viewModels.add(BaseViewModel(model: BaseModel()));
    // } on Exception catch (error) {
    //   status = "Error";
    //   exception = error;
    //   viewModels.add(BaseViewModel(model: BaseModel()));
    // } catch (e) {
    //   status = "Error";
    //   exception = Exception(e.toString());
    //   viewModels.add(BaseViewModel(model: BaseModel()));
    // }
  }

  Future<dynamic> uploadFiledb(
      File file, String cntryCode, String txtMsg, String ursNo) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
    log("token::::::: node sf  ${file}  ${token}");
    if (token == null || token.isEmpty) {
      print("No token found");
      return null;
    }
    var url = Uri.parse("${AppConstants.baseUrl}/api/whatsapp/files/null");
    print("Request URL: $url");
    var request = http.MultipartRequest("POST", url);

    // Detect MIME type
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final fileStream = http.ByteStream(file.openRead());
    final length = await file.length();

    // Attach file
    var multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: file.path.split('/').last,
      contentType: MediaType.parse(mimeType),
    );

    request.files.add(multipartFile);

    // Add headers
    request.headers.addAll({
      "Authorization": token,
      "Content-Type": "multipart/form-data",
    });
    debug("Request URL hhh: $url");
    debug("Request Headers jj: ${request.headers}");
    debug("Request Fields: ${request.fields}");
    debug("Request Files: ${request.files}");
    try {
      var response = await request.send();
      debug("response.statusCode${response.statusCode}   ");
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        print("File uploaded successfully");
        debug("File uploaded successfully $responseBody");
        var map = jsonDecode(responseBody);
        setPublicUrlId(map['records'][0]['title']);
        uploadFile(file, cntryCode, txtMsg, ursNo);
        return responseBody;
      } else {
        print("Failed to upload file: ${response.reasonPhrase}");
        return null;
      }
    } on UnauthorisedException {
      String url = Uri.https(AppConstants.baseUrl, "/api/whatsapp/files/null")
          .toString();

      await _refreshToken(url);
    } catch (e) {
      print("Error occurred during file upload   uploadFiledb: $e");
      return null;
    }
  }

  Future<dynamic> uploadFile(
      File file, String code, String mesg, String numbr) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";

    if (token == null || token.isEmpty) {
      debug("Missing token!");
      return null;
    }

    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    final url = Uri.parse(
      "${AppConstants.baseUrl}/api/webhook_template/documentId?whatsapp_setting_number=$busNum",
    );
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

    if (response.statusCode == 200) {
      debug("File uploaded successfully: webhook_template $responseBody");
      var mp = jsonDecode(responseBody);
      setFileDocId(mp['id']);

      sendFileApiCall(code: code, fil: file, msg: mesg, usrNumber: numbr);
      return responseBody;
    } else {
      debug(
          "File upload failed: ${response.statusCode} - ${response.reasonPhrase}");
      return null;
    }
  }

  bool _sendFileLoader = false;
  void _setSendFileLoader(bool val) {
    _sendFileLoader = val;
    notifyListeners();
  }

  Future<void> sendFileApiCall({
    required String msg,
    required String usrNumber,
    required String code,
    required File fil,
  }) async {
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

    _setSendFileLoader(true);

    try {
      final response = await AppApi().commonPostMethod(
        AppConstants.sfSendFileApi,
        body,
        sendToken: true,
      );

      if (response?.statusCode == 200) {
        ChatMessageController chatMessageController =
            Provider.of(navigatorKey.currentContext!, listen: false);
        await chatMessageController.messageHistoryApiCall(
            userNumber: fullNum, isFirstTime: false);
      } else {
        log("Send message failed [${response?.statusCode}]: ${response?.body}");
      }
    } catch (e) {
      log("Error in sendMessageApiCall: $e");
    } finally {
      _setSendFileLoader(false);
    }
  }
}
