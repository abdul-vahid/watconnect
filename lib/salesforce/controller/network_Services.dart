// ignore_for_file: avoid_print, file_names

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

class NetworkService {
  static Future<http.Response?> makeRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool useAuth = true,
    bool sendToken = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      Map<String, String> defaultHeaders = {
        'Content-Type': 'application/json',
        if (useAuth) 'Authorization': 'Bearer $token',
      };

      final fullHeaders = {
        ...defaultHeaders,
        if (headers != null) ...headers,
      };

      http.Response response;

      log("api url , body , header :::::  $url   $body  $fullHeaders");

      final uri = Uri.parse(url);
      final encodedBody = body != null ? jsonEncode(body) : null;

      switch (method.toUpperCase()) {
        case 'POST':
          response =
              await http.post(uri, headers: fullHeaders, body: encodedBody);
          break;
        case 'GET':
          response = await http.get(uri, headers: fullHeaders);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: fullHeaders);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Handle responses
      switch (response.statusCode) {
        case 200:
          log("=====================================================================================================================================================================================================================");
          log("api response ::  \nRequest - Method   $method   \nurl::  $url \nheader::   $token \nbody::  $body \nstatus code::  ${response.statusCode} \nResponse Body  ${response.body}   ");
          log("=====================================================================================================================================================================================================================");
          return response;

        case 400:
          log("\x1B[95m  =====================================================================================================================================================================================================================");
          log("\x1B[95m   api with status as 400 : \nRequest - Method  $method  \nApiurl  $url   $token \nBody  $body\nstatus code    ${response.statusCode}\n  body ${response.body}  ");
          log(" \x1B[95m  =====================================================================================================================================================================================================================");
          // EasyLoading.showToast("Something went wrong: ${response.body}");
          break;

        case 401:
          log("🔐 Unauthorized. Attempting token refresh...");
          bool refreshed = await getSfRefreshTokenApiApiCall();
          if (refreshed) {
            return await makeRequest(
              url: url,
              method: method,
              headers: headers,
              body: body,
              useAuth: useAuth,
            );
          } else {
            EasyLoading.showToast("Session expired. Please log in again.");
          }
          break;

        case 500:
          log("\x1B[95m   =====================================================================================================================================================================================================================");
          log("\x1B[95m ⚠️ Server error :$method $token  $url  $body    ${response.statusCode}]: ${response.body}  ");
          log("\x1B[95m  ====================================================================================================================================================================================================================="); // EasyLoading.showToast("Something went wrong: ${response.body}");
          break;

        default:
          log(" \x1B[95m  =====================================================================================================================================================================================================================");
          log(" \x1B[95m  Unhandled status [  $url  $body    ${response.statusCode}]: ${response.body}");
          log(" \x1B[95m  =====================================================================================================================================================================================================================");
          break;
      }
    } catch (e) {
      log("❌ $url  Network error: $e");
    }

    return null;
  }

  static Future<bool> getSfRefreshTokenApiApiCall() async {
    final prefs = await SharedPreferences.getInstance();

    final refreshToken =
        prefs.getString(SharedPrefsConstants.sfRefreshToken) ?? "";

    Map<String, String> body = {
      "grant_type": "refresh_token",
      "client_id":
          "3MVG9dAEux2v1sLvMShd1QqukhBR6uzZfjJuCm2Jind0stiCXF_X4sJrrVuyO9mz6e2efAESPs532ydpDE_nZ",
      "client_secret":
          "195E44ED6BAFD4F6F5CB20343F7FFC169616D9C417B3C51089B00F6487E0F459",
      "refresh_token": refreshToken,
      "redirect_uri": "https://login.salesforce.com/services/oauth2/success",
    };
    try {
      log("refresh token req body:::    $body");
      final encodedBody = Uri(queryParameters: body).query;

      String url = await AppUtils.getSFUrl(AppConstants.getToken);

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: encodedBody,
      );

      log("refresh token response body:::    $response");

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        print("parsedJson:: refresh token:::::   $parsedJson");
        final accessToken = parsedJson["access_token"] ?? "";
        final refreshToken = parsedJson['refresh_token'] ?? "";

        if (accessToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              SharedPrefsConstants.sfAccessToken, accessToken);

          await prefs.setString(
              SharedPrefsConstants.sfRefreshToken, refreshToken);
          log("refresh Access token stored successfully.");
        }
        return true;
      } else {
        log("refresh Token fetch failed [${response.statusCode}]: ${response.body}");
        return false;
      }
    } catch (e) {
      log("Error in refresh getSfAccessTokenApiApiCall: $e");
      return false;
    }
  }
}
