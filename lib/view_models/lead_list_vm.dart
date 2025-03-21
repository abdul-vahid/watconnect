//import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import '../core/models/base_list_view_model.dart';
import '../models/lead_model.dart';
// import '../models/task_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/function_lib.dart';

class LeadListViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  LeadListViewModel(this.context);
  void fetch() async {
    String url = AppUtils.getUrl(AppConstants.leadAPIPath);
    get(url: url, baseModel: LeadModel());
  }

  Future<dynamic> addlead(LeadModel addleadModel) async {
    print("working.....");
    String url = AppUtils.getUrl(AppConstants.leadAPIPath);
    print("urll=>$url");
    debug("===========>${addleadModel.toJson()}");
    var result = await post(url: url, body: addleadModel.toJson());
    print("result=>$result");
    return result;
  }

  Future<void> deleteById(String leadidd) async {
    print("agya vm mai");
    String url = AppUtils.getUrl("${AppConstants.leadAPIPath}/$leadidd");
    debug(' check= lead delete==$url');
    return delete(url: url);
  }

  // Future<dynamic> msghistorydelete(
  //     {required leadnumber, required number}) async {
  //   print("agya vm masdhsajdjs jdhfcjahsai");
  //   var url = AppUtils.getUrl(AppConstants.deletchathistory
  //       .replaceAll('{leadnumber}', leadnumber)
  //       .replaceAll('{whatsapp_setting_number}', number));
  //   debug('chat history delete  check===$url');
  //   return delete(url: url, body: MsModel());
  // }

  Future<void> update(String? id, LeadModel leadModel) async {
    String url = AppUtils.getUrl("${AppConstants.leadAPIPath}/$id");
    debug(' check===$url');
    var result = await put(url: url, body: leadModel.toJson());

    print("rssssssssssssss=>$result");
    return result;
  }

  // void taskfetch() async {
  //   String url = AppUtils.getUrl(AppConstants.taskAPIPath);
  //   get(url: url, baseModel: TaskModel());
  // }

  // Future<dynamic> addTask(TaskModel addtaskModel) async {
  //   String url = AppUtils.getUrl(AppConstants.taskAPIPath);
  //   debug(addtaskModel.toJson());
  //   var result = await post(url: url, body: addtaskModel.toJson());

  //   return result;
  // }

  // void fetchbusiness() async {
  //   String url = AppUtils.getUrl(AppConstants.businessAPIPath);
  //   get(url: url, baseModel: BusinessModel());
  // }

  // Future<void> updatebusiness(String? id, BusinessModel businessModel) async {
  //   String url = AppUtils.getUrl("${AppConstants.businessAPIPath}/$id");
  //   debug(' check===$url');
  //   final result = await put(url: url, body: businessModel.toJson());
  //   return result;
  // }
}
