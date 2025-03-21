//import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../core/models/base_list_view_model.dart';
import '../models/message_history_model/message_history_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/function_lib.dart';

class MeesageHistoryViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  MeesageHistoryViewModel(this.context);

  fetchMessageHistory(String? campaignId) async {
    String url =
        AppUtils.getUrl('${AppConstants.messageHistoryAPIPath}/$campaignId');
    debug("url2 = > $url");
    await get(url: url, baseModel: MessageHistoryModel());
  }
}
