// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import '../../services/api_service.dart';
import '../../utils/app_utils.dart';
import '../../utils/function_lib.dart';

class BaseService {
  static final APIService _apiService = APIService();
  Future<ApiResponse> get({required String url}) async {
    var token = await AppUtils.getToken();
    ApiResponse responseJsonData = await _apiService.getResponse(url, token!);
    log("token:::::: $token");
    log("responseiso=>$responseJsonData");
    return responseJsonData;
  }

  Future<ApiResponse> post({required String url, required String body}) async {
    var token = await AppUtils.getToken();
    // debugLog("Token a == $token");
    token ??= "";
    // printLongString("body base service send= $body");
    final responseJsonData = await _apiService.postResponse(url, body, token);
    print("responseJsonData::post:: from the api::: $responseJsonData");
    // print("rsponse==>$responseJsonData");
    return responseJsonData;
  }

  Future<ApiResponse> delete({required String url, String? body}) async {
    var token = await AppUtils.getToken();
    // debug("Token == $token");
    token ??= "";
    // printLongString("deletete send= $body");
    final responseJsonData =
        await _apiService.deleteResponse(url, token, body: body);
    print("delete response==>$responseJsonData");
    return responseJsonData;
  }

  Future<ApiResponse> put({required String url, required String body}) async {
    var token = await AppUtils.getToken();
    debug("Token == $token");
    token ??= "";
    printLongString("body = $body");
    Map<String, dynamic> bodyMap = jsonDecode(body);

    String updatedBody = jsonEncode(bodyMap);

    print("updatetdtttetetet body=>$updatedBody");
    final responseJsonData =
        await _apiService.putResponse(url, updatedBody, token);

    return responseJsonData;
  }

  /// Print Long String
  void printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}');
    pattern
        .allMatches(text)
        .forEach((RegExpMatch match) => debug(match.group(0)));
  }
}
