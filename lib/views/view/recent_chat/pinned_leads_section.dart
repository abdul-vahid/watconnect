import 'package:flutter/material.dart';
import 'package:whatsapp/models/recent_chat_model.dart';
import 'package:whatsapp/utils/app_color.dart';

class PinnedLeadsSection extends StatelessWidget {
  final List<Records> pinnedLeads;
  final Function(Records) onLeadTap;

  const PinnedLeadsSection({
    super.key,
    required this.pinnedLeads,
    required this.onLeadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Text(
            "Pinned Leads",
            style: TextStyle(fontFamily: 'Medium'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SizedBox(
            height: 70,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: pinnedLeads.map((model) {
                  print("pinned lead");
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: InkWell(
                      onTap: () => onLeadTap(model),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColor.navBarIconColor,
                                child: Text(
                                  model.contactName?.isNotEmpty == true
                                      ? model.contactName![0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Positioned(
                                top: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 8,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.push_pin,
                                    size: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const SizedBox(width: 60),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}