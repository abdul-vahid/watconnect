import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/react_side/chat/controller/chat_controller.dart';
import 'package:whatsapp/react_side/chat/page/whatsapp_chat_page.dart';
import 'package:whatsapp/react_side/lead/controller/lead_list_controller.dart';
import 'package:whatsapp/utils/app_color.dart';

class PinnedLeadsWidget extends StatefulWidget {
  bool isFromChat;
   PinnedLeadsWidget({super.key,this.isFromChat=false});

  @override
  State<PinnedLeadsWidget> createState() => _PinnedLeadsWidgetState();
}

class _PinnedLeadsWidgetState extends State<PinnedLeadsWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final ctrl = context.read<LeadListController>();

 
    if (ctrl.pinnedLeadList.isEmpty) {
      ctrl.fetchPinnedLeads();
    }

    _scrollController.addListener(() {
      final controller = context.read<LeadListController>();

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          controller.hasMorePinned &&
          !controller.isPinnedLoading) {
        controller.fetchPinnedLeads(isLoadMore: true);
      }
    });
  }

  String getInitial(String name) {
    if (name.isEmpty) return "?";
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeadListController>(
      builder: (context, leadCtrl, child) {
        if (leadCtrl.isPinnedLoading && leadCtrl.pinnedLeadList.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (leadCtrl.pinnedLeadList.isEmpty) {
          return const SizedBox(); 
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Pinned",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: leadCtrl.pinnedLeadList.length +
                    (leadCtrl.hasMorePinned ? 1 : 0), 
                itemBuilder: (context, index) {
                  
                  if (index == leadCtrl.pinnedLeadList.length) {
                    return const SizedBox(
                      width: 80,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final lead = leadCtrl.pinnedLeadList[index];

                  return GestureDetector(
                    onTap:(){


                      LeadListController ctrl=Provider.of(context,listen: false);
                       ChatController chatCtrl=Provider.of(context,listen: false);
              ctrl.getLeadDetail(lead.id??"");
              chatCtrl.setSelectedLeadNumber(lead.fullNumber??"");
              if(widget.isFromChat){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>WhatsappChatPage(
                leadId: lead.id??"",
                name: lead.name??"",
                number: lead.fullNumber??"",
                countryCode: lead.id??"",
              )));

              }else{
                
    Navigator.push(context, MaterialPageRoute(builder: (context)=>WhatsappChatPage(
                leadId: lead.id??"",
                name: lead.name??"",
                number: lead.fullNumber??"",
                countryCode: lead.id??"",
              )));

              }
          
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor:
                                AppColor.navBarIconColor.withOpacity(0.9),
                            child: Text(
                              getInitial(lead.name ?? ""),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lead.name ?? "",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}