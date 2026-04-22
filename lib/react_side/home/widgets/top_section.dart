import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/react_side/home/controller/home_summary_controller.dart';
import 'package:whatsapp/react_side/lead/page/all_leads_page.dart';
import 'package:whatsapp/views/view/campaign_list_view.dart';
import 'package:whatsapp/views/view/lead/lead_list_view.dart';

import 'package:whatsapp/views/widgets/home_page_cards.dart';
class TopCardsSection extends StatelessWidget {
  final List<String> modules;

  const TopCardsSection({super.key, required this.modules});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Consumer<HomeSummaryController>(
        builder: (_, ctrl, __) {
          final data = ctrl.homeSummary?.data;

          return Row(
            children: [
              Expanded(
                child: HomePageCard(
                   polygonAsset: "assets/images/home_polygon.png",
                  title: "All Leads",
                  subtitle: "${data?.leadCount ?? 0}",
                  icon: Icons.leaderboard,
                  tap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AllLeadsPage()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HomePageCard(
                    polygonAsset: "assets/images/home_polygon.png",
                  title: "Campaigns",
                  subtitle:
                      "${(data?.campaignStatus?.completed ?? 0) + (data?.campaignStatus?.aborted ?? 0)}",
                  icon: Icons.campaign,
                  tap: () {
                    if (modules.contains("Campaign")) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CampaignListView()),
                      );
                    } else {
                      EasyLoading.showToast("No access");
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}