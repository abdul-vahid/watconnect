import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/network/api_call.dart';
import 'package:whatsapp/react_side/template/model/template_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

class WhatsappTemplateController  extends ChangeNotifier {

List<TemplateData> approvedTemplatedList=[];

  getApprovedTemplates() async {
    try {
     final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
  String url = AppUtils.getUrl("${AppConstants.approvedtemplateapi}=$number");

      final response = await ApiHelper.get(url: url,);
      TemplateModel data = TemplateModel.fromJson(response);

      approvedTemplatedList=data.data??[];
    
    } catch (e) {
    } finally {
     notifyListeners();
    }
  }



}