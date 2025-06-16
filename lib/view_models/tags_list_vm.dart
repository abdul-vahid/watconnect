import 'package:flutter/material.dart';
import 'package:whatsapp/core/models/base_list_view_model.dart';
import 'package:whatsapp/models/tags_lsit_model.dart';
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
}
