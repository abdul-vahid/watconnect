import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

class ApiHelper {
  static bool _isRefreshing = false;

  /// ================= HEADERS =================
  static Future<Map<String, String>> _getHeaders({
    bool requireAuth = true,
  }) async {
    final token = await AppUtils.getToken();

    if (requireAuth && (token == null || token.isEmpty)) {
      throw Exception("Token missing");
    }

    return {
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// ================= RESPONSE HANDLER =================
  static Future<dynamic> _handleResponse(
    http.Response response,
    String? url,
    Future<http.Response> Function() retryRequest,
  ) async {
    final status = response.statusCode;

    log("STATUS → $status");
    
    log("RESPONSE →$url  ${response.body}");

  
    if (status == 200 || status == 201) {
      return jsonDecode(response.body);
    }

    
    if (status == 403) {
      log(" Token expired → refreshing...");

      final success = await _refreshToken();

      if (success) {
        log(" Retrying original request...");

        final newResponse = await retryRequest();

        if (newResponse.statusCode == 200 ||
            newResponse.statusCode == 201) {
          return jsonDecode(newResponse.body);
        } else {
          throw Exception("Retry failed: ${newResponse.statusCode}");
        }
      } else {
        log("Refresh failed → logout");
        AppUtils.logout(AppUtils.currentContext);
        throw Exception("Session expired");
      }
    }

    if (status == 401) {
      AppUtils.logout(AppUtils.currentContext);
      throw Exception("Unauthorized");
    }
    if (status == 402) {
      throw Exception("Plan expired");
    }

    
    if (status == 404) {
      throw Exception("Not found");
    }

 
    if (status == 500) {
      throw Exception("Server error");
    }

    throw Exception('Error: $status ${response.body}');
  }

  static Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      log("Already refreshing → wait...");
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }

    _isRefreshing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken =
          prefs.getString(SharedPrefsConstants.refreshTokenKey) ?? "";

      if (refreshToken.isEmpty) {
        log(" No refresh token");
        return false;
      }

      final url = AppUtils.getUrl(AppConstants.refreshTokenAPIPath);

      log("calling refresh API → $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      log(" Refresh response → ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await prefs.setString(
            SharedPrefsConstants.accessTokenKey, data["authToken"]);
        await prefs.setString(
            SharedPrefsConstants.refreshTokenKey, data["refreshToken"]);

        log(" Token refreshed successfully");
        return true;
      }

      return false;
    } catch (e) {
      log(" Refresh error → $e");
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// ================= GET =================
  static Future<dynamic> get({
    required String url,
    bool requireAuth = true,
  }) async {
    try {
      log("GET → $url");

      Future<http.Response> request() async {
        final headers = await _getHeaders(requireAuth: requireAuth);
        log("headers → $headers");
        return http
            .get(Uri.parse(url), headers: headers)
            .timeout(const Duration(seconds: 30));
      }

      final response = await request();

      return await _handleResponse(response, url,request,);
    } catch (e) {
      log("GET ERROR → $e");
      rethrow;
    }
  }

  /// ================= POST =================
  static Future<dynamic> post({
    required String url,
    required Map<String, dynamic> body,
    bool requireAuth = true,
  }) async {
    try {
      log("POST → $url");
      log("BODY → $body");

      Future<http.Response> request() async {
        final headers = await _getHeaders(requireAuth: requireAuth);

        return http
            .post(
              Uri.parse(url),
              headers: headers,
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 30));
      }

      final response = await request();

      return await _handleResponse(response, url,request);
    } catch (e) {
      log("POST ERROR → $e");
      rethrow;
    }
  }


    /// ================= POST =================
  static Future<dynamic> delete({
    required String url,
    required Map<String, dynamic> body,
    bool requireAuth = true,
  }) async {
    try {
      log("DELETE → $url");
      log("BODY → $body");

      Future<http.Response> request() async {
        final headers = await _getHeaders(requireAuth: requireAuth);

        return http
            .delete(
              Uri.parse(url),
              headers: headers,
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 30));
      }

      final response = await request();

      return await _handleResponse(response, url,request);
    } catch (e) {
      log("DELETE ERROR → $e");
      rethrow;
    }
  }

  /// ================= PUT =================
  static Future<dynamic> put({
    required String url,
    required Map<String, dynamic> body,
    bool requireAuth = true,
  }) async {
    try {
      log("PUT → $url");
      log("BODY → $body");

      Future<http.Response> request() async {
        final headers = await _getHeaders(requireAuth: requireAuth);

        return http
            .put(
              Uri.parse(url),
              headers: headers,
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 30));
      }

      final response = await request();

      return await _handleResponse(response,url, request);
    } catch (e) {
      log("PUT ERROR → $e");
      rethrow;
    }
  }
}