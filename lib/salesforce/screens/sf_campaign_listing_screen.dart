import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
import 'package:whatsapp/salesforce/model/campaign_model.dart';
import 'package:whatsapp/salesforce/screens/confige_listing_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_add_camp.dart';
import 'package:whatsapp/salesforce/screens/sf_campaign_detail.dart';
import 'package:whatsapp/utils/app_color.dart';

class SfCampaignScreen extends StatefulWidget {
  const SfCampaignScreen({super.key});

  @override
  State<SfCampaignScreen> createState() => _SfCampaignScreenState();
}

class _SfCampaignScreenState extends State<SfCampaignScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    SfcampaignController campController = Provider.of(context, listen: false);
    campController.getCampaignApiCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColor.navBarIconColor,
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.add,
                  size: 25,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SfAddCampScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Campaigns',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Consumer<SfcampaignController>(builder: (context, ref, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: TextField(
                controller: searchController,
                onChanged: ref.searchCamp,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: AppColor.textoriconColor.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            color: Color.fromARGB(255, 0, 0, 0),
                            size: 20,
                          ),
                          onPressed: () {
                            _showFilterBottomSheet(context);
                          },
                        ),
                        ref.campaignStatusList.length == 0
                            ? SizedBox()
                            : Positioned(
                                left: 8,
                                top: 5,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.brown),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        ref.campaignStatusList.length
                                            .toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 40),
                ),
              ),
            );
          }),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: _pageBody(),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  _pageBody() {
    return Consumer<SfcampaignController>(
        builder: (context, campController, child) {
      return Column(
        children: [
          Expanded(
            child: campController.getCampLoader
                ? const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : campController.sfCampaignList.isEmpty
                    ? const Center(
                        child: Text(
                          "No Campaigns Found..",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                "${campController.sfCampaignList.length} Campaigns Available",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: campController.sfCampaignList.length,
                              itemBuilder: (context, index) {
                                return campListItem(
                                  campController.sfCampaignList[index],
                                  index + 1,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      );
    });
  }

  campListItem(SfCampaignModel sfCampaignList, int index) {
    Color statusColor;
    statusColor = Colors.lightBlue.withOpacity(0.7);
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: statusColor,
              width: 5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 3,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: InkWell(
            onTap: () async {
              showBlurOnlyLoaderDialog(context);
              SfcampaignController campController =
                  Provider.of(context, listen: false);
              campController.setSelectedCampaign(sfCampaignList);
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SfCampaignDetailScreen()));
            },
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColor.navBarIconColor,
                      child: Text(
                        index.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${sfCampaignList.name}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                "Start Time : ${campDate(sfCampaignList.startDateTime ?? "")}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              // sfCampaignList.status == null
                              //     ? SizedBox()
                              //     :
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: IntrinsicWidth(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        sfCampaignList.status ?? "Pending",
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        enableDrag: false,
        builder: (BuildContext context) {
          return Consumer<SfcampaignController>(
              builder: (context, campController, child) {
            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppColor.navBarIconColor,
                                borderRadius: BorderRadius.circular(8)),
                            height: 40,
                            width: 350,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Campaign Status Filter',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    MultiSelectDialogField<String>(
                      items: [
                        'All',
                        'In Progress',
                        'Completed',
                        'Pending',
                      ].map((e) => MultiSelectItem<String>(e, e)).toList(),
                      title: const Flexible(
                        child: Text(
                          "Select Leads Status",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      buttonText: const Text("Select Leads Status"),
                      searchable: true,
                      dialogWidth: 300,
                      dialogHeight: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey,
                        ),
                      ),
                      onConfirm: (List<String> selected) {
                        campController.setCampStatusList(selected);
                        // Update selectleadList with the confirmed selections
                        // selectleadList = selected;
                      },
                      initialValue: [],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      children:
                          campController.campaignStatusList.map((selectedItem) {
                        return Chip(
                          label: Text(selectedItem),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            campController
                                .removeFromCampStatusList(selectedItem);
                          },
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          labelStyle: const TextStyle(color: Colors.blue),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            campController.resetCampStatusList();
                            campController.filterCamp();

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.cardsColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Clear Filters',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            campController.filterCamp();
                            Navigator.pop(context);
                            // Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.cardsColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }
}

campDate(String startDateTime) {
  DateTime dt = DateTime.parse(startDateTime);
  String readable = DateFormat('MMMM d, y – h:mm a').format(dt);
  return readable;
}
