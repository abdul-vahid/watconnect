// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

import '../core/apis/app_exception.dart';
import '../utils/function_lib.dart';
// import 'api_response.dart'; // Import the ApiResponse model

class APIService {
  Future<ApiResponse> getResponse(String url, String token) async {
    debug("GET URL ---> $url");
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': token,
      });

      final data = returnResponse(response);
      return ApiResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }

  Future<ApiResponse> postResponse(String url, var body, String token) async {
    log("POST URL ---> $url\nBODY ---> $body");
    try {
      final response = await http.post(Uri.parse(url), body: body, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': token,
      });

      log("POST URL ---> toke:  $token   $url \nSTATUSCODE ${response.statusCode}---> \nRESPONSE ---> ${response.body}  ");
      if (url.contains(AppConstants.refreshTokenAPIPath)) {
        var body = jsonDecode(response.body);
        String accessToken = body['authToken'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(SharedPrefsConstants.accessTokenKey, accessToken);
      }
      final data = returnResponse(response);
      return ApiResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }

  Future<ApiResponse> putResponse(String url, var body, String token) async {
    try {
      final response = await http.put(Uri.parse(url), body: body, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': token,
      });

      final data = returnResponse(response);
      return ApiResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }

  Future<ApiResponse> deleteResponse(String url, String token,
      {String? body}) async {
    print("DELETE URL ---> $url\nBODY ---> $body");
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
        body: body,
      );

      final data = returnResponse(response);
      return ApiResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }

  Future<ApiResponse> getMultipartResponse(
      String url, Map<String, String> data) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll(data);
      http.StreamedResponse response = await request.send();

      var jsonResponse = await response.stream.bytesToString();
      final dataResponse = returnMultipartResponse(response, jsonResponse);
      return ApiResponse(data: dataResponse, statusCode: response.statusCode);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }

  @visibleForTesting
  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 402: // 402 has a valid body and may show toast
        return jsonDecode(response.body);
      case 204:
        return {}; // No content
      case 400:
        // throw BadRequestException(response.body.toString());
        return jsonDecode(response.body);
      case 401:
      case 403:
        debug("Unauthorized");
        EasyLoading.showToast("Session Expired!\n Login Again");
        AppUtils.logout(AppUtils.currentContext);
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while communicating with server. Status code: ${response.statusCode}');
    }
  }

  @visibleForTesting
  dynamic returnMultipartResponse(
      http.StreamedResponse response, String jsonResponse) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(jsonResponse);
      case 400:
        throw BadRequestException(jsonResponse);
      case 401:
      case 403:
        throw UnauthorisedException(jsonResponse);
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while communicating with server. Status code: ${response.statusCode}');
    }
  }
}

class ApiResponse {
  final dynamic data;
  final int statusCode;

  ApiResponse({required this.data, required this.statusCode});
}
