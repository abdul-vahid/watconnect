//import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import '../core/models/base_list_view_model.dart';
import '../models/lead_count_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class LeadCountViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  LeadCountViewModel(this.context);

  void countNewLead() async {
    String url = AppUtils.getUrl(AppConstants.leadCountAPIPath);
    await get(url: url, baseModel: NewLeadCountModel());
  }
}
