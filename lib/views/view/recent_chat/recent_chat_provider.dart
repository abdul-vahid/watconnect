// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:whatsapp/models/recent_chat_model.dart';
// import 'package:whatsapp/utils/app_constants.dart';
// import 'package:whatsapp/utils/app_utils.dart';
// import 'package:whatsapp/view_models/lead_list_vm.dart';
// import 'package:whatsapp/view_models/unread_count_vm.dart';

// class RecentChatProvider extends ChangeNotifier {
//   final BuildContext context;

//   RecentChatProvider(this.context) {
//     _init();
//   }


//   List<Records> allRecentChats = [];
//   List<Records> tempLeadModelList = [];
//   List<Records> pinnedLeads = [];

//   List unreadList = [];
//   Map<String, dynamic> unreadMap = {};

//   List<Map<String, dynamic>> allUniqueTags = [];
//   List<Map<String, dynamic>> selectedTagsForFilter = [];

//   bool isInitialLoading = false;
//   bool isPaginationLoading = false;

//   bool noMatchedLeads = false;

//   bool isTagFilterActive = false;
//   int selectedFilterId = 0;

//   bool showPin = false;
//   String pinnedLeadId = "";

//   bool? shouldHideLeadNumber;
//   String? phoneNumber;

//   int currentPage = 1;
//   final int limit = 50;
//   bool hasMore = true;


//   Future<void> _init() async {
//     await _loadPrefs();
//     await refreshChats();
//     await refreshUnreadCount();
//   }

//   Future<void> _loadPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     shouldHideLeadNumber = prefs.getBool('shouldHideNumber');
//     phoneNumber = prefs.getString('phoneNumber');
//     notifyListeners();
//   }


//   Future<void> refreshChats() async {
//     currentPage = 1;
//     hasMore = true;

//     tempLeadModelList.clear();
//     allRecentChats.clear();

//     await _fetchData();
//     _applyCurrentFilter();
//   }

//   Future<void> _fetchData() async {
//     try {
//       if (currentPage == 1) {
//         isInitialLoading = true;
//         notifyListeners();
//       }

//       final offset = (currentPage - 1) * limit;

//       final url = AppUtils.getUrl(
//         AppConstants.recentChat
//             .replaceAll('{textName}', '')
//             .replaceAll('{recordType}', 'recentlyMessage')
//             .replaceAll('{limit}', limit.toString())
//             .replaceAll('{offset}', offset.toString()),
//       );
//        print("url of recent chat>>>>> $url");
//       final token = await AppUtils.getToken() ?? "";

//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);

//         List data = jsonData['records'] ?? [];
//         hasMore = jsonData['hasMore'] ?? false;

//         final fetched =
//             data.map((e) => Records.fromMap(e)).toList();

//         if (currentPage == 1) {
//           tempLeadModelList = List.from(fetched);
//         } else {
//           final existingIds =
//               tempLeadModelList.map((e) => e.leadId).toSet();

//           final newItems = fetched
//               .where((e) => !existingIds.contains(e.leadId))
//               .toList();

//           tempLeadModelList.addAll(newItems);
//         }

//         pinnedLeads = tempLeadModelList
//             .where((e) => e.pinned == true)
//             .toList();

//         _extractTags();
//       }
//     } catch (e) {
//       debugPrint("fetchChats error: $e");
//     } finally {
//       isInitialLoading = false;
//       notifyListeners();
//     }
//   }


//   Future<void> goToNextPage() async {
//     if (isPaginationLoading) return;

//     isPaginationLoading = true;
//     notifyListeners();

//     try {
//       if (selectedFilterId == 1) {
//         bool foundUnread = false;

//         while (hasMore && !foundUnread) {
//           currentPage++;

//           await _fetchData();
//           await refreshUnreadCount();

//           final unread = _getUnread();

//           if (unread.isNotEmpty) {
//             foundUnread = true;
//           }
//         }
//       } else {
//         if (!hasMore) return;

//         currentPage++;
//         await _fetchData();
//       }
//     } catch (e) {
//       debugPrint("pagination error: $e");
//     } finally {
//       isPaginationLoading = false;
//       _applyCurrentFilter();
//     }
//   }

//   Future<void> goToPreviousPage() async {
//     if (currentPage <= 1 || isPaginationLoading) return;

//     currentPage--;

//     await _fetchData();

//     if (selectedFilterId == 1) {
//       await refreshUnreadCount();
//     }

//     _applyCurrentFilter();
//   }


//   Future<void> applyFilter(int index) async {
//     selectedFilterId = index;

//     isTagFilterActive = false;
//     selectedTagsForFilter.clear();

//     await refreshChats();

//     if (selectedFilterId == 1) {
//       await refreshUnreadCount();
//     }

//     _applyCurrentFilter();
//   }

//   Future<void> applyTagFilter(List<Map<String, dynamic>> tags) async {
//     selectedTagsForFilter = tags;
//     isTagFilterActive = tags.isNotEmpty;

//     selectedFilterId = 0;

//     await refreshChats();
//     _applyCurrentFilter();
//   }

//   Future<void> clearTagFilter() async {
//     selectedTagsForFilter.clear();
//     isTagFilterActive = false;
//     selectedFilterId = 0;

//     await refreshChats();
//     _applyCurrentFilter();
//   }

//   void _applyCurrentFilter() {
//     if (selectedFilterId == 1) {
//       allRecentChats = _getUnread();
//     } else if (isTagFilterActive) {
//       allRecentChats = _getByTags(selectedTagsForFilter);
//     } else {
//       allRecentChats = List.from(tempLeadModelList);
//     }

//     noMatchedLeads = allRecentChats.isEmpty;
//     notifyListeners();
//   }


//   void filterLeads(String query) {
//     final q = query.toLowerCase();

//     if (q.isEmpty) {
//       _applyCurrentFilter();
//       return;
//     }

//     final source = List<Records>.from(allRecentChats);

//     allRecentChats = source.where((e) {
//       return (e.contactName ?? "").toLowerCase().contains(q) ||
//           (e.whatsappNumber ?? "").toLowerCase().contains(q);
//     }).toList();

//     noMatchedLeads = allRecentChats.isEmpty;
//     notifyListeners();
//   }


//   Future<void> refreshUnreadCount() async {
//     if (phoneNumber == null) return;

//     final vm =
//         Provider.of<UnreadCountVm>(context, listen: false);

//     await vm.fetchunreadcount(number: phoneNumber!);

//     unreadList = vm.viewModels
//         .map((e) => e.model?.records ?? [])
//         .expand((e) => e)
//         .toList();

//     unreadMap = {
//       for (var u in unreadList)
//         u.whatsappNumber: u.unreadMsgCount ?? 0
//     };

//     notifyListeners();
//   }

//   List<Records> _getUnread() {
//     final set = unreadMap.keys.toSet();

//     return tempLeadModelList
//         .where((e) => set.contains(e.whatsappNumber))
//         .toList();
//   }

//   String getUnreadCountForLead(Records lead) {
//     return (unreadMap[lead.whatsappNumber] ?? 0).toString();
//   }

//   Future<void> markAsRead(String whatsappNumber) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final myNumber = prefs.getString('phoneNumber');

//       final vm =
//           Provider.of<UnreadCountVm>(context, listen: false);

//       unreadMap.remove(whatsappNumber);

//       allRecentChats.removeWhere(
//           (e) => e.whatsappNumber == whatsappNumber);

//       notifyListeners();

//       await vm.marksreadcountmsg(
//         leadnumber: whatsappNumber,
//         number: myNumber,
//         bodydata: {"whatsapp_number": whatsappNumber},
//       );
//     } catch (e) {
//       debugPrint("markAsRead error: $e");
//     }
//   }


// Future<void> _updateLeadTags(
//     String leadId, List<dynamic> tags) async {
//   try {
//     final token = await AppUtils.getToken();

//     final url =
//         Uri.parse("https://admin.watconnect.com/ibs/api/leads/$leadId");

//     final response = await http.put(
//       url,
//       headers: {
//         "Authorization": "Bearer $token",
//         "Content-Type": "application/json"
//       },
//       body: jsonEncode({
//         "tag_names": tags,
//       }),
//     );

//     if (response.statusCode != 200 &&
//         response.statusCode != 204) {
//       throw Exception("Failed");
//     }
//   } catch (e) {
//     debugPrint("tag update error: $e");
//     rethrow;
//   }
// }

// Future<void> saveTagsToLead(
//     Records lead, List<String> selectedIds) async {
//   final oldTags = lead.tags;

//   try {
//     lead.tags = selectedIds
//         .map((id) => allUniqueTags
//             .firstWhere((t) => t['id'] == id,
//                 orElse: () => {"id": id, "name": ""}))
//         .map((e) => Tag(
//               id: e['id'],
//               name: e['name'],
//             ))
//         .toList();

//     notifyListeners();


//     await _updateLeadTags(lead.leadId ?? "", selectedIds);

   
//     _extractTags();

//     EasyLoading.showToast("Tags updated");
//   } catch (e) {

//     lead.tags = oldTags;
//     notifyListeners();

//     EasyLoading.showToast("Failed to update tags");
//   }
// }

//   String? get selectedTagName {
//     if (selectedTagsForFilter.isEmpty) return null;

//     return selectedTagsForFilter
//         .map((e) => e['name'])
//         .where((e) => e != null)
//         .join(', ');
//   }

//   List<Records> _getByTags(List<Map<String, dynamic>> tags) {
//     final ids = tags.map((e) => e['id']).toSet();

//     return tempLeadModelList.where((lead) {
//       if (lead.tags == null) return false;

//       final leadIds = lead.tags!.map((e) => e.id).toSet();
//       return ids.every((id) => leadIds.contains(id));
//     }).toList();
//   }

//   Future<Map<String, dynamic>?> createTagInBackend(String name) async {
//     if (name.trim().isEmpty) {
//       EasyLoading.showToast("Tag name required");
//       return null;
//     }

//     try {
//       final token = await AppUtils.getToken();

//       final res = await http.post(
//         Uri.parse("https://admin.watconnect.com/ibs/api/whatsapp/tag"),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json"
//         },
//         body: jsonEncode({
//           "name": name.trim(),
//           "status": true,
//         }),
//       );

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         final record = jsonDecode(res.body)["record"];

//         allUniqueTags.add({
//           "id": record["id"],
//           "name": record["name"],
//         });

//         notifyListeners();
//         EasyLoading.showToast("Tag created");

//         return record;
//       }
//     } catch (e) {
//       EasyLoading.showToast("Error creating tag");
//     }

//     return null;
//   }

//   void _extractTags() {
//     final seen = <String>{};
//     allUniqueTags.clear();

//     for (var r in tempLeadModelList) {
//       if (r.tags == null) continue;

//       for (var t in r.tags!) {
//         if (t.id != null && !seen.contains(t.id)) {
//           seen.add(t.id!);

//           allUniqueTags.add({
//             "id": t.id,
//             "name": t.name,
//           });
//         }
//       }
//     }
//   }


//   void selectLeadForPin(Records lead) {
//     showPin = true;
//     pinnedLeadId = lead.leadId ?? "";
//     notifyListeners();
//   }

//   void clearPinSelection() {
//     showPin = false;
//     pinnedLeadId = "";
//     notifyListeners();
//   }

//   Future<void> togglePinChat(Records lead) async {
//     final vm =
//         Provider.of<LeadListViewModel>(context, listen: false);

//     final isPinned = lead.pinned == true;
//     lead.pinned = !isPinned;

//     notifyListeners();

//     try {
//       if (isPinned) {
//         await vm.unpinChat(lead.leadId ?? "");
//       } else {
//         await vm.pinChat(lead.leadId ?? "");
//       }
//     } catch (e) {
//       lead.pinned = isPinned;
//       notifyListeners();
//     }
//   }


//   Future<void> toggleArchiveStatus(String? id) async {
//     try {
//       final vm =
//           Provider.of<LeadListViewModel>(context, listen: false);

//       await vm.updatelead({"id": id, "is_archived": true}, id ?? "");

//       EasyLoading.showToast("Archived");
//       await refreshChats();
//     } catch (e) {
//       EasyLoading.showToast("Failed");
//     }
//   }
// }