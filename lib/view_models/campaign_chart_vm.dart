//import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:whatsapp/models/campaignchart_model/campaign_chart_vm.dart';
import '../core/models/base_list_view_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class CampaignChartViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  CampaignChartViewModel(this.context);

  Future<void> fetchCampaignChart({String? number = ''}) async {
    String url =
        AppUtils.getUrl("${AppConstants.campaignChartAPIPath}/$number");
    await get(url: url, baseModel: CampaignChartModel());
  }
}
