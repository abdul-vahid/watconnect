import 'package:flutter/material.dart';

import '../core/models/base_list_view_model.dart';
import '../models/get_user.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/function_lib.dart';

class GetUserViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  GetUserViewModel(this.context);

  fetchUser() async {
    String url = AppUtils.getUrl(AppConstants.getUserAPIPath);
    debug(' check===$url');
    get(
      url: url,
      baseModel: GetUser(),
    );
  }

  Future<dynamic> updateProfile(String? id, GetUser updateUser) async {
    String url =
        AppUtils.getUrl("${AppConstants.updateUserAPIPath}/${updateUser.id}");
    debug(updateUser.toJson());
    var result = put(url: url, body: updateUser.toJson());
    debug('updateProfile==$url');
    debug('result===$result');
    return result;
  }
}
