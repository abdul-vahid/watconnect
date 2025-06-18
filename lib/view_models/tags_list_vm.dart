import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:whatsapp/core/models/base_list_view_model.dart';
import 'package:whatsapp/models/tags_list_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

class TagsListViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  TagsListViewModel(this.context);

  get record => null;

  Future<void> fetchAllTags() async {
    String url = AppUtils.getUrl(AppConstants.getAllTagsApi);
    String apiUrl = "${url}";
    await get(url: apiUrl, baseModel: TagsModel());
  }

  Future<dynamic> addTag(Map addTagBody) async {
    print("working.....");
    String url = AppUtils.getUrl(AppConstants.getAllTagsApi);
    print("urll=>$url");
    String jsonString = jsonEncode(addTagBody);
    var result = await post(url: url, body: jsonString);

    print("   ${result['success']}   result=>$result");
    return result;
  }

  Future<dynamic> updateTag(Map addTagBody, String tagId) async {
    print("working.....");
    String url = AppUtils.getUrl(AppConstants.getAllTagsApi);
    print("urll=>$url");
    String apiurl = "${url}/${tagId}";
    String jsonString = jsonEncode(addTagBody);
    var result = await put(url: apiurl, body: jsonString);

    print("   ${result['success']}   result=>$result");
    return result;
  }
}
