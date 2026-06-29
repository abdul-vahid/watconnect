import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:whatsapp/network/api_call.dart';
import 'package:whatsapp/react_side/template/model/template_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

class WhatsappTemplateController extends ChangeNotifier {
  List<TemplateData> allTemplates = [];

  List<TemplateData> filteredTemplates = [];

  List<String> selectedStatus = [];

  bool isLoading = false;

  Future<void> getAllTemplates() async {
    try {
      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      String? number = prefs.getString('phoneNumber');

      String url = AppUtils.getUrl(
        "${AppConstants.templeteAPIPath}=$number",
      );

      final response = await ApiHelper.get(
        url: url,
      );

      TemplateModel data = TemplateModel.fromJson(response);

      allTemplates = data.data ?? [];


      filteredTemplates = List.from(allTemplates);
    } catch (e) {
      debugPrint(
        "Template Error : $e",
      );
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }


  void searchTemplate(String value) {
    if (value.trim().isEmpty) {
      applyStatusFilter(selectedStatus);

      return;
    }

    filteredTemplates = allTemplates.where((item) {
      final name = item.name.toString().toLowerCase();

      return name.contains(
        value.toLowerCase(),
      );
    }).toList();

    notifyListeners();
  }


  void applyStatusFilter(List<String> status) {
    selectedStatus = status;

    if (status.isEmpty || status.contains("All")) {
      filteredTemplates = List.from(allTemplates);
    } else {
      filteredTemplates = allTemplates.where((item) {
        return status.contains(
          item.status.toString().toUpperCase(),
        );
      }).toList();
    }

    notifyListeners();
  }

  List<TemplateData> approvedTemplatedList = [];

  Future<void> getApprovedTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? number = prefs.getString('phoneNumber');

      String url = AppUtils.getUrl(
        "${AppConstants.approvedtemplateapi}=$number",
      );

      final response = await ApiHelper.get(
        url: url,
      );

      TemplateModel data = TemplateModel.fromJson(response);

      approvedTemplatedList = data.data ?? [];
    } catch (e) {
      debugPrint(
        "Approved Template Error $e",
      );
    }

    notifyListeners();
  }
}
