import 'package:flutter/material.dart';
import '../core/models/base_list_view_model.dart';
import '../models/approved_template_model/aprovedtempltemodel/aprovedtempltemodel.dart';

import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class ApprovedTemplateViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  ApprovedTemplateViewModel(this.context);
  Future<void> fetchTemplatechart({String? number = ''}) async {
    String url = AppUtils.getUrl('${AppConstants.templatehomepage}=$number');
    print("urlTemplate======>$url");
    get(url: url, baseModel: Aprovedtempltemodeldata());
  }
}
