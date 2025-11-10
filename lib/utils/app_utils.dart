// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/apis/app_exception.dart';
import '../core/models/base_list_view_model.dart';
import '../models/user_model/user_model.dart';
import '../utils/app_color.dart';
import '../utils/app_constants.dart';
import '../views/view/login_view.dart';
import 'function_lib.dart';
import 'notification_utils.dart';

class AppUtils {
  late UserModel userModelObjj;
  static bool isLoggedout = false;
  static int notificationCount = 0;
  static BuildContext? currentContext;
  static void onLoading(BuildContext? context, String? label) {
    showDialog(
        context: context!,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                  Text(
                    label!,
                  )
                ],
              ),
            ),
          );
        });
  }

  static List<Widget> _getTextWidgets(List<String> values) {
    List<Widget> widgets = [];
    for (var value in values) {
      widgets.add(Text(
        value,
        style: AppColor.themeNormal,
      ));
    }
    return widgets;
  }

  static DropdownButtonFormField<String> getDropdown(
    String? hint, {
    void Function(String?)? onSaved,
    List<dynamic>? data,
    void Function(String?)? onChanged,
    String? Function(String?)? validator,
    List<DropdownMenuItem<String>>? items,
    String? value,
  }) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        hintText: hint,
        // hintStyle: GoogleFonts.montserrat(fontSize: 14),
        contentPadding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
        focusedBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: AppColor.navBarIconColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        border: const OutlineInputBorder(),
      ),
      value: value,
      isExpanded: true,
      onSaved: onSaved,
      validator: validator,
      onChanged: onChanged,
      items: items ??
          data?.map<DropdownMenuItem<String>>((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status),
            );
          }).toList(),
    );
  }

  static TextFormField getTextFormField(
    String hintText, {
    controller,
    void Function(String?)? onSaved,
    void Function(String)? onChanged,
    void Function()? onTap,
    bool obscureText = false,
    bool readOnly = false,
    String? initialValue,
    int? maxLines = 1,
    InputDecoration? decoration = const InputDecoration(),
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      onSaved: onSaved,
      onTap: onTap,
      obscureText: obscureText,
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      onChanged: onChanged,
      initialValue: initialValue,
      decoration: InputDecoration(
        // suffixIcon: const Icon(Icons.check_circle, color: Colors.green),
        // errorStyle: TextStyle(
        //   color: const Color.fromARGB(255, 27, 216, 2),
        //   fontSize: 12,
        // ),

        contentPadding: const EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 10.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColor.navBarIconColor),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        // errorBorder: OutlineInputBorder(
        //   borderSide: const BorderSide(color: Color.fromARGB(255, 209, 0, 0)),
        //   borderRadius: BorderRadius.circular(8.0),
        // ),
        border: const OutlineInputBorder(),
        hintText: hintText,
        // hintStyle: tserrat(fontSize: 14),
      ),
      validator: validator,
    );
  }

  static getAlert(BuildContext context, List<String> values,
      {title = "", buttonLabel = 'OK', void Function()? onPressed}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: AppColor.themeNormal,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: _getTextWidgets(values),
            ),
          ),
          actions: [
            TextButton(
              onPressed: onPressed ?? () => _onPressed(context),
              child: Text(buttonLabel, style: AppColor.themeNormal),
            ),
          ],
        );
      },
    );
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(SharedPrefsConstants.userKey)) {
      var data = prefs.getString(SharedPrefsConstants.userKey);

      var userModel = UserModel.fromJson(data!);

      try {
        Map<String, dynamic> decodedToken =
            JwtDecoder.decode(userModel.authToken!);

        var modulesList = decodedToken['modules'];
        List availableModule =
            modulesList.map((e) => e['name'].toString()).toList();
        print("contains::: ${availableModule.contains('Billing')}");

        List<String> stringList = List<String>.from(availableModule);

        // print("stringList::::::::: $stringList  ${stringList.runtimeType}");
        await prefs.setStringList(
            SharedPrefsConstants.userAvailableMoulesKey, stringList);

        var userModelObj = UserModel.fromMap(decodedToken);
        await prefs.setString(
            SharedPrefsConstants.userDecodedTokenKey, userModelObj.toJson());

        await prefs.setString(SharedPrefsConstants.usertenantcodeKey,
            decodedToken['tenantcode'] ?? "");

        log("has wallet:::::::::::::::::::::::::::::::::::     ${decodedToken['has_wallet']}");

        await prefs.setBool(SharedPrefsConstants.hasWalletKey,
            decodedToken['has_wallet'] ?? false);

        await prefs.setBool(
            SharedPrefsConstants.hasCallsKey, stringList.contains("Calls"));

        userModel.authToken =
            prefs.getString(SharedPrefsConstants.accessTokenKey);

        return userModel.authToken;
      } catch (e) {
        print("Error decoding JWT: $e");
        return null;
      }
    } else {
      return null;
    }
  }

  static String getAccessToken(prefs) {
    return prefs.getString(SharedPrefsConstants.accessTokenKey);
  }

  static UserModel? getSessionUser(SharedPreferences prefs) {
    if (prefs.containsKey(SharedPrefsConstants.userDecodedTokenKey)) {
      // debug(
      //     "adsssssssssssssssssss${prefs.getString(SharedPrefsConstants.userKey)}");
      // print(
      //     "addddddddd${jsonDecode(prefs.getString(SharedPrefsConstants.userDecodedTokenKey)!)}");
      return UserModel.fromMap(jsonDecode(
          prefs.getString(SharedPrefsConstants.userDecodedTokenKey)!));
    }
    return null;
  }

  static ElevatedButton getElevatedButton(btnLabel,
      {required void Function()? onPressed, buttonStyle, textStyle}) {
    return ElevatedButton(
      style: buttonStyle,
      onPressed: onPressed,
      child: Text(btnLabel, style: textStyle),
    );
  }

  static showAlertDialog(BuildContext context, String title, String text) {
    Widget okButton = TextButton(
      child: const Text('Ok', style: AppColor.themeNormal),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        title,
        style: AppColor.themeNormal,
      ),
      content: Text(
        text,
        style: AppColor.themeNormal,
      ),
      actions: [
        okButton,
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static List<String> getErrorMessages(exception) {
    print("exception   $exception   ${exception.runtimeType}");
    List<String> errorMessages = [];
    print("exception is AppException:::: ${exception is AppException}");
    if (exception is AppException) {
      Map<String, dynamic> data = jsonDecode(exception.getMessage());
      print("data:::::::::::::  $data");
      data.forEach((key, value) {
        debug("key == $key == $value");
        errorMessages.add(value);
        isLoggedout = value.toString().toLowerCase() == "expired token";
      });
    } else {
      errorMessages.add(exception.toString());
    }
    return errorMessages;
  }

  static List<String> getLeadErrorMessages(exception) {
    print("exception   $exception   ${exception.runtimeType}");
    List<String> errorMessages = [];
    print("exception is AppException:::: ${exception is AppException}");
    if (exception is AppException) {
      Map<String, dynamic> data = jsonDecode(exception.getMessage());
      print("data:::::::::::::  $data");
      errorMessages.add(data['errors']);
      // data.forEach((key, value) {
      //   debug("key == $key == $value");
      //   errorMessages.add(value);
      //   isLoggedout = value.toString().toLowerCase() == "expired token";
      // });
    } else {
      errorMessages.add(exception.toString());
    }

    print("errorMessages::::::::::  $errorMessages");
    return errorMessages;
  }

  static Widget getErrorWidget(exception) {
    List<String> errorMessages = [];
    String errorMessage = "";

    errorMessages = AppUtils.getErrorMessages(exception);
    return errorMessages.isNotEmpty
        ? Center(
            child: Column(
            children: [for (var message in errorMessages) Text(message)],
          ))
        : Center(child: Text(errorMessage));
  }

  static Widget getAppBody(
      BaseListViewModel baseListViewModel, Widget Function() callBack,
      {context}) {
    if (baseListViewModel.status == "Loading") {
      return AppUtils.getLoader();
    }
    //  else if (baseListViewModel.status == "Error") {
    //   Widget widget = AppUtils.getErrorWidget(baseListViewModel.exception);
    //   Timer(Duration.zero, () {
    //     isLoggedOut(context);
    //   });

    //   return widget;
    // }
    else if (baseListViewModel.viewModels.isNotEmpty) {
      return callBack();
    } else {
      return AppUtils.getNoRecordWidget();
    }
  }

  static Center getLoader() => const Center(child: CircularProgressIndicator());
  static Center getNoRecordWidget({message = "No Records Found!"}) =>
      Center(child: Text(message));

  static String getImageUrl(logoUrl) {
    return '${AppConstants.baseUrl}${AppConstants.publicPath}/$logoUrl';
  }

  // static void viewPush(BuildContext context, Widget view) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => view),
  //   );
  // }

  static String getUrl(String path) {
    return AppConstants.baseUrl + path;
  }

  static Future<String> getSFUrl(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUrl = prefs.getString(SharedPrefsConstants.sfBaseUrl) ?? "";
    // String finalUrl = "$storedUrl/services/apexrest/WatConnect/";   //prod

    String finalUrl = "$storedUrl/services/apexrest/"; // stag

    return finalUrl + path;
  }

  static void onError(BuildContext context, error, {title = "Error Alert"}) {
    Navigator.pop(context);

    List<String> errorMessages = AppUtils.getErrorMessages(error);
    getAlert(context, errorMessages, title: title);
  }

  static _onPressed(context) {
    Navigator.of(context).pop();
  }

  static String capitalize(String string) {
    if (string.isEmpty) {
      return string;
    }
    return string[0].toUpperCase() + string.substring(1);
  }

  static void logout(context) {
    onLoading(context, "Logging out...");

    SharedPreferences.getInstance().then((prefs) {
      NotificationUtil.deleteFCMTokenOnLogout();
      prefs.clear();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false);
      //viewPush(context, const LoginHome());
    });
  }

  static void isLoggedOut(context) {
    if (isLoggedout) {
      logout(context);
    }
  }
  /* static FutureOr<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  } */

  static FutureOr<dynamic> getSimpleDialog(BuildContext context,
      {required String title, List<Widget>? children}) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (
          BuildContext context,
        ) {
          return SimpleDialog(
            //   shape: EdgeInsets.all(value),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Center(child: Text(title)),
            children: children,
          );
        });
  }

  static AppBar getappbar({
    String title = "",
    PreferredSizeWidget? bottom,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    List<Widget>? actions,
  }) {
    return AppBar(
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: true,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      bottom: bottom,
    );
  }

  static Widget geterrorwidget(BuildContext context,
      {required void Function()? onPressed}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Failed to load Data", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColor.navBarIconColor, // Text color
              minimumSize: const Size(80, 40), // Width and height of button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50), // Rounded corners
              ),
            ),
            onPressed: onPressed,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedPrefsConstants.refreshTokenKey);
  }
}
