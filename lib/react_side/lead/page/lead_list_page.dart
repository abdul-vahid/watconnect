// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/models/tags_list_model.dart';
import 'package:whatsapp/react_side/chat/controller/chat_controller.dart';
import 'package:whatsapp/react_side/chat/page/whatsapp_chat_page.dart';
import 'package:whatsapp/react_side/lead/controller/lead_list_controller.dart';
import 'package:whatsapp/react_side/lead/model/lead_list_model.dart';
import 'package:whatsapp/react_side/lead/widget/lead_item.dart';
import 'package:whatsapp/react_side/lead/widget/pinned_lead_item.dart';
import 'package:whatsapp/react_side/lead/widget/tag_filter_bottom_sheet.dart';
import 'package:whatsapp/utils/app_color.dart';

class LeadListPage extends StatefulWidget {
  const LeadListPage({super.key});

  @override
  State<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends State<LeadListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  late ScrollController _allController;
  late ScrollController _unreadController;
  late ScrollController _archivedController;

  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    final ctrl = Provider.of<LeadListController>(context, listen: false);

    ctrl.changeTab(LeadTabType.recentlyMessage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchLeads();
      ctrl.fetchPinnedLeads();
    });

    _allController = ScrollController();
    _unreadController = ScrollController();
    _archivedController = ScrollController();

    _allController.addListener(() => _onScroll(LeadTabType.recentlyMessage));
    _unreadController.addListener(() => _onScroll(LeadTabType.unread));
    _archivedController.addListener(() => _onScroll(LeadTabType.archived));

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      switch (_tabController.index) {
        case 0:
          ctrl.changeTab(LeadTabType.recentlyMessage);
          break;
        case 1:
          ctrl.changeTab(LeadTabType.unread);
          break;
        case 2:
          ctrl.changeTab(LeadTabType.archived);
          break;
      }

      ctrl.fetchLeads();
    });
  }

  void _onScroll(LeadTabType tab) {
    final ctrl = Provider.of<LeadListController>(context, listen: false);

    if (searchQuery.isNotEmpty || ctrl.selectedFilterTagIds.isNotEmpty) return;

    ScrollController controller;

    switch (tab) {
      case LeadTabType.recentlyMessage:
        controller = _allController;
        break;
      case LeadTabType.unread:
        controller = _unreadController;
        break;
      case LeadTabType.archived:
        controller = _archivedController;
        break;
      case LeadTabType.lead:
        throw UnimplementedError();
    }

    if (!controller.hasClients) return;

    if (controller.position.pixels >=
            controller.position.maxScrollExtent - 100 &&
        !ctrl.isPaginationLoading &&
        ctrl.hasMoreData) {
      ctrl.fetchLeads(isLoadMore: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _allController.dispose();
    _unreadController.dispose();
    _archivedController.dispose();
    super.dispose();
  }

  
  List<LeadRecord> _getFilteredLeads(List<LeadRecord> leads) {
    if (searchQuery.isEmpty) return leads;

    return leads.where((lead) {
      final name = (lead.contactName ?? "").toLowerCase();
      final phone = (lead.fullNumber ?? "").toLowerCase();
      final query = searchQuery.toLowerCase();

      return name.contains(query) || phone.contains(query);
    }).toList();
  }

  
  List<LeadRecord> _getFilteredPinnedLeads(List<LeadRecord> leads) {
    return _getFilteredLeads(leads)
        .where((e) => e.pinned == true)
        .toList();
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    LeadListController ctrl,
    ScrollController controller,
  ) {
    final filteredLeads = _getFilteredLeads(ctrl.filteredLeadList);

    Future<void> onRefresh() async {
      await ctrl.refresh();
    }

    if (ctrl.isLoading && ctrl.leadList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

  
    if (filteredLeads.isEmpty) {
      final isFilterApplied = ctrl.selectedFilterTagIds.isNotEmpty;

      String message;

      if (searchQuery.isNotEmpty) {
        message = "No leads found for \"$searchQuery\"";
      } else if (isFilterApplied) {
        message = "No leads match selected filters";
      } else {
        String tabTitle = "All";
        switch (_tabController.index) {
          case 1:
            tabTitle = "Unread";
            break;
          case 2:
            tabTitle = "Archived";
            break;
        }
        message = "No $tabTitle leads available";
      }

      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          controller: controller,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _buildEmptyState(message, Icons.inbox),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: controller,
        itemCount: filteredLeads.length + 1,
        itemBuilder: (context, index) {
          if (index < filteredLeads.length) {
            return LeadItem(data: filteredLeads[index],onTap: (){
              ChatController chatCtrl=Provider.of(context,listen: false);
              chatCtrl.setSelectedLeadNumber(filteredLeads[index].fullNumber??"");
              Navigator.push(context, MaterialPageRoute(builder: (context)=>WhatsappChatPage(
                leadId: filteredLeads[index].parentId??"",
                name: filteredLeads[index].contactName??"",
                number: filteredLeads[index].fullNumber??"",
              )));
            },);
          }

          if (ctrl.isPaginationLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeadListController>(
      builder: (context, ctrl, child) {
        final filteredPinnedLeads =
            _getFilteredPinnedLeads(ctrl.filteredLeadList);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColor.navBarIconColor,
            centerTitle: true,
            title: const Text("Recent Chat",
                style: TextStyle(color: Colors.white)),
            actions: [
             
              if (ctrl.selectedFilterTagIds.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.filter_alt_off,
                      color: Colors.white),
                  onPressed: () => ctrl.clearFilter(),
                ),

             
              IconButton(
                icon:
                    const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () async {
                  await ctrl.fetchAllTags();

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => TagFilterBottomSheet(
                      selectedTagIds: ctrl.selectedFilterTagIds,
                      filterMode: ctrl.filterMode,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
            
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: "Search by name or phone...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                searchQuery = "";
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

             if (ctrl.selectedFilterTagIds.isNotEmpty)
  Container(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColor.navBarIconColor.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Active Filters",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.navBarIconColor,
              ),
            ),
            GestureDetector(
              onTap: () => ctrl.clearFilter(),
              child: const Text(
                "Clear all",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.navBarIconColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

     
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ctrl.selectedFilterTagIds.map((id) {
            final tag = ctrl.allTagList.firstWhere(
              (e) => e.id == id,
              orElse: () => TagRecord(
                id: id,
                name: id,
                status: false,
                createddate: '',
                lastmodifieddate: '',
                createdbyid: '',
                lastmodifiedbyid: '',
                firstMessage: '',
                autoTagRules: [],
              ),
            );

            return Container(
              decoration: BoxDecoration(
                color: AppColor.navBarIconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColor.navBarIconColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
            
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    child: Text(
                      tag.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColor.navBarIconColor,
                      ),
                    ),
                  ),

              
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:4.0),
                    child: GestureDetector(
                      onTap: () {
                        final updated =
                            List<String>.from(ctrl.selectedFilterTagIds)
                              ..remove(id);
                    
                        ctrl.updateFilter(
                          tagIds: updated,
                          mode: ctrl.filterMode,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColor.navBarIconColor,
                          borderRadius: BorderRadius.circular(8)
                       
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  ),

              if (ctrl.pinnedLeadList.isNotEmpty)
               const PinnedLeadsWidget(
                   
                    ),

              const SizedBox(height: 10),

             
              Container(
                color: AppColor.navBarIconColor,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "All",),
                    Tab(text: "Unread"),
                    Tab(text: "Archived"),
                  ],
                  unselectedLabelStyle: const TextStyle(color: Colors.white30),
                  labelStyle: const TextStyle(color: Colors.white),
                  indicatorColor: Colors.white,
                ),
              ),

         
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(ctrl, _allController),
                    _buildList(ctrl, _unreadController),
                    _buildList(ctrl, _archivedController),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  
}