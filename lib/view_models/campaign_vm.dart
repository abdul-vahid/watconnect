//import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:whatsapp/models/campaign_model/campaign_clone_model.dart';
import '../core/models/base_list_view_model.dart';
import '../models/campaign_model/campaign_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/function_lib.dart';

class CampaignViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  CampaignViewModel(this.context);

  get record => null;

  Future<void> fetchCampaign({String? number = ''}) async {
    String url = AppUtils.getUrl("${AppConstants.campaignAPIPath}=$number");
    await get(url: url, baseModel: CampaignModel());
  }

  Future<dynamic> addCampaign(Map addModel) async {
    String url = AppUtils.getUrl(AppConstants.updateCampaignAPIPath);
    var result = await post(url: url, body: jsonEncode(addModel));
    return result;
  }

  Future<dynamic> updateCampaign(String? id, Map campaignModel) async {
    String url = AppUtils.getUrl("${AppConstants.updateCampaignAPIPathid}/$id");
    debug(' check===$url');
    var result = await put(url: url, body: jsonEncode(campaignModel));
    return result;
  }

  Future<void> getcampaignbyid(String id) async {
    print("iddd=>get campaign id${id}");
    String url = AppUtils.getUrl("${AppConstants.getcampaignbyid}$id");
    print("urlll cmapaign model====>${url}");
    // await get(url: url, baseModel: CampaigndetailModel());
  }

  Future<void> deleteById(String campaignidd) async {
    print("agya vm mai");
    String url = AppUtils.getUrl("${AppConstants.campdeleteById}/$campaignidd");
    debug(' check= campaignidd delete==$url');
    return delete(url: url);
  }

  void fetch() {}
}
