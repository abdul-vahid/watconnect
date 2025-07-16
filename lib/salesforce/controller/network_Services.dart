import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/utils/app_constants.dart';

class NetworkService {
  static Future<http.Response?> makeRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool useAuth = true,
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
          log("api response :: ${method}   \nurl::  $url \nheader::   $headers \nbody::  $body \nstatus code::  ${response.statusCode} \nresponse body  ${response.body}   ");
          log("=====================================================================================================================================================================================================================");
          return response;

        case 400:
          log("=====================================================================================================================================================================================================================");
          log("⚠️ api with status as 400 : ${method}  \nApiurl  ${url}  \nBody  ${body}\nstatus code    ${response.statusCode}\n  body ${response.body}  ");
          log("=====================================================================================================================================================================================================================");
          EasyLoading.showToast("Something went wrong: ${response.body}");
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
          log("=====================================================================================================================================================================================================================");
          log("⚠️ Server error :${method}   ${url}  ${body}    ${response.statusCode}]: ${response.body}  ");
          log("====================================================================================================================================================================================================================="); // EasyLoading.showToast("Something went wrong: ${response.body}");
          break;

        default:
          log("=====================================================================================================================================================================================================================");
          log("Unhandled status [  ${url}  ${body}    ${response.statusCode}]: ${response.body}");
          log("=====================================================================================================================================================================================================================");
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
          "3MVG9HDaKRUgW3VrsUI_RKn2LNBUcxtribjudS7kOePtrSPn9mK.aWox_5gvqxOTD50qyOmRcRWV6jp3jwTOs",
      "client_secret":
          "A34A06D1DD329F2DCEED942971BF62FC3758588B2DF22EB4FF86FA1A0B6A5C87",
      "refresh_token": refreshToken,
      "redirect_uri": "https://test.salesforce.com/services/oauth2/success",
    };
    try {
      final encodedBody = Uri(queryParameters: body).query;

      final response = await http.post(
        Uri.parse(AppConstants.getToken),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: encodedBody,
      );

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
