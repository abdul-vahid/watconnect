import 'dart:convert';

// ignore: unused_import
import 'package:flutter/cupertino.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

import '../models/user_model/user_model.dart';

import '../core/models/base_list_view_model.dart';
import '../utils/function_lib.dart';

class UserListViewModel extends BaseListViewModel {
  String? name;

  Future<dynamic> signup(UserModel userModel) async {
    String url = AppUtils.getUrl(AppConstants.signupAPIPath);
    return await post(url: url, body: userModel.toJson());
  }

  Future<dynamic> registerFCMToken(String token) async {
    //String url = AppUtils.getUrl(AppConstants.registerFCMTokenAPIPath);
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //var userModel = AppUtils.getSessionUser(prefs);
    /* Map<String, String> body = {
      "registration_id": token,
      "user_id": userModel?.authToken ?? ""
    }; */
    //return post(url: url, body: jsonEncode(body));
  }

  /* Future<dynamic> updateStudentProfile(UserModel userModel) async {
    String url = AppUtils.getUrl(
        "${AppConstants.studentProfileAPIPath}/${userModel.studentId}");

    return await post(url: url, body: userModel.toJson());
  } */

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
    var records = await post(url: url, body: jsonEncode(requestData));
    return records["records"]['profile_url'];
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

  // Future<void> updatePassword(String? id, UserDataModel userModel) async {
  //   // var id = "754d1acf-317e-4bf8-9084-f0fa8d26a8bc";
  //   String url = AppUtils.getUrl("${AppConstants.userPasswordAPIPath}/$id");
  //   debug(' check===update password$url');
  //   final result = await put(url: url, body: userModel.toJson());
  //   return result;
  // }
}
