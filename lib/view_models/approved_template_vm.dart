// //import 'package:http/http.dart' as http;

// import 'package:flutter/material.dart';
// import 'package:http/http.dart';

// import '../core/models/base_list_view_model.dart';
// import '../models/approved_template_model/aprovedtempltemodel/aprovedtempltemodel.dart';
// import '../utils/app_constants.dart';
// import '../utils/app_utils.dart';

// class ApprovedTemplate extends BaseListViewModel {
//   @override
//   BuildContext context;
//   ApprovedTemplate(this.context);
//   // void fetch() async {
//   //   String url = AppUtils.getUrl(AppConstants.leadAPIPath);
//   //   // get(url: url, baseModel: Aprovedtempltemodeldata());
//   //   var response = get(url: url, baseModel: Aprovedtempltemodeldata());
//   // }
//  void fetch() async {
//     String url = AppUtils.getUrl(AppConstants.leadAPIPath);
//     get(url: url, baseModel: Aprovedtempltemodeldata());
//   }

// }

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
