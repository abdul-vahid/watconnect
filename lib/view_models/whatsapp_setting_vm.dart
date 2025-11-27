//import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:whatsapp/utils/function_lib.dart';
import '../core/models/base_list_view_model.dart';
import '../models/whatsapp_setting_model/whatsapp_setting_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class WhatsappSettingViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  WhatsappSettingViewModel(this.context);
  Future<void> fetch() async {
    String url = AppUtils.getUrl(AppConstants.whatsAppSettingAPIPath);
    debug("urlll=>$url");
    await get(url: url, baseModel: WhatsappSettingModel());
  }

  List<String> allBusinessNums = [];
  addNumToList(String num) async {
    allBusinessNums.add(num);
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  clearAllNumbers() async {
    allBusinessNums.clear();
    await Future.delayed(Duration.zero);
    notifyListeners();
  }
}
