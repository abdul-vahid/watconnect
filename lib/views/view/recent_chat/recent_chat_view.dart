import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';

import 'package:whatsapp/models/recent_chat_model.dart';
import 'package:whatsapp/utils/app_color.dart';

import 'package:whatsapp/views/view/recent_archieve_chat.dart';
import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
import 'package:whatsapp/views/view/recent_chat/char_appbar.dart';
import 'package:whatsapp/views/view/recent_chat/filter_chips.dart';
import 'package:whatsapp/views/view/recent_chat/filter_tag_bottom_sheet.dart';
import 'package:whatsapp/views/view/recent_chat/lead_record_item.dart';
import 'package:whatsapp/views/view/recent_chat/pinned_leads_section.dart';
import 'package:whatsapp/views/view/recent_chat/recent_chat_provider.dart';
import 'package:whatsapp/views/view/recent_chat/tag_bottom_sheet.dart';

class RecentChatView extends StatefulWidget {
  const RecentChatView({super.key});

  @override
  State<RecentChatView> createState() => _RecentChatViewState();
}

class _RecentChatViewState extends State<RecentChatView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pullRefresh(RecentChatProvider provider) async {
    await provider.refreshChats();
  }

  void _navigateToChat(
      BuildContext context, RecentChatProvider provider, Records model) {
    if (model.fullNumber != null) {
      provider.markAsRead(model.fullNumber!);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WhatsappChatScreen(
            pinnedLeads: provider.pinnedLeads,
            leadName: model.contactName ?? "",
            wpnumber: model.fullNumber,
            id: model.leadId,
            isArch: model.isArchived,
            contryCode: model.countryCode,
          ),
        ),
      ).then((_) {
        provider.refreshUnreadCount();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Phone Number'),
          backgroundColor: AppColor.motivationCar1Color,
        ),
      );
    }
  }

  void _showTagsSheet(
      BuildContext context, RecentChatProvider provider, Records lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TagsBottomSheet(
        lead: lead,
        allTags: provider.allUniqueTags,
        onTagsSaved: (selectedTagIds) async {
          await provider.saveTagsToLead(lead, selectedTagIds);
          if (context.mounted) Navigator.pop(context);
        },
        onTagCreated: (tagName) => provider.createTagInBackend(tagName),
      ),
    );
  }

  void _showFilterTagsSheet(BuildContext context, RecentChatProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterTagsBottomSheet(
        allTags: provider.allUniqueTags,
        selectedTags: provider.selectedTagsForFilter,
        onFilterApplied: (selectedTags) async {
          await provider.applyTagFilter(selectedTags);
          if (context.mounted) Navigator.pop(context);
        },
        onFilterCleared: () async {
          await provider.clearTagFilter();
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecentChatProvider(context),
      child: Consumer<RecentChatProvider>(
        builder: (context, provider, _) {
          return FocusDetector(
            onFocusGained: () => provider.refreshChats(),
            child: Scaffold(
              backgroundColor: AppColor.pageBgGrey,
              appBar: ChatAppBar(
                isTagFilterActive: provider.isTagFilterActive,
                selectedTagName: provider.selectedTagName,
                onBackPressed: provider.clearTagFilter,
                onArchivePressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecentArchieveChatView(),
                  ),
                ),
              ),
              body: GestureDetector(
                onTap: provider.clearPinSelection,
                child: RefreshIndicator(
                  onRefresh: () => _pullRefresh(provider),
                  child: _buildBody(context, provider),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, RecentChatProvider provider) {
    return Column(
      children: [
        /// SEARCH
        TextField(
          controller: _searchController,
          onChanged: provider.filterLeads,
          decoration: const InputDecoration(
            hintText: "Search chats...",
            prefixIcon: Icon(Icons.search),
          ),
        ),

        /// PINNED
        if (provider.pinnedLeads.isNotEmpty)
          PinnedLeadsSection(
            pinnedLeads: provider.pinnedLeads,
            onLeadTap: (lead) =>
                _navigateToChat(context, provider, lead),
          ),

        /// ✅ INITIAL LOADER ONLY
        if (provider.isInitialLoading &&
            provider.allRecentChats.isEmpty)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Expanded(
            child: Stack(
              children: [
                _buildChatList(context, provider),

                /// subtle top loader
                if (provider.isInitialLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildChatList(
      BuildContext context, RecentChatProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          FilterChips(
            selectedFilterId: provider.selectedFilterId,
            isTagFilterActive: provider.isTagFilterActive,
            selectedTagsCount: provider.selectedTagsForFilter.length,
            onFilterSelected: provider.applyFilter,
            onFilterTagsPressed: () =>
                _showFilterTagsSheet(context, provider),
          ),

          const Divider(),

          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildListView(context, provider)),

                /// ✅ PAGINATION BUTTONS (NON-BLOCKING)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: provider.currentPage > 1 &&
                                !provider.isPaginationLoading
                            ? provider.goToPreviousPage
                            : null,
                        child: provider.isPaginationLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Text("Previous"),
                      ),

                      ElevatedButton(
                        onPressed: provider.hasMore &&
                                !provider.isPaginationLoading
                            ? provider.goToNextPage
                            : null,
                        child: provider.isPaginationLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Text("Next"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(
      BuildContext context, RecentChatProvider provider) {
    if (provider.allRecentChats.isEmpty ||
        provider.noMatchedLeads) {
      return const Center(
        child: Text(
          "No Chat Found",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: provider.allRecentChats.length,
      itemBuilder: (context, index) {
        final lead = provider.allRecentChats[index];

        return LeadRecordItem(
          model: lead,
          unreadMsgCount:
              provider.getUnreadCountForLead(lead),
          shouldHideNumber:
              provider.shouldHideLeadNumber ?? false,
          allUniqueTags: provider.allUniqueTags,
          isSelectedForPin: provider.showPin &&
              provider.pinnedLeadId == lead.leadId,
          onTap: () =>
              _navigateToChat(context, provider, lead),
          onLongPress: () =>
              provider.selectLeadForPin(lead),
          onPinToggle: () =>
              provider.togglePinChat(lead),
          onArchiveToggle: () =>
              provider.toggleArchiveStatus(lead.leadId),
          onManageTags: () =>
              _showTagsSheet(context, provider, lead),
        );
      },
    );
  }
}