//import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:whatsapp/models/template_model/template_model.dart';
import '../core/models/base_list_view_model.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/function_lib.dart';

class TempleteListViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  TempleteListViewModel(this.context);

  Future<dynamic> templetefetch({required String? number}) async {
    String url = AppUtils.getUrl("${AppConstants.templeteAPIPath}=$number");
    print("uddlld=>TEE$url");
    await get(url: url, baseModel: TemplateModel());
  }

  Future<dynamic> templeteCountfetch({String? number = ''}) async {
    String url = AppUtils.getUrl("${AppConstants.approvedtemplateapi}=$number");
    print("tetettetetetettetetee=>$url");
    await get(url: url, baseModel: TemplateModel());
  }

  Future<dynamic> deleteLeads({String? number = '', String? id}) async {
    final APIService apiService = APIService();

    try {
      var token = await AppUtils.getToken();
      if (token == null) {
        throw Exception("Token is null");
      }

      String url =
          AppUtils.getUrl("${AppConstants.templeteAPIPath}=$number/$id");
      debug('Request URL: $url');

      var result = await apiService.deleteResponse(url, token);
      return result;
    } catch (e) {
      print("Error in deleteLeads: $e");
      throw Exception("Failed to delete template: $e");
    }
  }
}
