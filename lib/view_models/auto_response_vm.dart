//import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:whatsapp/models/auto_response_model.dart';
import '../core/models/base_list_view_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class AutoResponseViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  AutoResponseViewModel(this.context);

  void autoResponseFetch() async {
    String url = AppUtils.getUrl(AppConstants.autoResponseAPIPath);
    get(url: url, baseModel: AutoResponseModel());
  }
}
