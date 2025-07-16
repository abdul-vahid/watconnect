import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../core/apis/app_exception.dart';
import '../utils/function_lib.dart';

class APIService {
  Future getResponse(String url, String token) async {
    debug("url ----> $url");
    dynamic responseJson;
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$token',
      });
      // print(
      //     "get response without filters:::::: ${response.body}  ${response.statusCode}");

      // if (response.statusCode == 402) {
      //   var body = jsonDecode(response.body);
      //   print("body:::::::::  ${body}  ${body.runtimeType}");
      //   EasyLoading.showToast((body['message']));
      //   return response.body;
      // }
      responseJson = returnResponse(response);

      print("responseJson::: get api response :::: ${responseJson}");
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    //AppUtils.printDebug("responseData --> $responseJson");
    return responseJson;
  }

  Future<dynamic> postResponse(String url, var body, String token) async {
    print("url=>>>>>>>>>>>>>>> $url");
    //debug("API Serivce URL = ${url.substring(6)}");
    dynamic responseJson;
    try {
      final response = await http.post(Uri.parse(url), body: body, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$token',
      });

      responseJson = returnResponse(response);
      print("url=>>>>>>>>>>>>>>>111 $url");
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  Future<dynamic> putResponse(String url, var body, String token) async {
    //debug("API Serivce URL = ${url.substring(6)}");
    dynamic responseJson;
    try {
      final response = await http.put(Uri.parse(url), body: body, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': token,
      });

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  Future deleteResponse(String url, String token, {String? body}) async {
    dynamic responseJson;
    try {
      print("sddssasff=>>>>>>>>>${url}");
      print("fdelete response body=>>>>>>>>>${body}");
      final response = await http.delete(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': token,
          },
          body: body);

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  Future getMultipartResponse(String url, Map<String, String> data) async {
    dynamic responseJson;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll(data);
      http.StreamedResponse response = await request.send();

      var jsonResponse = await response.stream.bytesToString();
      responseJson = returnMultipartResponse(response, jsonResponse);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  @visibleForTesting
  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var jsonResponse = jsonDecode(response.body);
        //print(jsonResponse["records"]);
        return jsonResponse;
      case 201:
        var jsonResponse = jsonDecode(response.body);
        //print(jsonResponse["records"]);
        return jsonResponse;
      //return responseJson;
      case 204:
        var jsonResponse = jsonDecode(response.toString());
        //print('Delete jsonResponse ${jsonResponse}');
        return jsonResponse;
      case 400:
        throw BadRequestException(response.body.toString());
      case 402:
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      case 401:
      case 403:
        debug("Un Authorise");
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while communication with server with status code : ${response.statusCode}');
    }
  }

  @visibleForTesting
  dynamic returnMultipartResponse(
      http.StreamedResponse response, String jsonResponse) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(jsonResponse);
        return responseJson;
      case 400:
        throw BadRequestException(jsonResponse);
      case 401:
      case 403:
        throw UnauthorisedException(jsonResponse);
      case 500:
      default:
        throw FetchDataException(
            'Error occured while communication with server with status code : ${response.statusCode}');
    }
  }

  // Future<void> uploadImage(
  //     File image, String url, WhatsAppImageModel body, String token) async {
  //   var stream = http.ByteStream(image.openRead());

  //   var length = await image.length();

  //   var uri = Uri.parse(url);

  //   Map<String, String> header = {
  //     'Authorization': token,
  //   };
  //   Map<String, String> bodyData = {
  //     'title': body.title.toString(),
  //     'createddate': DateTime.now().toString(),
  //     'description': body.description.toString(),
  //     'filesize': body.filesize.toString(),
  //     'filetype': body.filetype.toString(),
  //   };

  //   print("Body Data: $bodyData");

  //   var request = http.MultipartRequest('POST', uri)
  //     ..headers.addAll(header)
  //     ..fields.addAll(bodyData)
  //     ..files.add(
  //       http.MultipartFile(
  //         'file',
  //         stream,
  //         length,
  //         filename: path.basename(image.path),
  //       ),
  //     );

  //   print("Request URL: $uri");
  //   print("Request Headers: ${request.headers}");
  //   print("Request Fields: ${request.fields}");
  //   print("Request Files: ${request.files}");

  //   var response = await request.send();

  //   var responseStream = await response.stream.bytesToString();
  //   print("Response body: $responseStream");

  //   if (response.statusCode == 201) {
  //     print("File uploaded successfully");
  //   } else {
  //     print("File upload failed with status code: ${response.statusCode}");
  //   }
  // }
}
