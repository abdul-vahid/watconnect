// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

class MessageController extends ChangeNotifier {
  var leadNo;
  var phNo;
  String userProfile = "";

  List msgToDelete = [];

  updateDeleteMsgList(String val) async {
    if (msgToDelete.contains(val)) {
      msgToDelete.remove(val);
    } else {
      msgToDelete.add(val);
    }

    print("msgToDelete>::>>:>>>:::>>>>  $msgToDelete");
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  clearDeleteList() async {
    msgToDelete.clear();
    msgToDelete = [];
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  setUsrProfile(str) async {
    userProfile = "";
    userProfile = str;
    print("setting the user prifiel:::::$userProfile");
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  // List allMessages = [];
  setLeadNum(var leadNum) async {
    leadNo = leadNum;
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  setPhoneNum(var phNum) async {
    phNo = phNum;
    await Future.delayed(Duration.zero);
    notifyListeners();
  }
}
