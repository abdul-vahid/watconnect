import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';
import '../../utils/function_lib.dart';

class SalesforceAuth {
  static Future<void> loginWithSalesforce(
    context, {
    bool? isFromDetailpage,
    String? id,
  }) async {
    FlutterAppAuth _appAuth = FlutterAppAuth();

    try {
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AppConstants.clientId,
          // AppConstants.redirectUri,
          "https://watconnect.com/",
          clientSecret: AppConstants.clientSecret,
          issuer: AppConstants.issuer,
          scopes: ['openid', 'offline_access', 'api'],
        ),
      );

      if (result != null) {
        debug('ID Token: ${result.idToken}');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          SharedPrefsConstants.idTokenKey,
          result.idToken ?? '',
        );

        if (result.refreshToken?.isNotEmpty == true) {
          await prefs.setString(
            SharedPrefsConstants.refreshTokenKey,
            result.refreshToken ?? '',
          );
        }

        if (result.accessToken?.isNotEmpty == true) {
          await prefs.setString(
            SharedPrefsConstants.accessTokenKey,
            result.accessToken ?? '',
          );
        }

        debug('Access Token: ${result.accessToken}');
      } else {
        throw Exception("Authorization failed");
      }
    } catch (e) {
      debug("Error during login: $e");
      rethrow;
    }
  }
}
