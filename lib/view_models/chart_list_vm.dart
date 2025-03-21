//import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../core/models/base_list_view_model.dart';
import '../models/leadsmonthmodel.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/function_lib.dart';

class ChartListViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  ChartListViewModel(this.context);

  void fetchLeadsMonth() async {
    String url = AppUtils.getUrl(AppConstants.leadsmonthAPIPath);
    debug("url1 = > $url");
    get(url: url, baseModel: Leadsmonthmodel());
  }
}
