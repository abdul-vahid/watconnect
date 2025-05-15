import 'dart:convert';
import 'dart:developer';
import 'dart:io';

// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/core/models/base_view_model.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

import '../models/user_model/user_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../core/models/base_list_view_model.dart';
import '../utils/function_lib.dart';

class UserListViewModel extends BaseListViewModel {
  String? name;
  Future<dynamic> signup(UserModel userModel) async {
    String url = AppUtils.getUrl(AppConstants.signupAPIPath);
    return await post(url: url, body: userModel.toJson());
  }

  Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      print("Device: Android");
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // print("Aanaannn=>${androidInfo.id} ");
      // print("Aanaannndevice=>${androidInfo.device}");
      // print("Aanadeviceannn=>${androidInfo.name}");
      // print("ANDROID ID => ${androidInfo.androidId}");
      return androidInfo.id ?? "unknown_device_id";
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      print("Device: iOS");
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "unknown_device_id";
    } else {
      print("Device: Unsupported");
      return "unsupported_platform";
    }
  }

  // Future<dynamic> registerFCMToken(String token) async {
  //   String url = AppUtils.getUrl(AppConstants.notificationfcm);
  //   print("Notifcation Url=>${url}");
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String d = "";
  //   String device_id = "";

  //   var userModel = AppUtils.getSessionUser(prefs);
  //   Map<String, String> body = {
  //     "fcm_token":
  //         "dd75P88kT9GMCO7kzHa-wj:APA91bHlBX5C0TpaHYSuLygxfoky3cWFGAc6Of64bOIrSrJ_DK7XxMhp93M9v0XnIVNla6qNC94_rPFlijzmBh-2uY9Etlff_JVzuTFoVwlJAcezNKqyik0",
  //     "device_id": "860588055848157"
  //   };
  //   print("bodyyy=>$body");
  //   return post(url: url, body: jsonEncode(userModel));
  // }

  Future<dynamic> registerFCMToken(String token) async {
    String url = AppUtils.getUrl(AppConstants.notificationfcm);
    print("Notification URL => $url");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userModel = AppUtils.getSessionUser(prefs);

    String deviceId = await getDeviceId();

    Map<String, String> body = {"fcm_token": token, "device_id": deviceId};

    print("Request body => $body");

    return post(url: url, body: jsonEncode(body));
  }

  Future<dynamic> getOTP(String mobileNo, String reason) async {
    String url = AppUtils.getUrl(AppConstants.otpVerificationAPIPath);
    Map<String, String> requestData = {
      'contact_number': mobileNo,
      'reason': reason
    };
    var records = await post(url: url, body: jsonEncode(requestData));
    return records["message"];
  }

  Future<dynamic> updateProfilePicture(
      String userId, String profilePicture) async {
    String url = AppUtils.getUrl(AppConstants.profilePictureUpdateAPIPath);
    Map<String, String> requestData = {'id': userId, 'body': profilePicture};
    log("update body and url::: ${requestData}  ,  ${url}");
    var records = await post(url: url, body: jsonEncode(requestData));
    return records["records"]['profile_url'];
  }

  Future<void> uploadFile(File file, String staffRecord, String api) async {
    try {
      var url = Uri.parse(api);
      var token = await AppUtils.getToken();

      if (token == null || token.isEmpty) {
        print("Error: Token is missing.");
        return;
      }

      var request = http.MultipartRequest("PUT", url);

      // Attach file
      var multipartFile = await http.MultipartFile.fromPath("file", file.path);
      request.files.add(multipartFile);

      print("staffRecord:>>::>>>:: ${staffRecord}");
      String jsonString = jsonEncode(staffRecord);

      String formattedString = "\"$jsonString\"";
      print("staffRecord::: ${formattedString}");
      String correctedJson =
          formattedString.replaceAll("\"{", "{").replaceAll("}\"", "}");

      request.fields["staffRecord"] = correctedJson;

      // Set headers
      request.headers.addAll({
        "Authorization": token,
        "Content-Type": "multipart/form-data",
      });

      debug("Request URL: $url");

      debug("Request Fields: ${request.fields}");
      debug("Request Files: ${request.files}");

      //  Print Request Details
      print(" API URL: $api");
      print(" Headers: ${request.headers}");
      print(" Form Data:");
      request.fields.forEach((key, value) {
        print("   - $key: $value");
      });
      print(
          " Attached File: ${multipartFile.filename} (${multipartFile.length} bytes)");

      // Send the request
      var response = await request.send();

      // Print raw response
      print("Response Status: ${response.statusCode}");

      // Get response body
      var responseBody = await response.stream.bytesToString();
      print("Response Body: $responseBody");

      if (response.statusCode == 200) {
        print("File uploaded successfully!");
      } else {
        print("Upload failed: ${response.statusCode} - $responseBody");
      }
    } catch (e) {
      print(" Error: $e");
    }
  }

  Future<dynamic> changePasword(String mobileNo, String password) async {
    String url = AppUtils.getUrl(AppConstants.changePasswordAPIPath);

    Map<String, String> requestData = {
      'username': mobileNo,
      'password': password
    };

    var records = await post(url: url, body: jsonEncode(requestData));
    return records["message"];
  }

  Future<bool> makeLoginRequest(
      String username, String password, String tcode) async {
    EasyLoading.show();
    String url = AppUtils.getUrl(AppConstants.loginAPIPath);

    final headers = {
      'Content-Type': 'application/json',
    };

    final body =
        jsonEncode({'email': username, 'password': password, 'tcode': tcode});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      print("response.statusCode:::::: ${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        print("jsonResponse['success']::: ${jsonResponse}");

        if (jsonResponse['success'] == false) {
          EasyLoading.showToast(jsonResponse['errors']);
          return false;
        } else {
          var authToken = jsonResponse['authToken'];
          var refreshToken = jsonResponse['refreshToken'];
          print('Success: $jsonResponse');

          var records = jsonResponse is List ? jsonResponse : [jsonResponse];
          var modelMap =
              records.map((item) => UserModel.fromMap(item)).toList();
          viewModels =
              modelMap.map((item) => BaseViewModel(model: item)).toList();

          log(" modelMap ${modelMap}  ${modelMap.runtimeType}   viewModels  ${viewModels}");
          var userModel = modelMap[0];
          print(
              "viewModels: make : login: ${viewModels}   ${userModel}  ${userModel}");
          // var userModel = jsonResponse as UserModel;
          // print(
          //     "userModel: in other login api:: ${userModel}  ${userModel.runtimeType}");
          SharedPreferences.getInstance().then((prefs) async {
            await prefs.setString(
              SharedPrefsConstants.userKey,
              userModel.toJson(),
            );
            await prefs.setString(
              SharedPrefsConstants.refreshTokenKey,
              refreshToken ?? '',
            );
            await prefs.setString(
              SharedPrefsConstants.accessTokenKey,
              authToken ?? '',
            );
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

  Future<dynamic> login(String username, String password, String tcode) async {
    //final result = await UserService().login(username, password);
    debug("login");
    String url = AppUtils.getUrl(AppConstants.loginAPIPath);
    Map<String, String> requestData = {
      'email': username,
      'password': password,
      'tcode': tcode
    };

    String body = jsonEncode(requestData);
    debug('body==$body');

    var str = await postData(url: url, body: body, baseModel: UserModel());
    debug(viewModels.length);
    print("str::: ${str}");

    if (viewModels.isEmpty) {
      print("str as lsit::: ${[str]}");
      return str.toString();
    }

    return viewModels;
  }
}
