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

      log("headers:::: ${"Bearer $token"}    ${AppConstants.getWalletApi}");
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

      log("headers:::: ${"Bearer $token"}    ${AppConstants.getWalletApi}");
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

  Future<bool> getAmountApiCall() async {
    setGetAmountLoader(true);

    Map body = {};
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

      log("headers:::: ${"Bearer $token"}    ${AppConstants.checkWalletBalance}");
      print(
          "check balance response :: ${response.runtimeType}  ${response.statusCode} ${response.body}");
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        res = data["success"];
        msg = data["message"];
        String amt = "";

        checkWalletBalApiCall(amt);
      } else {
        msg = data["message"];
        EasyLoading.showToast(msg);
        log("wallet check balance API failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      print("Error in check balance api: $e");
    } finally {
      setGetAmountLoader(false);
      notifyListeners();
    }

    return res;
  }

  bool getCheckBalLoader = false;

  setGetWalletBalLoader(bool val) {
    getCheckBalLoader = val;
    notify();
  }

  Future<bool> checkWalletBalApiCall(String amt) async {
    setGetWalletBalLoader(true);

    final prefs = await SharedPreferences.getInstance();

    String tenatCode =
        prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";

    Map body = {"amount": amt, "tenantcode": tenatCode};
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

      log("headers:::: ${"Bearer $token"}    ${AppConstants.checkWalletBalance}");
      print(
          "check balance response :: ${response.runtimeType}  ${response.statusCode} ${response.body}");
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        res = data["success"];
        msg = data["message"];

        EasyLoading.showToast(msg);

        debitWalletBalApiCall(amount: amt, tennetCode: tenatCode);
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

  Future<bool> debitWalletBalApiCall(
      {String? tennetCode, String? amount}) async {
    setDebitBalLoader(true);

    Map body = {
      "amount": amount,
      "reason": "debited for sending WhatsApp campaign ",
      "type": "debit",
      "status": "paid",
      "tenantcode": tennetCode
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

      log("headers:::: ${"Bearer $token"}    ${AppConstants.checkWalletBalance}");
      print(
          "debit wallet balance  response :: ${response.runtimeType}  ${response.statusCode} ${response.body}");
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        res = data["success"];
        var transactionData = data["transaction"];
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
}
