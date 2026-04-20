import 'package:flutter/material.dart';
import 'package:whatsapp/network/api_call.dart';
import 'package:whatsapp/react_side/chat/model/chat_history_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

class ChatController extends ChangeNotifier {
  List<ChatRecord> chatHistoryList = [];

  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> fetchChatHistory({
    required String leadnumber,
    required String settingNum,
  }) async {
    try {
      var url = AppUtils.getUrl(
          AppConstants.Messagehistory.replaceAll('{leadnumber}', leadnumber)
              .replaceAll('{whatsapp_setting_number}', settingNum));
      final response = await ApiHelper.get(url: url);

      var chatHistory = ChatHistoryModel.fromJson(response);

      chatHistoryList = chatHistory.records ?? [];
      print(response);
    } catch (e) {
      print("Error: $e");
    } finally {
      notify();
    }
  }
}
