import 'dart:convert' show jsonEncode;
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:whatsapp/models/ms_model/message_model.dart';
import '../core/models/base_list_view_model.dart';
import 'package:mime/mime.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/function_lib.dart';
import 'package:http_parser/http_parser.dart';

class MessageViewModel extends BaseListViewModel {
  @override
  BuildContext context;
  MessageViewModel(this.context);
  bool historyExists = false;
  Future Fetchmsghistorydata({required leadnumber, required number}) async {
    try {
      var url = AppUtils.getUrl(
          AppConstants.Messagehistory.replaceAll('{leadnumber}', leadnumber)
              .replaceAll('{whatsapp_setting_number}', number));
      print("urll= get hisory msg>$url");
      print("AAAAAAA");
      var response = get(url: url, baseModel: MsModel());
      print("respone==> $response");
      // print("respone encode==>  ${jsonEncode(response)}");

      return response;
    } catch (e, stackTrace) {
      debug("Error: $e   $stackTrace");
    }
  }

  Future<dynamic> sendMessage({
    String? number,
    required Map<String, dynamic> addmsModel,
  }) async {
    print("sendMessage called");
    String url = AppUtils.getUrl('${AppConstants.Messagesendmeta}=$number');
    print("url==senddd>$url");
    String body = jsonEncode(addmsModel);
    var result = await post(url: url, body: body);
    debug('result0 $result');
    // print("resssssssssssssssssssssssssssss${result.messages}");
    return result;
  }

  Future<dynamic> sendmsgmobile({
    required Map<String, dynamic> msgmobilbody,
  }) async {
    print("senjhhhdmsgmobile jjjjjjjjjcalled");
    String url = AppUtils.getUrl(AppConstants.Messagesendmobile);
    print("url==mobile send >$url");
    String body = jsonEncode(msgmobilbody);
    var result = await post(url: url, body: body);
    debug('result $result');
    return result;
  }

  Future<dynamic> sendCampParam({
    required Map<String, dynamic> campParambody,
  }) async {
    print("senjhhhdmsgmobile jjjjjjjjjcalled");
    String url = AppUtils.getUrl(AppConstants.campaignParam);
    print("url==mobile send >$url");
    String body = jsonEncode(campParambody);
    var result = await post(url: url, body: body);
    debug('result $result');
    return result;
  }

  Future<dynamic> sendtemplete({
    String? number,
    required Map<String, dynamic> msgmobilbody,
  }) async {
    print("c=templeate snd callled");
    String url = AppUtils.getUrl('${AppConstants.templetesend}=$number');
    print("url==mobile templete send >$url");
    String body = jsonEncode(msgmobilbody);
    var result = await post(url: url, body: body);
    // debug('result templete sed $result');
    return result;
  }

  Future<dynamic> sendProxy({
    String? number,
    required Map<String, dynamic> fileProxyBody,
  }) async {
    print("c=templeate snd callled");
    String url = AppUtils.getUrl('${AppConstants.proxy}=$number');
    print("url==mobile templete send >$url");
    String body = jsonEncode(fileProxyBody);
    var result = await post(url: url, body: body);
    // debug('result templete sed $result');
    return result;
  }

  Future<dynamic> createmsgtemplete({
    String? number,
    required Map<String, dynamic> msgmobilbody,
  }) async {
    print("createtempletcreatetemplet");
    String url = AppUtils.getUrl(AppConstants.createtemplet);
    print("createtempletcreatetemplet >$url");
    String body = jsonEncode(msgmobilbody);
    var result = await post(url: url, body: body);
    // debug('createtempletcreatetempletcreatetemplet $result');
    return result;
  }

  Future<dynamic> semdtempmsghistory({
    required Map<String, dynamic> msghistorydata,
  }) async {
    print("templetehistorycreatetempletehistorycreate");
    String url = AppUtils.getUrl(AppConstants.historycreate);
    print("templetehistorycreatetempletehistorycreate>$url");
    String body = jsonEncode(msghistorydata);
    var result = await post(url: url, body: body);
    debug('templetehistorycreatetempletehistorycreate $result');
    return result;
  }

  Future<dynamic> msghistorydelete(
      {required leadnumber, required number}) async {
    print("agya vm masdhsajdjs jdhfcjahsai");
    var url = AppUtils.getUrl(AppConstants.deletchathistory
        .replaceAll('{leadnumber}', leadnumber)
        .replaceAll('{whatsapp_setting_number}', number));
    debug('chat history delete  check===$url');
    return delete(url: url);
  }

  Future<dynamic> uploadFile(File file, String? number) async {
    // final APIService _apiService = APIService();
    var token = await AppUtils.getToken();
    // debug("Token2 == $token");
    token ??= "";
    var url = Uri.parse(
        "${AppConstants.baseUrl}/webhook_template/documentId?whatsapp_setting_number=$number");

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
      contentType: MediaType.parse(mimeType),
    );

    request.files.add(multipartFile);

    // Add headers if required
    request.headers.addAll({
      "Authorization": token,
      "Content-Type": "multipart/form-data",
    });
    log("Request URL: $url");
    // debug("Request Headers: ${request.headers}");
    debug("Request Fields: ${request.fields}");
    debug("Request Files: ${request.files}");
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      print("File uploaded successfully");
      debug("File uploaded successfully$responseBody");
      return responseBody;
    } else {
      print("Failed to upload file: ${response.reasonPhrase}");
      return null;
    }
  }

  Future<dynamic> uploadimagewithdoucmentid(
      {required Map<String, dynamic> bodyy, required String? number}) async {
    print("sendMessage called");
    String url = AppUtils.getUrl('${AppConstants.Messagesendmeta}=$number');
    print("url==senddd>$url");
    String body = jsonEncode(bodyy);
    var result = await post(url: url, body: body);
    debug('result0 $result');

    return result;
  }

  Future<dynamic> uploadFiledb(File file, String? number, String? id) async {
    var token = await AppUtils.getToken();
    if (token == null || token.isEmpty) {
      print("No token found");
      return null;
    }
    var url = Uri.parse("${AppConstants.baseUrl}/whatsapp/files/$id");
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
      contentType: MediaType.parse(mimeType),
    );

    request.files.add(multipartFile);

    // Add headers
    request.headers.addAll({
      "Authorization": token,
      "Content-Type": "multipart/form-data",
    });
    debug("Request URL hhh: $url");
    debug("Request Headers jj: ${request.headers}");
    debug("Request Fields: ${request.fields}");
    debug("Request Files: ${request.files}");
    try {
      var response = await request.send();
      debug("response.statusCode${response.statusCode}");
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        print("File uploaded successfully");
        debug("File uploaded successfully $responseBody");
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

  Future<dynamic> uploadCampFiledb(File file, String? id,
      {bool isFromCamp = false}) async {
    var token = await AppUtils.getToken();
    if (token == null || token.isEmpty) {
      print("No token found");
      return null;
    }
    String uri = "";
    if (isFromCamp) {
      uri = "${AppConstants.baseUrl}/whatsapp/campaign/file/null";
    } else {
      uri = "${AppConstants.baseUrl}/whatsapp/campaign/file/$id";
    }

    var url = Uri.parse(uri);
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
      contentType: MediaType.parse(mimeType),
    );

    request.files.add(multipartFile);

    // Add headers
    request.headers.addAll({
      "Authorization": token,
      "Content-Type": "multipart/form-data",
    });
    debug("Request URL hhh: $url");
    debug("Request Headers jj: ${request.headers}");
    debug("Request Fields: ${request.fields}");
    debug("Request Files: ${request.files}");
    try {
      var response = await request.send();
      debug("response.statusCode${response.statusCode}");
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        print("File uploaded successfully");
        debug("File uploaded successfully $responseBody");
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

  Future<dynamic> sendimagehistory({
    required Map<String, dynamic> msghistorydata,
  }) async {
    print("histpy image send send history image");
    String url = AppUtils.getUrl(AppConstants.historycreate);
    print("histpy image send send history image>$url");
    String body = jsonEncode(msghistorydata);
    var result = await post(url: url, body: body);
    debug('histpy image send send history image $result');
    return result;
  }

  Future<dynamic> singlemsgdelete(String bodyy) async {
    print("Request body: $bodyy");

    var url = AppUtils.getUrl(AppConstants.singlemsgdelete);
    debug('Single message delete URL: $url');

    return delete(url: url, body: bodyy);
  }

  Future<dynamic> uploadvideo(File file, String? number) async {
    print("ulaoodoaooaooa");
    var token = await AppUtils.getToken();
    token ??= "";
    var url = Uri.parse(
        "${AppConstants.baseUrl}/webhook_template/documentId?whatsapp_setting_number=$number");
    print("videieieie=>URL=>>>>>>>$url");
    var request = http.MultipartRequest("POST", url);

    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

    final videoFormats = ['video/mp4', 'video/mov', 'video/avi', 'video/mpeg'];

    bool isVideo = videoFormats.contains(mimeType);

    final fileStream = http.ByteStream(file.openRead());
    final length = await file.length();

    var multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: file.path.split('/').last,
      contentType: MediaType.parse(mimeType),
    );

    request.files.add(multipartFile);

    request.headers.addAll({
      "Authorization": token,
      "Content-Type": isVideo ? "video/mp4" : "multipart/form-data",
    });

    debug("Request URL videooooo: $url");
    // debug("Request Headers: ${request.headers}");
    debug("Request Files: ${request.files}");

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print("✅ video uploaded successfully");
      debug("Response: $responseBody");
      return responseBody;
    } else {
      print("❌ Failed to upload file: ${response.reasonPhrase}");
      return null;
    }
  }
}
