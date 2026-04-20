import 'package:flutter/material.dart';
import 'package:whatsapp/network/api_call.dart';
import 'package:whatsapp/react_side/home/model/home_summary_model.dart';

class HomeSummaryController extends ChangeNotifier {
  HomeSummaryModel? homeSummary;

  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> fetchHomeSummary() async {
    try {
      final response = await ApiHelper.get(url: "");

      homeSummary = HomeSummaryModel.fromJson(response);

      print(response);
    } catch (e) {
      print("Error: $e");
    } finally {
      notify();
    }
  }
}
