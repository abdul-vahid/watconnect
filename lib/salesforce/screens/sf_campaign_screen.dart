import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
import 'package:whatsapp/salesforce/model/campaign_model.dart';
import 'package:whatsapp/salesforce/screens/confige_listing_screen.dart';
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TextField(
              controller: searchController,
              // onChanged: ref.filterRecs,
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
                  child: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 0, 0, 0),
                      size: 20,
                    ),
                    onPressed: () {
                      // _showFilterBottomSheet(context);
                    },
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
              ),
            ),
          ),
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
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListView.builder(
                                itemCount: campController.sfCampaignList.length,
                                itemBuilder: (context, index) {
                                  return campListItem(
                                      campController.sfCampaignList[index],
                                      index + 1);
                                },
                              ),
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
      onTap: () {},
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
              Navigator.pop(context);
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
                              sfCampaignList.status == null
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: IntrinsicWidth(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${sfCampaignList.status}",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
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
}
