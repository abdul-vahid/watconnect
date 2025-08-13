// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/models/balance_model.dart';
import 'package:whatsapp/models/template_rates_model.dart'
    show TemplateRateModel;
import 'package:whatsapp/models/transaction_model.dart';
import 'package:whatsapp/utils/app_constants.dart';

class WalletController extends ChangeNotifier {
  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  BalanceModel? balanceData;

  bool getWalletLoader = false;

  setGetWalletLoader(bool val) {
    getWalletLoader = val;
    notify();
  }

  Future<void> getWalletApiCall() async {
    setGetWalletLoader(true);
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString(SharedPrefsConstants.accessTokenKey) ?? "";

      final response = await http.get(
        Uri.parse(AppConstants.getWalletApi),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log("headers::::  ${AppConstants.getWalletApi}");
      print(
          "get wallet response :: ${response.runtimeType}  ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        balanceData = BalanceModel.fromJson(data['data']);

        notify();
        log("Fetched ${balanceData?.tenantCode ?? ""}  get wallet .");
      } else {
        log(" get wallet  API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      print("Error in get wallet api: $e");
    } finally {
      setGetWalletLoader(false);
    }
    notifyListeners();
  }

  List<TransactionModel> transactionList = [];

  bool getTransactionLoader = false;

  setGetTransactionLoader(bool val) {
    getTransactionLoader = val;
    notify();
  }

  Future<void> getTransactionsApiCall() async {
    setGetTransactionLoader(true);
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString(SharedPrefsConstants.accessTokenKey) ?? "";

      final response = await http.get(
        Uri.parse(AppConstants.getTransactionApi),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log("headers:::: ${AppConstants.getWalletApi}");
      print(
          "get Transaction response :: ${response.runtimeType}  ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List temp = data["data"];

        transactionList
          ..clear()
          ..addAll(temp.map((e) => TransactionModel.fromJson(e)));

        notify();
        log("Fetched ${transactionList.length}  get Transaction .");
      } else {
        log(" get Transaction  API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      print("Error in get Transaction api: $e");
    } finally {
      setGetTransactionLoader(false);
    }
    notifyListeners();
  }

  bool getAmountLoader = false;

  setGetAmountLoader(bool val) {
    getAmountLoader = val;
    notify();
  }

  bool getCheckBalLoader = false;

  setGetWalletBalLoader(bool val) {
    getCheckBalLoader = val;
    notify();
  }

  bool hasBalance = false;

  Future<bool> checkWalletBalApiCall() async {
    hasBalance = false;
    setGetWalletBalLoader(true);

    final prefs = await SharedPreferences.getInstance();

    String tenatCode =
        prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";

    Map body = {"amount": finalAmount, "tenantcode": tenatCode};
    bool res = false;
    String msg = "";
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPrefsConstants.accessTokenKey) ?? "";

      final response = await http.post(
        Uri.parse(AppConstants.checkWalletBalance),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      log("headers::::  ${AppConstants.checkWalletBalance}");
      print(
          "check balance response :: ${response.runtimeType}  ${response.statusCode} ${response.body}");
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        hasBalance = data['sufficient'];
        res = data["success"];
        msg = data["message"];
        EasyLoading.showToast(msg);

        print("hasBalance in api calll:::::::::::  $hasBalance");
        notify();
      } else {
        msg = data["message"];
        EasyLoading.showToast(msg);
        log("wallet check balance API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      print("Error in check balance api: $e");
    } finally {
      setGetWalletBalLoader(false);
      notifyListeners();
    }

    return res;
  }

  bool debitBalLoader = false;

  setDebitBalLoader(bool val) {
    debitBalLoader = val;
    notify();
  }

  Future<bool> debitWalletBalApiCall() async {
    setDebitBalLoader(true);

    final prefs = await SharedPreferences.getInstance();

    String tenatCode =
        prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";

    Map body = {
      "amount": finalAmount,
      "reason": "debited for sending WhatsApp campaign ",
      "type": "debit",
      "status": "paid",
      "tenantcode": tenatCode
    };
    bool res = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPrefsConstants.accessTokenKey) ?? "";

      final response = await http.post(
        Uri.parse(AppConstants.debitWalletBalance),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      log("headers::::    ${AppConstants.checkWalletBalance}");
      print(
          "debit wallet balance  response :: ${response.runtimeType}  ${response.statusCode} ${response.body}");
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        res = data["success"];
        if (res == false) {
          EasyLoading.showToast(data['message']);
        }
        // var transactionData = data["transaction"];
      } else {
        log(" debit wallet balance API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      print("Error indebit wallet balance  api: $e");
    } finally {
      setDebitBalLoader(false);
      notifyListeners();
    }

    return res;
  }

  List<TemplateRateModel> templateRatesList = [];

  Future<void> templateRatesApiCall() async {
    try {
      // setGetCampLoader(true);
      final prefs = await SharedPreferences.getInstance();

      String apiUrl = AppConstants.templateRates;
      final token = prefs.getString(SharedPrefsConstants.accessTokenKey) ?? "";
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      log("headers::::  $apiUrl");
      print(
          "Template Rates response :: ${response.runtimeType}  ${response.statusCode} $response");

      if (response.statusCode == 200) {
        // setGetCampLoader(false);
        final data = jsonDecode(response.body);
        List temp = data['records'];

        templateRatesList
          ..clear()
          ..addAll(temp.map((e) => TemplateRateModel.fromJson(e)));

        notify();
        log("Fetched ${templateRatesList.length}  Template Rates .");
      } else {
        // setGetCampLoader(false);
        log("Template Rates API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      // setGetCampLoader(false);
      print("Error in Template Rates api: $e");
    }
    notifyListeners();
  }

  calAmount({Map? csv, Map? body}) {
    log("temp::::: rate:::::: list::::::::::   $templateRatesList");
    print("csv:::::   $csv");
    print("body:::::   $body");

    Map<String, int> codeCount = mergeCountryCodeCounts(
        memberList: body?['lead_ids'],
        originalCounts: csv?['countryCodeCounts']);

    print("codeCount:::::::     $codeCount");
    print("temp cate ::: ${body?['template_id']}");

    var amount = calculateTotalCost(
        category: body?['template_id'],
        codeCounts: codeCount,
        pricingList: templateRatesList);

    print("final amount::::::     $amount");

    finalAmount = amount.toString();
    notify();
  }

  Map<String, int> mergeCountryCodeCounts({
    required Map<String, int> originalCounts,
    required List<Map<String, dynamic>> memberList,
  }) {
    final Map<String, int> mergedCounts = {};

    // Normalize original counts (remove + from keys)
    for (var entry in originalCounts.entries) {
      final key = entry.key.replaceAll('+', '');
      mergedCounts[key] = entry.value;
    }

    // Add counts from memberList
    for (final member in memberList) {
      final rawCode = member['country_code'];
      if (rawCode != null && rawCode is String) {
        final normalizedCode = rawCode.replaceAll('+', '');
        mergedCounts[normalizedCode] = (mergedCounts[normalizedCode] ?? 0) + 1;
      }
    }

    return mergedCounts;
  }

  String finalAmount = "";
  // bool hasBalance = false;

  double calculateTotalCost({
    required Map<String, int> codeCounts,
    required List<TemplateRateModel> pricingList,
    required String category, // "UTILITY" or "MARKETING"
  }) {
    double total = 0.0;

    for (final entry in codeCounts.entries) {
      final countryCode = entry.key;
      final count = entry.value;

      final matchingRate = pricingList.firstWhere(
        (item) => item.countryCode == countryCode,
        orElse: () =>
            TemplateRateModel(countryCode: '', marketing: '0', utility: '0'),
      );

      double price = 0.0;
      if (category.toUpperCase() == 'UTILITY') {
        price = double.tryParse(matchingRate.utility ?? "") ?? 0.0;
      } else if (category.toUpperCase() == 'MARKETING') {
        price = double.tryParse(matchingRate.marketing ?? "") ?? 0.0;
      }

      total += count * price;
    }

    return total;
  }

  calculateAmount(String tempCate, String code) async {
    String cCode = code.replaceAll("+", '');
    print("tempCate:::::::::   $tempCate    $code   $cCode");

    String amt = "";

    final matches =
        templateRatesList.where((rate) => rate.countryCode == cCode).toList();
    if (matches.isNotEmpty) {
      final matchedRate = matches.first;
      amt = tempCate.toUpperCase() == "MARKETING"
          ? (matchedRate.marketing ?? "")
          : (matchedRate.utility ?? "");
    }

    setFinalAmt(amt.toString());
    await checkWalletBalApiCall();
    notify();
  }

  setFinalAmt(String amt) {
    finalAmount = amt;
    notify();
  }
}
