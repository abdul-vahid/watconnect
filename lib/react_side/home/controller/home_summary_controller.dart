import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/network/api_call.dart';
import 'package:whatsapp/react_side/home/model/business_number_model.dart';
import 'package:whatsapp/react_side/home/model/home_summary_model.dart';
import 'package:whatsapp/react_side/lead/model/lead_list_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

class HomeSummaryController extends ChangeNotifier {
  HomeSummaryModel? homeSummary;

  Future<void> notify() async {
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> fetchHomeSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? number = prefs.getString('phoneNumber');
      String url = AppUtils.getUrl("${AppConstants.dashboardApi}$number");
      final response = await ApiHelper.get(url: url);

      homeSummary = HomeSummaryModel.fromJson(response);

      print(response);
    } catch (e) {
      print("Error: $e");
    } finally {
      notify();
    }
  }

  List<BusinessRecord> businessNumbers = [];

  BusinessRecord? selectedBusinessNum;
  setSelectedBusinessNum(BusinessRecord value) {
    selectedBusinessNum = value;
    fetchHomeSummary();
    notify();
  }

  List<String> activeBusinessNumbers = [];

  Future<void> fetchBusinessNumbers() async {
    try {
      activeBusinessNumbers.clear();
      String url = AppUtils.getUrl(AppConstants.whatsAppSettingAPIPath);
      final response = await ApiHelper.get(url: url);

      BusinessNumberModels body = BusinessNumberModels.fromJson(response);
      businessNumbers = body.record ?? [];

      final prefs = await SharedPreferences.getInstance();

      var selectedNum = await prefs.getString(
            'phoneNumber',
          ) ??
          "";
      print("selectedNum selected business num>>>>>>>>>>>>>>>>> $selectedNum");
      if (selectedNum.isNotEmpty) {
        for (int i = 0; i < businessNumbers.length; i++) {
          activeBusinessNumbers.add(businessNumbers[i].phone ?? "");
          if (selectedNum == businessNumbers[i].phone) {
            setSelectedBusinessNum(businessNumbers[i]);
          }
        }
      } else {
        prefs.setString('phoneNumber', businessNumbers.first.phone??"");
        setSelectedBusinessNum(businessNumbers.first);
      }
      print(response);
    } catch (e) {
      print("Error: $e");
    } finally {
      print("activeBusinessNumbers>>>>>>> $activeBusinessNumbers");
      notify();
    }
  }

  final int limit = 50;
  int offset = 0;
  List<LeadRecord> notificationList = [];
  bool isLoading = false;
  bool isPaginationLoading = false;
  bool hasMoreData = true;
  LeadListModel? unReadData;

  /// ================= RESET =================
  void resetPagination() {
    notificationList.clear();
    offset = 0;
    hasMoreData = true;
  }

  Future<void> fetchUnreadList({bool isLoadMore = false}) async {
    if (isLoading || isPaginationLoading || !hasMoreData) return;

    try {
      if (isLoadMore) {
        isPaginationLoading = true;
      } else {
        isLoading = true;
      }

      notifyListeners();

      var url = AppUtils.getUrl(AppConstants.leadList);

      String apiUrl = "${url}unread&limit=$limit&offset=$offset";

      final response = await ApiHelper.get(url: apiUrl);

      unReadData = LeadListModel.fromJson(response);

      if (isLoadMore) {
        notificationList.addAll(unReadData?.records ?? []);
      } else {
        notificationList = unReadData?.records ?? [];
      }

      offset += limit;

      hasMoreData = unReadData?.hasMore ?? false;
    } catch (e, StackTrace) {
      print("Fetch Error: $e.  ${StackTrace}");
    } finally {
      isLoading = false;
      isPaginationLoading = false;
      notifyListeners();
    }
  }
}
