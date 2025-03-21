//import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../core/models/base_list_view_model.dart';
import '../models/lead_count_agent_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/function_lib.dart';

class AgentListViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  AgentListViewModel(this.context);

  void fetchCountAgent() async {
    String url = AppUtils.getUrl(AppConstants.leadcountagentAPIPath);
    debug("url2 = > $url");
    await get(url: url, baseModel: LeadCountAgentModel());
  }
}
