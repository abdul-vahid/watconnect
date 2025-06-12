import 'dart:io';

import 'package:http/http.dart' as http;

final client = http.Client();

class NetworkCalls {
  static Future<String> get(String url, Map<String, String>? header) async {
    var response = await http.get(
      Uri.parse(url),
      headers: header,
    );

    return response.body;
  }

  static Future<http.Response> post(
      String url, var body, Map<String, String>? header) async {
    var response = await http.post(Uri.parse(url), body: body, headers: header);
    return response;
  }

  static Future<String> put(
      String url, var body, Map<String, String>? header) async {
    var response = await http.put(Uri.parse(url), body: body, headers: header);
    return response.body;
  }

  static void checkAndThrowError(http.Response response) {
    if (response.statusCode != HttpStatus.ok) throw Exception(response.body);
  }
}
