//import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import '../core/models/base_list_view_model.dart';
import '../models/groups_model/groups_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class GroupsViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  GroupsViewModel(this.context);

  void fetchGroups() async {
    String url = AppUtils.getUrl(AppConstants.groupAPIPath);
    get(url: url, baseModel: GroupsModel());
  }
}
