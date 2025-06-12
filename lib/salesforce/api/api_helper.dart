import 'dart:convert';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart';

// import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/salesforce/api/network_calls.dart';
import 'package:whatsapp/utils/app_constants.dart';

String token = "";

Future<bool> isInternetAvailable() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

class AppApi {
  final netWorkCalls = NetworkCalls();

  Future<Response?> commonPostMethod(String url, Map params,
      {bool sendToken = true}) async {
    final hasInternet = await isInternetAvailable();
    if (!hasInternet) {
      // Show the dialog

      return null;
    }

    try {
      Map<String, String> header = {};
      if (sendToken) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        token = await prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
        header.putIfAbsent("Authorization", () => "Bearer $token");
      }
      // header.putIfAbsent("content-type", () => "application/json");

      printRequest(url: url, header: header, body: params);

      var response = await NetworkCalls.post(
        url,
        jsonEncode(params),
        header,
      ).timeout(const Duration(minutes: 2));
      print("repose::: ${response}  ${response.statusCode} ${response.body}");
      if (response.body.isNotEmpty) {
        printResponse(url: url, header: header, response: response.body);
      }

      return (response);
    } catch (e, stackTrace) {
      print("Error calling $url: $e\nStackTrace: $stackTrace");
      throw Exception("Failed to perform POST request: $e");
    }
  }

  Future<dynamic> commonGetMethod(String url, {bool sendToken = true}) async {
    final hasInternet = await isInternetAvailable();

    if (!hasInternet) {
      return null;
    }

    try {
      Map<String, String> header = {};

      if (sendToken) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        token = await prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
        header.putIfAbsent("Authorization", () => token);
      }

      // header.putIfAbsent("content-type", () => "application/json");

      printRequest(url: url, header: header);

      var response = await NetworkCalls.get(url, header)
          .timeout(const Duration(seconds: 20));
      print("get reposne before log::: ${response}");
      printResponse(url: url, header: header, response: response);

      return jsonDecode(response);
    } catch (e, stackTrace) {
      print("Error calling $url: $e\nStackTrace: $stackTrace");
      throw Exception("Failed to perform GET request: $e");
    }
  }

  Future commonPutMethod(String url, Map params,
      {bool sendToken = true}) async {
    Map<String, String> header = {};
    if (sendToken) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = await prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      header.putIfAbsent("Authorization", () => token);
    }
    header.putIfAbsent("content-type", () => "application/json");

    printRequest(url: url, header: header);
    var response = await NetworkCalls.put(url, jsonEncode(params), header)
        .timeout(const Duration(minutes: 1));
    printResponse(url: url, header: header, response: response);
    return jsonDecode(response);
  }

  Future commonPostMethodDummy(String url, Map params,
      {bool sendToken = true,
      required Map<String, dynamic> responseBody}) async {
    Map<String, String> header = {};
    if (sendToken) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String token = "";
      token = await prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

      header.putIfAbsent("Authorization", () => token);
    }
    header.putIfAbsent("content-type", () => "application/json");

    var response = await Future.delayed(const Duration(seconds: 2), () {
      return jsonEncode(responseBody);
    });

    return jsonDecode(response);
  }
}

printRequest(
    {required String url,
    required Map<String, String>? header,
    Map<dynamic, dynamic>? body}) {
  dev.log("call api url    >>> $url ");
  dev.log("call api header   >>> ${jsonEncode(header)}");
  dev.log("call api body >>>  ${jsonEncode(body)} \n  $url");
  dev.log('\n');
}

printResponse(
    {required String url,
    required Map<String, String>? header,
    String? response}) {
  // dev.log("response api url    >>> $url ");
  // dev.log("response response    >>> $response       $url");
  // dev.log("response response    >>> ${response} ");
  dev.log("response api header   >>> ${jsonEncode(header)}");

  dev.log('\n');
  var data = jsonDecode(response ?? "");
  // dev.log("response body >>>>>>>> ${data}   ");
}
