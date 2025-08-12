// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/component.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/view_models/message_list_vm.dart';
import 'package:whatsapp/view_models/wallet_controller.dart';
import 'package:whatsapp/views/widgets/whatsapp_chats_widgets.dart/build_media_widget.dart';

class TemplateSheetHelper extends StatefulWidget {
  final List<TextEditingController> controllers;
  String leadName;
  String leadNum;

  TemplateSheetHelper(
      {super.key,
      required this.controllers,
      required this.leadName,
      required this.leadNum});

  @override
  State<TemplateSheetHelper> createState() => _TemplateSheetHelperState();
}

class _TemplateSheetHelperState extends State<TemplateSheetHelper> {
  late MessageViewModel msgViewModel;
  bool isChecked = false;
  bool isOtherFileSelected = false;
  String imgToShow = "";
  List<TextEditingController> carousalController = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    msgViewModel = Provider.of<MessageViewModel>(context, listen: false);

    final text = msgViewModel.selectedBody?.text ?? "";
    imgToShow = _extractImageToShow(msgViewModel);
    final placeholderCount = _countPlaceholders(text);

    widget.controllers.clear();
    widget.controllers.addAll(
      List.generate(placeholderCount, (index) => TextEditingController()),
    );
  }

  String _extractImageToShow(MessageViewModel msgViewModel) {
    final headerExample = msgViewModel.selectedHeader?.example;
    if (headerExample?.headerHandle != null &&
        headerExample!.headerHandle!.isNotEmpty) {
      return headerExample.headerHandle![0];
    }
    return "";
  }

  int _countPlaceholders(String text) {
    final regex = RegExp(r'\{\{\d+\}\}');
    return regex.allMatches(text).length;
  }

  void _scrollToFocused() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .80,
      child: SingleChildScrollView(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeaderRow(),
                const Divider(thickness: 1),
                const SizedBox(height: 5),
                buildPlaceholderInputs(widget.controllers),
                _buildTemplateCard(),
                CarousalCard(msgViewModel: msgViewModel),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        bool hasWallet = prefs.getBool('hasWalletKey') ?? false;
                        WalletController walletController =
                            Provider.of(context, listen: false);
                        if (hasWallet) {
                          walletController.debitWalletBalApiCall();
                        }
                        MessageViewModel msgViewModel =
                            Provider.of(context, listen: false);

                        bool allCarCrtlFilled = carousalController.every(
                            (controller) => controller.text.trim().isNotEmpty);

                        bool allCrtlFilled = widget.controllers.every(
                            (controller) => controller.text.trim().isNotEmpty);
                        if (!allCarCrtlFilled) {
                          EasyLoading.showToast(
                              "Fill the values of all carousel placeholders..");
                          return;
                        }

                        if (!allCrtlFilled) {
                          EasyLoading.showToast(
                              "Fill the values of all placeholders..");
                          return;
                        }

                        Map<String, dynamic> body = {};

                        if (carousalController.isEmpty) {
                          body = {
                            "id": msgViewModel.selectedTempId,
                            "name": msgViewModel.selectedTempName,
                            "contact_name": widget.leadName,
                            "whatsapp_number": widget.leadNum,
                            "amount":
                                hasWallet ? walletController.finalAmount : 0,
                            "parameters": {
                              ...Map.fromEntries(
                                widget.controllers.asMap().entries.map(
                                      (entry) => MapEntry(
                                        "${entry.key + 1}",
                                        entry.value.text.trim(),
                                      ),
                                    ),
                              ),
                              "sendToAdmin": isChecked,
                              "file": null,
                            }
                          };
                        } else {
                          body = {
                            "id": msgViewModel.selectedTempId,
                            "name": msgViewModel.selectedTempName,
                            "contact_name": widget.leadName,
                            "whatsapp_number": widget.leadNum,
                            "amount":
                                hasWallet ? walletController.finalAmount : 0,
                            "parameters": {
                              ...Map.fromEntries(
                                carousalController.asMap().entries.map(
                                      (entry) => MapEntry(
                                        "${entry.key + 1}",
                                        entry.value.text.trim(),
                                      ),
                                    ),
                              ),
                              "sendToAdmin": isChecked,
                              "file": null,
                            },
                            "main": {
                              ...Map.fromEntries(
                                widget.controllers.asMap().entries.map(
                                      (entry) => MapEntry(
                                        "${entry.key + 1}",
                                        entry.value.text.trim(),
                                      ),
                                    ),
                              ),
                            }
                          };
                        }
                        print("send temp api call body:::  $body");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.navBarIconColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side:
                              const BorderSide(color: AppColor.navBarIconColor),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          "Send",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Review Template",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.highlight_remove_outlined,
            color: AppColor.navBarIconColor,
            size: 25,
          ),
        ),
      ],
    );
  }

  Widget buildPlaceholderInputs(List<TextEditingController> controllers) {
    return Column(
      children: List.generate(controllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: controllers[index],
            decoration: InputDecoration(
              labelText: "Enter value for placeholder ${index + 1}",
              border: const OutlineInputBorder(),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTemplateCard() {
    return Card(
      elevation: 5,
      color: const Color(0xffE3FFC9).withOpacity(0.5),
      shadowColor: Colors.black38,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msgViewModel.selectedBody != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(msgViewModel.selectedBody!.text ?? ""),
              ),
            const SizedBox(height: 10),
            if (msgViewModel.selectedButtons != null)
              Wrap(
                spacing: 10,
                children: List.generate(
                  msgViewModel.selectedButtons!.buttons!.length,
                  (index) {
                    return buildChatButtonTag(
                      msgViewModel.selectedButtons?.buttons?[index].text ?? "",
                    );
                  },
                ),
              ),
            const SizedBox(height: 15),
            if (msgViewModel.selectedFooter != null)
              Text(
                msgViewModel.selectedFooter?.text ?? "",
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 15),
            if (msgViewModel.selectedHeader != null)
              buildMediaWidget(msgViewModel.selectedHeader!.format ?? "",
                  msgViewModel.selectedHeader?.example?.headerHandle?[0] ?? ""),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) => setState(() {
                    isChecked = value!;
                  }),
                ),
                const Expanded(
                  child: Text(
                    "Send on login user WhatsApp number also",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildChatButtonTag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey[400],
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: AppColor.navBarIconColor),
    ),
    child: Text(
      text,
      style: const TextStyle(color: AppColor.navBarIconColor),
    ),
  );
}

class CarousalCard extends StatefulWidget {
  final MessageViewModel msgViewModel;

  const CarousalCard({Key? key, required this.msgViewModel}) : super(key: key);

  @override
  _CarousalCardState createState() => _CarousalCardState();
}

class _CarousalCardState extends State<CarousalCard> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  late List<List<TextEditingController>> allCarousalControllers;
  late List<List<String>> allCarousalPlaceholders;

  @override
  void initState() {
    super.initState();
    allCarousalControllers = [];
    allCarousalPlaceholders = [];

    for (var i in widget.msgViewModel.carousalList) {
      Component? selectedCarousalBody = i.components?.firstWhere(
        (e) => e.type == "BODY",
        orElse: () => Component(),
      );

      final placeholders = _getPlaceholders(selectedCarousalBody?.text ?? "");

      allCarousalPlaceholders.add(placeholders);

      allCarousalControllers.add(
        List.generate(
          placeholders.length,
          (_) => TextEditingController(),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var list in allCarousalControllers) {
      for (var c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                autoPlay: false,
                enableInfiniteScroll: false,
                viewportFraction: 1,
                enlargeCenterPage: true,
                height: 360,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
              items:
                  widget.msgViewModel.carousalList.asMap().entries.map((entry) {
                final index = entry.key;
                final i = entry.value;

                Component? selectedCarousalHeader;
                Component? selectedCarousalBody;
                Component? selectedCarousalFooter;
                Component? selectedCarousalButtons;

                for (var e in i.components ?? []) {
                  switch (e.type) {
                    case "HEADER":
                      selectedCarousalHeader = e;
                      break;
                    case "BODY":
                      selectedCarousalBody = e;
                      break;
                    case "FOOTER":
                      selectedCarousalFooter = e;
                      break;
                    case "BUTTONS":
                      selectedCarousalButtons = e;
                      break;
                  }
                }

                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedCarousalHeader != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: buildMediaWidget(
                              selectedCarousalHeader.format ?? "",
                              selectedCarousalHeader
                                      .example?.headerHandle?[0] ??
                                  "",
                              fromCarousal: true,
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (selectedCarousalBody?.text != null)
                          Text(
                            selectedCarousalBody!.text!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        // Placeholder Inputs
                        buildPlaceholderInputs(
                          allCarousalControllers[index],
                          allCarousalPlaceholders[index],
                        ),
                        const SizedBox(height: 12),
                        if (selectedCarousalButtons != null)
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(
                              selectedCarousalButtons.buttons!.length,
                              (btnIndex) {
                                return buildChatButtonTag(
                                  selectedCarousalButtons
                                          ?.buttons?[btnIndex].text ??
                                      "",
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (selectedCarousalFooter?.text != null)
                          Text(
                            selectedCarousalFooter!.text!,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  for (int i = 0; i < allCarousalControllers.length; i++) {
                    bool allFilled = allCarousalControllers[i].every(
                        (controller) => controller.text.trim().isNotEmpty);
                    print("Slide $i all filled: $allFilled");
                    for (var c in allCarousalControllers[i]) {
                      print("Text: ${c.text}");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.navBarIconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: AppColor.navBarIconColor),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    "Save Carousal",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.msgViewModel.carousalList.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: _currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.black87
                        : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPlaceholderInputs(
    List<TextEditingController> controllers,
    List<String> placeholders,
  ) {
    return Column(
      children: List.generate(controllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextField(
            controller: controllers[index],
            decoration: InputDecoration(
              labelText: 'Placeholder ${index + 1}',
              hintText: placeholders[index],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        );
      }),
    );
  }

  List<String> _getPlaceholders(String text) {
    final regex = RegExp(r'\{\{.*?\}\}|\{.*?\}');
    return regex.allMatches(text).map((m) => m.group(0) ?? '').toList();
  }
}
