import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:whatsapp/models/unread_count_msg/unread_count_msg.dart';
import '../core/models/base_list_view_model.dart';
import '../models/unread_msg_model/unread_msg_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/function_lib.dart';

class UnreadCountVm extends BaseListViewModel {
  @override
  BuildContext context;
  UnreadCountVm(this.context);
  Future<void> fetchunreadcount({
    String? number = '',
  }) async {
    print("numberrr=>${number}");
    String url = AppUtils.getUrl("${AppConstants.unreadcountpath}$number");
    debug("urldata=>$url");
    await get(url: url, baseModel: UnreadMsgModel());
  }

  Future<void> marksreadcountmsg({
    String? leadnumber = '',
    String? number = '',
    Map<String, String>? bodydata,
  }) async {
    print("Marks read request completed for $leadnumber");
    String url = AppUtils.getUrl("${AppConstants.marksreadmsg}$number");

    print("URL for marks read => $url");
    String body = jsonEncode(bodydata);
    print("bodyyy=>$body");
    await post(url: url, body: body);
  }
}
