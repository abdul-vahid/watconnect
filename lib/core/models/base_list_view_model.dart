import 'dart:convert';
import 'dart:developer';
// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/apis/app_exception.dart';
import '../../core/models/base_model.dart';
import '../../core/models/base_view_model.dart';
import '../../core/services/base_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_utils.dart';
import '../../utils/function_lib.dart';

class BaseListViewModel extends ChangeNotifier {
  var viewModels = [];
  var status = "Loading";
  Exception? exception;
  bool get isError {
    return status == "Error";
  }

  BuildContext? get context => null;

  Future get(
      {required BaseModel baseModel,
      required String url,
      String jsonKey = "records",
      bool showToast = false}) async {
    log("get api url>>> ${url}   ");

    try {
      final jsonObject = await BaseService().get(url: url);
      // await _refreshToken(url, jsonKey);
      log("Response Data get == $jsonObject ${url}");
      // print("jsonObject:: ${jsonObject.runtimeType}");
      if (showToast) {
        if (jsonObject is Map<String, dynamic> &&
            jsonObject.containsKey('success') &&
            jsonObject['success'] == false) {
          EasyLoading.showToast(jsonObject['message']);
        }
      }

      print("jsonObject is! List:::: ${jsonObject is! List}");
      var records = jsonObject;
      if (jsonObject is! List) {
        debug("not an array");
        records = [jsonObject];
        // return records;
      }
      print(
          ":____________________>>>>>>>>>> ${url} ${records.length}   ${records.runtimeType}  ${records}  ${records[0]['records']}");
      try {
        var rec = records[0]['records'];
        var modelMap = records.map((item) => baseModel.fromMap(item)).toList();

        print("modelMap::::::::: ${modelMap}   ${url}   ");

        viewModels =
            modelMap.map((item) => BaseViewModel(model: item)).toList();

        // print("execute of the get method ${url}  ${viewModels}  ");
      } catch (e, stackTrace) {
        print("catching error in parsing :: ${e}     $stackTrace");
      }
      status = "Completed";
    } on UnauthorisedException {
      await _refreshToken(url);

      final jsonObjectRequest = await BaseService().get(url: url);
      var records = jsonObjectRequest;
      if (jsonObjectRequest is! List) {
        records = [jsonObjectRequest];
      }
      debug("Response Data === $records");
      //AppUtils.printDebug("Response Data === $records");
      var modelMap = records.map((item) => baseModel.fromMap(item)).toList();
      viewModels = modelMap.map((item) => BaseViewModel(model: item)).toList();
      status = "Completed";
    } on AppException catch (error) {
      status = "Error";
      exception = error;
      viewModels.add(BaseViewModel(model: BaseModel()));
    } on Exception catch (e) {
      print("e:::::::::::::: ${e}");
      exception = e;
      status = "Error";
      viewModels.add(BaseViewModel(model: BaseModel()));
    } catch (e) {
      exception = Exception(e.toString());
      status = "Error";
    }

    notifyListeners();
  }

  Future<void> _refreshToken(String url) async {
    String refreshTokenUrl = AppUtils.getUrl(AppConstants.refreshTokenAPIPath);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String refreshToken = "";
      String accessToken = "";
      if (prefs.containsKey(SharedPrefsConstants.refreshTokenKey)) {
        refreshToken = prefs.getString(SharedPrefsConstants.refreshTokenKey)!;
      }
      //if (prefs.containsKey(SharedPrefsConstants.sessionTimeKey)) {
      // String sessionTime;
      // int minutes = 0;
      // if (prefs.containsKey(SharedPrefsConstants.sessionTimeKey)) {
      //   sessionTime = prefs.getString(SharedPrefsConstants.sessionTimeKey)!;
      //   var sessionDT = DateFormat('yyyy-MM-dd HH:mm:ss').parse(sessionTime);
      //   minutes = DateTime.now().difference(sessionDT).inMinutes;
      // }

      // if (minutes > 119) {
      Map<String, String> body = {"refreshToken": refreshToken};
      debug("rftgyhjuhgtfrderftghyjkjhygttgyhuj${body}");
      final jsonObject = await postForRefreshToken(
          url: refreshTokenUrl, body: jsonEncode(body));

      accessToken = jsonObject["authToken"];
      refreshToken = jsonObject["refreshToken"];
      // debug("Refresh Token == $refreshToken");
      // debugLog("zauuu Token == $accessToken");
      await prefs.setString(SharedPrefsConstants.accessTokenKey, accessToken);
      await prefs.setString(SharedPrefsConstants.refreshTokenKey, refreshToken);
      await prefs.setString(
          SharedPrefsConstants.sessionTimeKey, DateTime.now().toString());
      // }
    } on UnauthorisedException {
      //showAlert and Logout
      AppUtils.getAlert(AppUtils.currentContext!, [
        "You have been logged out!",
      ], onPressed: () {
        AppUtils.logout(AppUtils.currentContext);
      });
    } on AppException catch (error) {
      exception = error;
      status = "Error";
      viewModels.add(BaseViewModel(model: BaseModel()));
    } on Exception catch (error) {
      status = "Error";
      exception = error;
      viewModels.add(BaseViewModel(model: BaseModel()));
    } catch (e) {
      status = "Error";
      exception = Exception(e.toString());
      viewModels.add(BaseViewModel(model: BaseModel()));
    }
  }

  // ------------
  Future<dynamic> postForRefreshToken({
    required String url,
    required String body,
  }) async {
    try {
      return await BaseService().post(url: url, body: body);
    } on UnauthorisedException {
      AppUtils.getAlert(AppUtils.currentContext!, [
        "You have been logged out!",
      ], onPressed: () {
        Navigator.pop(AppUtils.currentContext!);
        AppUtils.logout(AppUtils.currentContext);
      });
    }
  }

  Future<dynamic> post(
      {required String url,
      required String body,
      String jsonKey = "records",
      bool showToast = false}) async {
    log("req body>> ${url} >>>>>> ${body}");

    try {
      var r = await BaseService().post(url: url, body: body);
      // log("response=>$r    api>>> ${url}");
      if (showToast) {
        if (r is Map<String, dynamic> &&
            r.containsKey('success') &&
            r['success'] == false) {
          EasyLoading.showToast(r['message']);
        }
      }
      print("r  is to return:::::::::::  ${r}");
      return r;
    } on UnauthorisedException {
      await _refreshToken(url);
      return await BaseService().post(url: url, body: body);
    }
  }

  Future<dynamic> put(
      {required String url,
      required String body,
      String jsonKey = "records"}) async {
    try {
      print("bodyyy user update=>$body");
      return await BaseService().put(url: url, body: body);
    } on UnauthorisedException {
      await _refreshToken(url);
      return await BaseService().put(url: url, body: body);
    }
  }

  Future<dynamic> delete({required String url, String? body}) async {
    try {
      print("bdoodododododoy=>$body");
      return await BaseService().delete(url: url, body: body);
    } on UnauthorisedException {
      await _refreshToken(url);
      return await BaseService().delete(url: url, body: body);
    }
  }

  Future<String> postData(
      {required BaseModel baseModel,
      required String url,
      required String body,
      String jsonKey = "records"}) async {
    try {
      debug("postData");
      final jsonObject = await BaseService().post(url: url, body: body);
      print(
          "responseJsonData:  ${jsonObject['errors']}  ${jsonObject['authToken']}");

      if (jsonObject['success'] == false) {
        return jsonObject['errors'].toString();
      }

      var records = jsonObject is List ? jsonObject : [jsonObject];

      var modelMap = records.map((item) => baseModel.fromMap(item)).toList();
      viewModels = modelMap.map((item) => BaseViewModel(model: item)).toList();
      status = "Completed";
    } on UnauthorisedException {
      await _refreshToken(url);
      final jsonObject = await BaseService().post(url: url, body: body);
      print("jsonObject['errors'] error::::::${jsonObject['errors']}");
      if (jsonObject['errors'] != null) {
        print("jsonObject['errors']::::::${jsonObject['errors'].toString()}");
        return jsonObject['errors'].toString();
      }

      final records = jsonObject[jsonKey];
      var modelMap = records.map((item) => baseModel.fromMap(item)).toList();
      viewModels = modelMap.map((item) => BaseViewModel(model: item)).toList();
      status = "Completed";
    } on AppException catch (error) {
      status = "Error";
      exception = error;
      viewModels.add(BaseViewModel(model: BaseModel()));
    } on Exception catch (e) {
      exception = e;
      status = "Error";
      viewModels.add(BaseViewModel(model: BaseModel()));
    } catch (e) {
      print("error:::here  ${e}");
      exception = Exception(e.toString());
      status = "Error";
    }

    notifyListeners();
    return "";
  }
}
