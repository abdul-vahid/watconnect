// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/network_Services.dart';
import 'package:whatsapp/salesforce/model/template_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:whatsapp/utils/function_lib.dart';

class TemplateController extends ChangeNotifier {
  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  List<TemplateModel> templateList = [];
  List<String> templateNames = [];

  String selectedTempName = "Select";

  String selectedTempCategory = "ALL";
  setSeletcedTempCate(String tempCate) {
    selectedTempCategory = tempCate;
    notify();
  }

  setSelectedTempName(String name) {
    selectedTempName = name;
    print("seleting temp and temp name:::: ${selectedTempName}");
    if (selectedTempName != "Select") {
      if (selectedTempName != "Select") {
        for (int i = 0; i < templateList.length; i++) {
          print("templateList[i].name    ${templateList[i].name}");
          if (templateList[i].name == selectedTempName) {
            setSelectedTemp(templateList[i]);
            return;
          }
        }
      }
    }
    notify();
  }

  TemplateModel? selectedTemplate;
  setSelectedTemp(TemplateModel? selTemp) {
    debug("selTempselTempselTempselTemp${selTemp}");
    selectedTemplate = selTemp;
    notify();
  }

  bool getTempLoader = false;

  TextEditingController campTempController = TextEditingController();

  resetController() {
    campTempController.clear();
    notify();
  }

  List<String> tempParamsList = [];
  setTempParams(List<String> paramList) {
    tempParamsList = paramList;
    notify();
  }

  resetTempParamList() {
    tempParamsList.clear();
    notify();
  }

  setCampTempController(String val) {
    campTempController.text = val;
    notify();
  }

  setGetTempLoader(bool val) {
    getTempLoader = val;
    notify();
  }

  Future<void> getTemplateApiCall(
      {String category = "ALL", bool showLoader = true}) async {
    if (showLoader) {
      setGetTempLoader(true);
    }
    final prefs = await SharedPreferences.getInstance();
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    // String apiUrl =
    //     "${AppConstants.sfGetTemplates}businessnumber=${busNum}&category=$category";

    String url = await AppUtils.getSFUrl(
        "${AppConstants.sfGetTemplates}businessnumber=${busNum}&category=$category");

    final response = await NetworkService.makeRequest(
      url: url,
      method: 'GET',
    );
    if (response != null && response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      templateList
        ..clear()
        ..addAll(data.map((e) => TemplateModel.fromJson(e)));

      templateNames
        ..clear()
        ..addAll(templateList
            .map((e) => e.name ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList());
      templateNames.insert(0, "Select");
    }
    setGetTempLoader(false);
    notify();
  }

  bool sendTempLoader = false;

  setSentTempLoader(bool val) {
    sendTempLoader = val;
    notify();
  }

  Future<void> sendTemplateApiCall(
      {required String tempId,
      required String usrNumber,
      required List<String> params,
      String? docId,
      String? url,
      String? mimetyp,
      String? category}) async {
    debug("categorycategorycategorycategory${category}");
    setSentTempLoader(true);
    // String apiUrl = AppConstants.sfSendTemplate;

    String apiUrl = await AppUtils.getSFUrl(AppConstants.sfSendTemplate);
    debug("sfSendTemplatesfSendTemplatesfSendTemplate$apiUrl");
    final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
    Map<String, dynamic> body = {};
    var paramToSend = buildParamsJson(params);
    debug("paramToSendparamToSendparamToSendparamToSend$paramToSend");
    if (params.isEmpty) {
      body = {
        "businessnumber": busNum,
        "userWhatsAppNumber": usrNumber,
        "metaTemplateId": tempId
      };
      debug("boddddddddddddy$body");
    } else {
      body = {
        "businessnumber": busNum,
        "userWhatsAppNumber": usrNumber,
        "metaTemplateId": tempId,
        "params": paramToSend,
        "document_id": docId,
        "category": category
      };
      debug("basdodybodybody$body");
    }

    print("docId::: ${docId}  url::: ${url}  mimetyp::: ${mimetyp}");

    if (docId != null) {
      debug("docIddocId$docId");
      body["document_id"] = docId;
      body["url"] = url;
      body["content_type"] = mimetyp;
    }

    final response = await NetworkService.makeRequest(
        url: apiUrl, method: 'POST', body: body);
    print("response response ${response!.statusCode}");

    if (response != null && response.statusCode == 200) {
      debug("Template sent successfully");
      EasyLoading.showToast("Template Send Successfully");
      ChatMessageController msgCtrl =
          Provider.of(navigatorKey.currentContext!, listen: false);
      await msgCtrl.messageHistoryApiCall(
          userNumber: usrNumber, isFirstTime: false);
    }
    setSentTempLoader(false);
    notify();
  }

  // String buildParamsJson(List<String> values) {
  //   debug("valuesvaluesvaluesvaluesvalues${values}");
  //   final List<Map<String, String>> paramList = [];

  //   for (int i = 0; i < values.length; i++) {
  //     paramList.add({
  //       "name": "{{${i + 1}}}",
  //       "value": values[i],
  //     });
  //   }

  //   String jsonString = jsonEncode(paramList);
  //   print("temp param as encoded strigify format::::::::::::   ${jsonString}");
  //   return jsonString;
  // }
  List<Map<String, String>> buildParamsJson(List<String> values) {
    final List<Map<String, String>> paramList = [];

    for (int i = 0; i < values.length; i++) {
      paramList.add({
        "name": "{{${i + 1}}}",
        "value": values[i],
      });
    }

    debugPrint("PARAM LIST::: $paramList");

    return paramList;
  }

  List<TextEditingController> textControllers = [];

  void setupControllers(int count) {
    textControllers = List.generate(count, (_) => TextEditingController());
  }

  void disposeControllers() {
    for (var controller in textControllers) {
      controller.dispose();
    }
    textControllers.clear();
  }
}
