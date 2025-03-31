import 'package:flutter/material.dart';

class MessageController extends ChangeNotifier {
  var leadNo;
  var phNo;
  String userProfile = "";

  setUsrProfile(str) {
    userProfile = str;
    print("setting the user prifiel:::::${userProfile}");
    notifyListeners();
  }

  List allMessages = [];
  setLeadNum(var leadNum) {
    leadNo = leadNum;
    notifyListeners();
  }

  setPhoneNum(var phNum) {
    phNo = phNum;
    notifyListeners();
  }
}
