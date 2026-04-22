import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:whatsapp/models/tags_list_model.dart'
    show TagRecord, AllTagsModel;
import 'package:whatsapp/network/api_call.dart';
import 'package:whatsapp/react_side/lead/model/lead_detail_model.dart';
import 'package:whatsapp/react_side/lead/model/lead_list_model.dart';
import 'package:whatsapp/react_side/lead/model/pinned_leads_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

enum LeadTabType { recentlyMessage, lead, archived, unread }

enum FilterMode { or, and }

class LeadListController extends ChangeNotifier {
  List<LeadRecord> leadList = [];
  List<PinnedLeadRecord> pinnedLeadList = [];
  List<TagRecord> allTagList = [];
  final int limit = 50;
  int offset = 0;

  bool isPinnedLoading = false;
  bool isTagLoading = false;
  bool isLoading = false;
  bool isPaginationLoading = false;
  bool hasMoreData = true;

  LeadTabType currentTab = LeadTabType.recentlyMessage;

  /// ================= GET PARAM =================
  String _getTypeParam() {
    switch (currentTab) {
      case LeadTabType.recentlyMessage:
        return "recentlyMessage";
      case LeadTabType.lead:
        return "lead";
      case LeadTabType.archived:
        return "archived";
      case LeadTabType.unread:
        return "unread";
    }
  }

  /// ================= RESET =================
  void resetPagination() {
    leadList.clear();
    offset = 0;
    hasMoreData = true;
  }

  /// ================= CHANGE TAB =================
  Future<void> changeTab(LeadTabType tab) async {
    if (currentTab == tab) return;

    currentTab = tab;
    resetPagination();
    notifyListeners();

    await fetchLeads();
  }

  int pageNo = 1;
  bool hasMorePinned = true;

  resetPinnedLead() {
    pageNo = 1;
    hasMorePinned = true;
    notifyListeners();
  }

  Future<void> fetchPinnedLeads(
      {bool isLoadMore = false, showLoader = true}) async {
    if (isPinnedLoading) return;

    try {
      if (showLoader) {
        isPinnedLoading = true;
      }

      if (!isLoadMore) {
        pageNo = 1;
        hasMorePinned = true;
        pinnedLeadList.clear();
      }

      notifyListeners();

      var url = AppUtils.getUrl(AppConstants.pinnedLeads);
      var apiUrl = "$url?page=$pageNo&pageSize=25";

      final response = await ApiHelper.get(url: apiUrl);

      PinnedLeadModel data = PinnedLeadModel.fromJson(response);

      if (data.records != null && data.records!.isNotEmpty) {
        pinnedLeadList.addAll(data.records!);
        pageNo++;
      }

      hasMorePinned = data.hasMore ?? false;
    } catch (e) {
      debugPrint("Pinned Leads Error: $e");
    } finally {
      isPinnedLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllTags() async {
    if (isTagLoading) return;

    try {
      isTagLoading = true;
      notifyListeners();

      var url = AppUtils.getUrl(AppConstants.getAllTagsApi);
      final response = await ApiHelper.get(url: url);

      AllTagsModel data = AllTagsModel.fromJson(response);

      allTagList = data.records?.toList() ?? [];

      print("allTagList >>>> $allTagList");
    } catch (e, StackTrace) {
      print("fetchAllTags error: $e StackTrace>>>> $StackTrace");
    } finally {
      isTagLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeads({bool isLoadMore = false}) async {
    if (isLoading || isPaginationLoading || !hasMoreData) return;

    try {
      if (isLoadMore) {
        isPaginationLoading = true;
      } else {
        isLoading = true;
      }

      notifyListeners();

      var url = AppUtils.getUrl(AppConstants.leadList);

      String apiUrl = "${url}${_getTypeParam()}&limit=$limit&offset=$offset";

      final response = await ApiHelper.get(url: apiUrl);

      LeadListModel data = LeadListModel.fromJson(response);

      if (isLoadMore) {
        leadList.addAll(data.records);
      } else {
        leadList = data.records;
      }

      offset += limit;

      hasMoreData = data.hasMore;
    } catch (e, StackTrace) {
      print("Fetch Error: $e.  ${StackTrace}");
    } finally {
      isLoading = false;
      isPaginationLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    resetPagination();
    await fetchLeads();
  }

  unPinLead(String leadId) async {
    try {
      EasyLoading.show();
      String url = AppUtils.getUrl(
          AppConstants.unpinLead.replaceAll("{leadId}", leadId));

      final response = await ApiHelper.post(url: url, body: {});
      EasyLoading.showToast("Un Pinned Successfully");
    } catch (e) {
         EasyLoading.dismiss();
    } finally {
         EasyLoading.dismiss();
      resetPinnedLead();
      fetchPinnedLeads(showLoader: false);
      refetchSamePage();
    }
  }

  pinLead(String leadId) async {
    EasyLoading.show();
    try {
      String url =
          AppUtils.getUrl(AppConstants.pinLead.replaceAll("{leadId}", leadId));

      final response = await ApiHelper.post(url: url, body: {});
      EasyLoading.dismiss();
      EasyLoading.showToast("Pinned Successfully");
    } catch (e) {
      EasyLoading.dismiss();
    } finally {
      EasyLoading.dismiss();
      resetPinnedLead();
      fetchPinnedLeads(showLoader: false);
      refetchSamePage();
    }
  }

  archieveUnarchieveLead(String leadId, bool isArc) async {
    try {
      EasyLoading.show();
      Map<String, dynamic> body = {"id": leadId, "is_archived": isArc};

      String url = AppUtils.getUrl(AppConstants.leadAPIPath);
      String apiUrl = "$url/$leadId";

      final response = await ApiHelper.put(url: apiUrl, body: body);
    } catch (e) {
    } finally {
      refetchSamePage().then((onValue) {
        EasyLoading.dismiss();
      });
    }
  }

  updateTag(String leadId, List tags) async {
    try {
      Map<String, dynamic> body = {"id": leadId, "tag_names": tags};

      String url = AppUtils.getUrl(AppConstants.leadAPIPath);
      String apiUrl = "$url/$leadId";

      final response = await ApiHelper.put(url: apiUrl, body: body);
    } catch (e) {
    } finally {
      refetchSamePage();
    }
  }

  Future<void> refetchSamePage() async {
    try {
      isLoading = true;
      notifyListeners();

      var url = AppUtils.getUrl(AppConstants.leadList);

      String apiUrl = "${url}${_getTypeParam()}&limit=${offset}&offset=0";

      final response = await ApiHelper.get(url: apiUrl);

      LeadListModel data = LeadListModel.fromJson(response);

      leadList = data.records;

      hasMoreData = data.hasMore;
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<String> selectedFilterTagIds = [];
  FilterMode filterMode = FilterMode.or;

  List<LeadRecord> get filteredLeadList {
    if (selectedFilterTagIds.isEmpty) return leadList;

    return leadList.where((lead) {
      final leadTagIds = lead.tagNames?.map((e) => e.id ?? "").toList() ?? [];

      final leadTagNames =
          lead.tagNames?.map((e) => (e.name ?? "").toLowerCase()).toList() ??
              [];

      bool matches(String selectedId) {
        final selectedTag = allTagList.firstWhere(
          (tag) => tag.id == selectedId,
          orElse: () => TagRecord(
            id: selectedId,
            name: selectedId,
            status: false,
            createddate: '',
            lastmodifieddate: '',
            createdbyid: '',
            lastmodifiedbyid: '',
            firstMessage: '',
            autoTagRules: [],
          ),
        );

        return leadTagIds.contains(selectedId) ||
            leadTagNames.contains(selectedTag.name.toLowerCase());
      }

      if (filterMode == FilterMode.or) {
        return selectedFilterTagIds.any(matches);
      } else {
        return selectedFilterTagIds.every(matches);
      }
    }).toList();
  }

  void updateFilter({
    required List<String> tagIds,
    required FilterMode mode,
  }) {
    selectedFilterTagIds = tagIds;
    filterMode = mode;
    notifyListeners();
  }

  void clearFilter() {
    selectedFilterTagIds.clear();
    filterMode = FilterMode.or;
    notifyListeners();
  }




LeadDetail? leadDetail;


  getLeadDetail(String leadId,) async {
    try {
    

      String url = AppUtils.getUrl(AppConstants.leadAPIPath);
      String apiUrl = "$url/$leadId";

      final response = await ApiHelper.get(url: apiUrl,);
          LeadDetailModel data = LeadDetailModel.fromJson(response);
          leadDetail=data.records;
    } catch (e) {
    } finally {
      notifyListeners();
    }
  }


  //LeadRecord
}
