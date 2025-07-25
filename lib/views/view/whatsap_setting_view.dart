// import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/models/whatsapp_setting_model/whatsapp_setting_model.dart';
import 'package:whatsapp/utils/app_color.dart';
import '../../view_models/whatsapp_setting_vm.dart';
import '../../models/whatsapp_setting_model/record.dart';

class WhatsapSettingView extends StatefulWidget {
  const WhatsapSettingView({super.key});

  @override
  State<WhatsapSettingView> createState() => _WhatsapSettingViewState();
}

class _WhatsapSettingViewState extends State<WhatsapSettingView> {
  WhatsappSettingViewModel? wapmodel;
  Future<void> _pullRefresh() async {
    Provider.of<WhatsappSettingViewModel>(context, listen: false)
        .viewModels
        .clear();
    Provider.of<WhatsappSettingViewModel>(context, listen: false).fetch();
    return Future<void>.delayed(const Duration(seconds: 2));
  }

  @override
  void initState() {
    super.initState();
    Provider.of<WhatsappSettingViewModel>(context, listen: false).fetch();
  }

  @override
  Widget build(BuildContext context) {
    wapmodel = Provider.of<WhatsappSettingViewModel>(context);

    return Scaffold(
      backgroundColor: AppColor.pageBgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Whatsapp Setting',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: _pageBody(),
      ),
    );
  }

  Widget _pageBody() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: getContactWidgets(),
          ),
        ),
      ],
    );
  }

  List<Widget> getContactWidgets() {
    List<Widget> widgets = [];
    for (var viewModel in wapmodel!.viewModels) {
      WhatsappSettingModel model = viewModel.model;
      if (model.record?.isNotEmpty ?? false) {
        for (int i = 0; i < model.record!.length; i++) {
          widgets.add(leadRecordList(model, i));
        }
      }
    }
    return widgets;
  }

  Widget leadRecordList(WhatsappSettingModel model, int index) {
    var contact = model.record![index];
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              spreadRadius: 3,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnotherScreen(contact: contact),
                ),
              );
            },
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${contact.name}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textoriconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${contact.phone}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColor.textoriconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // );
  }
}

// ignore: must_be_immutable
class AnotherScreen extends StatefulWidget {
  Record? contact;

  AnotherScreen({super.key, required this.contact});

  @override
  State<AnotherScreen> createState() => _AnotherScreenState();
}

class _AnotherScreenState extends State<AnotherScreen> {
  // late NotchBottomBarController _controller;
  Widget recordDetails(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColor.textoriconColor,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "Not available",
              style: const TextStyle(
                fontSize: 13,
                color: AppColor.textoriconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding getRow(String lable, String name) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 1,
              child: Text(
                lable,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Whatsapp Setting',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [_pageBody(widget.contact)],
          ),
        ),
      ),
    );
  }

  Widget _pageBody(contact) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      getRow(" Name", contact.name),
                      const Divider(),
                      getRow("Bussiness Number", contact?.businessNumberId),
                      const Divider(),
                      getRow("Bussiness Account Id",
                          contact?.whatsappBusinessAccountId),
                      const Divider(),
                      getRow("Phone", contact?.phone),
                      const Divider(),
                      getRow("App Id", contact?.appId),
                      const Divider(),
                      getRow("End Point Url", contact?.endPointUrl),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
