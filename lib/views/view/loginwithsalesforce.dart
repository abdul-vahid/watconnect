import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';

import '../../utils/app_constants.dart';

import '../../utils/function_lib.dart';
import '../widgets/bottomnavigatonbar.dart';

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
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint:
                'https://test.salesforce.com/services/oauth2/authorize',
            tokenEndpoint: 'https://test.salesforce.com/services/oauth2/token',
          ),
          AppConstants.clientId,
          AppConstants.redirectUri,
          // "https://watconnect.com/",
          clientSecret: AppConstants.clientSecret,
          issuer: AppConstants.issuer,

          scopes: ['openid', 'offline_access', 'api', 'refresh_token'],
        ),
      );

      print("result:::: ${result}");

      if (result != null) {
        print(
            "result:::::::${result.tokenAdditionalParameters}}:::::::::::: ${result.authorizationAdditionalParameters}  ${result.tokenAdditionalParameters}");
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
          if (result.accessToken?.isNotEmpty == true) {
            await prefs.setString(
              SharedPrefsConstants.accessTokenKey,
              result.accessToken ?? '',
            );
            DashBoardController dashBoardController =
                Provider.of(context, listen: false);
            dashBoardController.setLoginType(true);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const FooterNavbarPage(),
              ),
              (Route<dynamic> route) => false,
            );
          }
        }
        debug(
            'result Token: ${result.authorizationAdditionalParameters}      ');
        debug(
            'result tokenAdditionalParameters: ${result.tokenAdditionalParameters} \n   ${result.tokenAdditionalParameters?['instance_url']}    ');
        debug('Access Token: ${result.accessToken}');
        debug('resulttt : ${result.refreshToken}');

        await prefs.setString(
          SharedPrefsConstants.sfAccessToken,
          result.accessToken ?? '',
        );

        await prefs.setString(
          SharedPrefsConstants.sfRefreshToken,
          result.refreshToken ?? '',
        );

        await prefs.setString(
          SharedPrefsConstants.sfInstanceurl,
          result.tokenAdditionalParameters?['instance_url'] ?? '',
        );
      } else {
        throw Exception("Authorization failed");
      }
    } catch (e) {
      debug("Error during login: $e");
      rethrow;
    }
  }

  // Future<void> refreshToken(BuildContext context) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final refreshToken = await AppUtils.getRefreshToken();

  //     if (refreshToken == null || refreshToken.isEmpty) {
  //       throw Exception("Refresh token is missing");
  //     }

  //     Map<String, String> body = {
  //       'grant_type': 'refresh_token',
  //       'client_id': AppConstants.clientId,
  //       'client_secret': AppConstants.clientSecret,
  //       'refresh_token': refreshToken
  //     };

  //     // var response = await postAsUrlEncoded(
  //     //   url: AppConstants.refreshTokenAPIPath,
  //     //   body: body,
  //     // );
  //     print("resposne=>${response}");
  //     final newAccessToken = response["access_token"];

  //     if (newAccessToken != null && newAccessToken.toString().isNotEmpty) {
  //       debug("New access token => $newAccessToken");
  //       await prefs.setString(
  //         SharedPrefsConstants.accessTokenKey,
  //         newAccessToken,
  //       );
  //     } else {
  //       throw Exception("Access token not found in response");
  //     }
  //   } on UnauthorisedException {
  //     debug("Unauthorised: Invalid refresh token or session expired");

  //     throw Exception("Unauthorised Error");
  //   } catch (e, stackTrace) {
  //     debug("Error occurred in refreshToken: $e");
  //     debug("Stack trace: $stackTrace");
  //     throw Exception("Error occurred");
  //   }
  // }
}
