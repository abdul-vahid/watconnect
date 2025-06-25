import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/utils/app_constants.dart';

class ApiHelper {
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// GET request
  static Future<dynamic> get(String url, {bool debug = false}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (debug) {
        log("GET $url\nHeaders: $headers\nStatus: ${response.statusCode}\nBody: ${response.body}");
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'GET request failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log("GET request error: $e");
      rethrow;
    }
  }

  /// POST request
  static Future<dynamic> post(String url, Map body,
      {bool debug = false}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (debug) {
        log("POST $url\nHeaders: $headers\nBody: $body\nStatus: ${response.statusCode}\nResp: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'POST request failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log("POST request error: $e");
      rethrow;
    }
  }

  /// PUT request
  static Future<dynamic> put(String url, Map body, {bool debug = false}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (debug) {
        log("PUT $url\nHeaders: $headers\nBody: $body\nStatus: ${response.statusCode}\nResp: ${response.body}");
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'PUT request failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log("PUT request error: $e");
      rethrow;
    }
  }
}
