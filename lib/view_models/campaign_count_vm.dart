//import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:whatsapp/models/campaign_count_model/campaign_count_model.dart';
import '../core/models/base_list_view_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class CampaignCountViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  CampaignCountViewModel(this.context);

  Future<void> fetchCampaignCount({String? number = ''}) async {
    String url =
        AppUtils.getUrl("${AppConstants.campaignCountAPIPath}/$number");
    await get(url: url, baseModel: CampaignCountModel());
    // notifyListeners();
  }
}
