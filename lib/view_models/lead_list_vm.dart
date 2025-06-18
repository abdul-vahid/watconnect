import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:whatsapp/models/recent_chat_model.dart';
import 'package:whatsapp/models/tags_list_model.dart';
import '../core/models/base_list_view_model.dart';
import '../models/lead_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/function_lib.dart';

class LeadListViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  LeadListViewModel(this.context);

  get record => null;

  Future<void> fetch() async {
    String url = AppUtils.getUrl(AppConstants.leadAPIPath);
    await get(url: url, baseModel: LeadResponseModel());
    // .then((onValue) {
    //   print("viewModels::: ${viewModels}");
    //   print("fetch val::: ${onValue}");
    // });
  }

  Future<void> fetchRecentChat() async {
    String url = AppUtils.getUrl(AppConstants.recentChat);
    await get(url: url, baseModel: RecentChatModel());
  }

  Future<void> fetchLeadTags() async {
    String url = AppUtils.getUrl(AppConstants.getAllTagsApi);
    String apiUrl = "${url}?status=true";
    await get(url: apiUrl, baseModel: TagsModel());
  }

  Future<void> fetchCampLeads() async {
    String url = AppUtils.getUrl(AppConstants.allCampLeads);
    await get(url: url, baseModel: RecentChatModel());
  }

  Future<dynamic> addlead(Map addLeadBody) async {
    print("working.....");
    String url = AppUtils.getUrl(AppConstants.leadAPIPath);
    print("urll=>$url");
    String jsonString = jsonEncode(addLeadBody);
    var result = await post(url: url, body: jsonString);
    print("result=>$result");
    return result;
  }

  Future<dynamic> updatelead(Map addLeadBody, String leadId) async {
    print("working.....");
    String url = AppUtils.getUrl(AppConstants.leadAPIPath);
    String apiUrl = "${url}/${leadId}";
    print("urll=>$url");
    String jsonString = jsonEncode(addLeadBody);
    var result = await put(url: apiUrl, body: jsonString);
    print("result=>$result");
    return result;
  }

  Future<void> deleteById(String leadidd) async {
    print("agya vm mai");
    String url = AppUtils.getUrl("${AppConstants.leadAPIPath}/$leadidd");
    debug(' check= lead delete==$url');
    return delete(url: url);
  }

  Future<void> update(String? id, LeadModel leadModel) async {
    String url = AppUtils.getUrl("${AppConstants.leadAPIPath}/$id");
    debug(' check===$url');
    var result = await put(url: url, body: leadModel.toJson().toString());
    print("rssssssssssssss=>$result");
    return result;
  }
}
