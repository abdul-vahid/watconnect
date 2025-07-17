import 'dart:convert';

import 'package:flutter/material.dart';
import '../core/models/base_list_view_model.dart';
import '../models/user_data_model/user_data_model.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/function_lib.dart';

class UserDataListViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  UserDataListViewModel(this.context);

  fetchUser() async {
    String url = AppUtils.getUrl(AppConstants.userDataAPIPath);
    debug(' check===$url');
    get(url: url, baseModel: UserDataModel());
  }

  Future<dynamic> addUser(UserDataModel addUserModel) async {
    String url = AppUtils.getUrl(AppConstants.addUserAPIPath);
    debug(addUserModel.toJson());
    var result = post(url: url, body: addUserModel.toJson());
    return result;
  }

  Future<dynamic> updateUser(String? id, UserDataModel productModel) async {
    String url = AppUtils.getUrl("${AppConstants.updateUserAPIPath}/$id");
    debug(' check===$url');
    print("bodyyyyyyyyyyyyyyyyyyyyy=>${productModel.toJson()}");
    final result = await put(url: url, body: productModel.toJson());
    print("result-=>$result");
    return result;
  }

  Future<void> updatePassword(String? id, Map userModel) async {
    String url = AppUtils.getUrl("${AppConstants.userPasswordAPIPath}/$id");
    debug(' check===$url');
    final result = await put(url: url, body: jsonEncode(userModel));
    return result;
  }

  Future<void> deleteUser(String? id) async {
    if (id == null) {
      print('ID is null, cannot delete.');
      return;
    }

    final APIService apiService = APIService();
    var token = await AppUtils.getToken();

    if (token == null) {
      print('Token is null, cannot delete.');
      return;
    }

    String url = AppUtils.getUrl("${AppConstants.userDataAPIPath}/$id");

    try {
      var result = await apiService.deleteResponse(url, token);

      if (result != null && result is Map) {
        print('User successfully deleted');
      } else {
        print('Failed to delete user');
      }
    } catch (e) {
      print('Error while deleting user: $e');
    }
  }

  void fetch() {}
}
