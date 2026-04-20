import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/network/api_call.dart';
import 'package:whatsapp/react_side/chat/model/chat_history_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

class ChatController extends ChangeNotifier {
  List<ChatRecord> chatHistoryList = [];

  int limit = 50;
  int offset = 0;

  bool isLoading = false;
  bool hasMore = true;

  
  Future<void> fetchInitialChat() async {
    offset = 0;
    hasMore = true;
    chatHistoryList.clear();

    await fetchChatHistory(
  
    );
  }


  String selectedLeadNumber="";

setSelectedLeadNumber(String num){
selectedLeadNumber=num;
notifyListeners();
}
  Future<void> fetchChatHistory() async {
    if (isLoading || !hasMore) return;

    try {
      isLoading = true;
      notifyListeners();
   final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber')??"";
      var baseUrl = AppUtils.getUrl(
        AppConstants.Messagehistory
            .replaceAll('{leadnumber}', selectedLeadNumber)
            .replaceAll('{whatsapp_setting_number}', phoneNumber),
      );

      var apiUrl = '$baseUrl&limit=$limit&offset=$offset';

      final response = await ApiHelper.get(url: apiUrl);

      var chatHistory = ChatHistoryModel.fromJson(response);
      final newData = chatHistory.records ?? [];

      if (offset == 0) {
        chatHistoryList = newData;
      } else {
  
        final filteredData = newData.where((newItem) =>
            !chatHistoryList.any((old) => old.id == newItem.id));

        chatHistoryList.addAll(filteredData);
      }


      if (newData.length < limit) {
        hasMore = false;
      } else {
        offset += limit;
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

 
  Future<void> refetchSamePage({
    required String leadnumber,
    required String settingNum,
  }) async {
    if (isLoading) return;

    try {
      isLoading = true;
      notifyListeners();

      var baseUrl = AppUtils.getUrl(
        AppConstants.Messagehistory
            .replaceAll('{leadnumber}', leadnumber)
            .replaceAll('{whatsapp_setting_number}', settingNum),
      );

     
      var apiUrl = '$baseUrl&limit=$limit&offset=$offset';

      final response = await ApiHelper.get(url: apiUrl);

      var chatHistory = ChatHistoryModel.fromJson(response);
      final newData = chatHistory.records ?? [];

      if (offset == 0) {
        chatHistoryList = newData;
      } else {
       
        chatHistoryList = [
          ...chatHistoryList.take(offset),
          ...newData,
        ];
      }

      hasMore = newData.length == limit;
    } catch (e) {
      print("Refetch Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> markChatAsRead(String number) async {
    try {
      final body = {
        "whatsapp_number": number,
      };

      String url =
          AppUtils.getUrl("${AppConstants.marksreadmsg}$number");

      await ApiHelper.post(url: url, body: body);
    } catch (e) {
      print("Mark Read Error: $e");
    }
  }
}