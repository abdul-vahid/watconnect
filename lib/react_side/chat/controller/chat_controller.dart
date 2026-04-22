import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/network/api_call.dart';
import 'package:whatsapp/react_side/chat/model/chat_history_model.dart';
import 'package:whatsapp/react_side/template/model/template_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
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

 
  Future<void> refetchSamePage() async {
    if (isLoading) return;

    try {
        final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber')??"";
      isLoading = true;
      notifyListeners();

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





  Future<dynamic> sendMessage({
    String? number,
    required Map<String, dynamic> addmsModel,
  }) async {
    try {
    
    String url = AppUtils.getUrl('${AppConstants.Messagesendmeta}=$number');

     var response= await ApiHelper.post(url: url, body: addmsModel);
     return response;
    } catch (e) {
      print("Mark Read Error: $e");
    }
  }



  Future<dynamic> sendmsgmobile({
  
    required Map<String, dynamic> msgmobilbody,
  }) async {
    try {
    
    String url = AppUtils.getUrl(AppConstants.Messagesendmobile);

     var response= await ApiHelper.post(url: url, body: msgmobilbody);
     return response;
    } catch (e) {
      print("Mark Read Error: $e");
    }
  }



  File? fileToSend;

  setFileToSend(File? someFile) {
    fileToSend = someFile;
    print("file to send set>>>>. ${fileToSend}");
    notifyListeners();
  }


    List<CardComponent> carousalList = [];

  setCarousalList(carusals) {
    carousalList = carusals;
    notifyListeners();
  }

  setCarousalListEmpty() {
    carousalList = [];
    carousalList.clear();
    notifyListeners();
  }



  String? selectedLanguage;
  String? selectedTempId;
  String? selectedTempName;

  Component? selectedBody;
  Component? selectedHeader;
  Component? selectedFooter;
  Component? selectedButtons;
  setSelectedTempId(String? tempId) {
    selectedTempId = tempId;
    notifyListeners();
  }

  setSelectedTempName(String? tempName) {
    selectedTempName = tempName;
    notifyListeners();
  }

  setSelectedButton(Component? button) {
    selectedButtons = button;
    notifyListeners();
  }

  setSelectedFooter(Component? footer) {
    selectedFooter = footer;
    notifyListeners();
  }

  setSelectedBody(Component? body) {
    selectedBody = body;
    notifyListeners();
  }

  setSelectedHeader(Component? header) {
    selectedHeader = header;
    notifyListeners();
  }
  Map<String, dynamic> mainBodyParams = {};

  setMainBodyParams(Map<String, dynamic> body) {
    mainBodyParams = body;
    print("mainBodyParams: are now set:::::::   $mainBodyParams ");
    notifyListeners();
  }



  Future<void> sendImageHistory(  Map<String, dynamic> msghistorydata) async {
    try {
    
        String url = AppUtils.getUrl(AppConstants.historycreate);

      await ApiHelper.post(url: url, body: msghistorydata);
    } catch (e) {
      print("Mark Read Error: $e");
    }
  }

  Future<dynamic> uploadFile(File file, String? number) async {
    var token = await AppUtils.getToken();
    if (token == null || token.isEmpty) {
      print("Missing token!");
      return null;
    }
    final url = Uri.parse(
      "${AppConstants.baseUrl}/api/webhook_template/documentId?whatsapp_setting_number=$number",
    );
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final fileStream = http.ByteStream(file.openRead());
    final length = await file.length();
    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: file.path.split('/').last,
      contentType: http.MediaType.parse(mimeType),
    );
    final request = http.MultipartRequest("POST", url)
      ..files.add(multipartFile)
      ..headers.addAll({
        "Authorization": token,
        // No need to add Content-Type for multipart
      });

    log("Uploading file to $url");

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print("File uploaded successfully: $responseBody");
      return responseBody;
    } else {
      print(
          "File upload failed: ${response.statusCode} - ${response.reasonPhrase}");
      return null;
    }
  }

  Future<void> uploadimagewithdoucmentid(  Map<String, dynamic> msghistorydata,  String? number) async {
    try {
    
    String url = AppUtils.getUrl('${AppConstants.Messagesendmeta}=$number');

      await ApiHelper.post(url: url, body: msghistorydata);
    } catch (e) {
      print("Mark Read Error: $e");
    }
  }


  Future<dynamic> uploadFiledb(File file, String? number, String? id) async {
    var token = await AppUtils.getToken();
    if (token == null || token.isEmpty) {
      print("No token found");
      return null;
    }
    var url = Uri.parse("${AppConstants.baseUrl}/api/whatsapp/files/$id");
    print("Request URL: $url");
    var request = http.MultipartRequest("POST", url);

    // Detect MIME type
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final fileStream = http.ByteStream(file.openRead());
    final length = await file.length();

    // Attach file
    var multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: file.path.split('/').last,
      contentType: http.MediaType.parse(mimeType),
    );

    request.files.add(multipartFile);

    // Add headers
    request.headers.addAll({
      "Authorization": token,
      "Content-Type": "multipart/form-data",
    });

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        print("File uploaded successfully");
        print("File uploaded successfully $responseBody");
        return responseBody;
      } else {
        print("Failed to upload file: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Error occurred during file upload: $e");
      return null;
    }
  }


bool isSending = false;

setSending(bool val) {
  isSending = val;
  notifyListeners();
}

clearFile() {
  fileToSend = null;
  notifyListeners();
}

Future<void> refreshChat() async {
  offset = 0;
  hasMore = true;
  await fetchInitialChat();
}



deleteChat() async {

try{
   final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber')??"";
   var url = AppUtils.getUrl(AppConstants.deletchathistory
        .replaceAll('{leadnumber}', selectedLeadNumber)
        .replaceAll('{whatsapp_setting_number}', phoneNumber));

      await ApiHelper.delete(url: url, body: {});

}catch(e){

}


 
}


}