// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, must_be_immutable

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/component.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/view_models/message_list_vm.dart';
import 'package:whatsapp/view_models/wallet_controller.dart';
import 'package:whatsapp/views/widgets/whatsapp_chats_widgets.dart/build_media_widget.dart';

class TemplateSheetHelper extends StatefulWidget {
  final List<TextEditingController> controllers;
  String leadName;
  String leadNum;
  String ledid;

  TemplateSheetHelper({
    super.key,
    required this.controllers,
    required this.leadName,
    required this.leadNum,
    required this.ledid,
  });

  @override
  State<TemplateSheetHelper> createState() => _TemplateSheetHelperState();
}

class _TemplateSheetHelperState extends State<TemplateSheetHelper> {
  late MessageViewModel msgViewModel;
  bool isChecked = false;
  bool isOtherFileSelected = false;
  String imgToShow = "";
  bool isSendingTemplate = false;
  List<TextEditingController> carousalController = [];
  File? mainContentFile;

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
    final matches = regex.allMatches(text).map((m) => m.group(0)).toSet();
    return matches.length;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Review Template",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColor.navBarIconColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xffF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tip Card
                    _buildTipCard(),
                    const SizedBox(height: 20),

                    // Template Card
                    _buildTemplateCard(),

                    // Carousel Section
                    if (msgViewModel.carousalList.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      CarousalCard(
                        msgViewModel: msgViewModel,
                        wpleadNum: widget.leadNum,
                        leadId: widget.ledid,
                      ),
                    ],

                    // Send Button
                    const SizedBox(height: 24),
                    _buildSendButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.navBarIconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.navBarIconColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColor.navBarIconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Tip: Write name as a parameter to replace it with the real name of the client.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xffE3FFC9).withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Body Text
            if (msgViewModel.selectedBody != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  msgViewModel.selectedBody!.text ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),

            // Placeholder Inputs
            _buildPlaceholderInputs(widget.controllers),
            const SizedBox(height: 16),

            // Buttons
            if (msgViewModel.selectedButtons != null) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  msgViewModel.selectedButtons!.buttons!.length,
                  (index) => _buildButtonChip(
                    msgViewModel.selectedButtons?.buttons?[index].text ?? "",
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Media Section
            if (msgViewModel.selectedHeader != null) ...[
              _buildMediaSection(),
              const SizedBox(height: 16),
            ],

            // Footer
            if (msgViewModel.selectedFooter != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  msgViewModel.selectedFooter?.text ?? "",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Checkbox
            const SizedBox(height: 16),
            // _buildCheckbox(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderInputs(List<TextEditingController> controllers) {
    return Column(
      children: List.generate(controllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Parameter ${index + 1}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controllers[index],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Enter value for placeholder ${index + 1}",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColor.navBarIconColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildButtonChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.navBarIconColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColor.navBarIconColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColor.navBarIconColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: mainContentFile == null
                      ? buildMediaWidget(
                          msgViewModel.selectedHeader!.format ?? "",
                          msgViewModel
                                  .selectedHeader?.example?.headerHandle?[0] ??
                              "",
                        )
                      : _isImageFile(mainContentFile!.path)
                          ? Image.file(mainContentFile!)
                          : buildMediaWidget(
                              msgViewModel.selectedHeader!.format ?? "",
                              msgViewModel.selectedHeader?.example
                                      ?.headerHandle?[0] ??
                                  "",
                            ),
                ),
              ),
              const SizedBox(height: 12),
              if (msgViewModel.selectedHeader!.format == "IMAGE" ||
                  msgViewModel.selectedHeader!.format == "VIDEO" ||
                  msgViewModel.selectedHeader!.format == "DOCUMENT")
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text("Choose File"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.navBarIconColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              setState(() => isChecked = !isChecked);
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isChecked ? AppColor.navBarIconColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color:
                      isChecked ? AppColor.navBarIconColor : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Expanded(
          //   child: GestureDetector(
          //     onTap: () => setState(() => isChecked = !isChecked),
          //     child: const Text(
          //       "Send on login user WhatsApp number also",
          //       style: TextStyle(
          //         fontSize: 14,
          //         color: Colors.black87,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _sendTemplate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.navBarIconColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: AppColor.navBarIconColor.withOpacity(0.3),
        ),
        child: isSendingTemplate
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Send Template",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final format = msgViewModel.selectedHeader!.format;
    final allowedExtensions = format == 'IMAGE'
        ? ["jpg", "jpeg", "png"]
        : format == 'VIDEO'
            ? ["mp4", "mkv", "mov"]
            : ["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx"];

    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (pickedFile != null) {
      EasyLoading.showToast("File selected successfully");
      setState(() {
        mainContentFile = File(pickedFile.files.first.path!);
      });
    }
  }

  Future<void> _sendTemplate() async {
    setState(() {
      isSendingTemplate = true;
    });

    final msgViewModel = Provider.of<MessageViewModel>(context, listen: false);
    final walletController =
        Provider.of<WalletController>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    final hasWallet = prefs.getBool(SharedPrefsConstants.hasWalletKey) ?? false;

    if (_requiresFile(msgViewModel) && mainContentFile == null) {
      EasyLoading.showToast("Please pick a file to send this template");
      setState(() {
        isSendingTemplate = false;
      });
      return;
    }

    if (hasWallet) walletController.debitWalletBalApiCall();

    if (!_allFilled(widget.controllers)) {
      EasyLoading.showToast("Fill the values of all placeholders..");
      setState(() {
        isSendingTemplate = false;
      });
      return;
    }

    final body = await _buildBody(
      msgViewModel: msgViewModel,
      phoneNumber: phoneNumber,
      hasWallet: hasWallet,
      walletController: walletController,
    );

    debugPrint("send temp api call body::: $body");

    if (body.isEmpty) {
      setState(() {
        isSendingTemplate = false;
      });
      return;
    }

    final response = await msgViewModel.sendTemplateApiCall(
      tempBody: body,
      number: phoneNumber,
    );

    debugPrint("onValue of send template::: $response");

    setState(() {
      isSendingTemplate = false;
    });

    if (response['success'] == true) {
      await msgViewModel.Fetchmsghistorydata(
          leadnumber: widget.leadNum, number: phoneNumber);
      Navigator.pop(context);
    }
  }

  bool _requiresFile(MessageViewModel msgViewModel) {
    final format = msgViewModel.selectedHeader?.format;
    return format == 'IMAGE' || format == 'VIDEO' || format == 'DOCUMENT';
  }

  bool _allFilled(List<TextEditingController> controllers) {
    return controllers.every((c) => c.text.trim().isNotEmpty);
  }

  Future<Map<String, dynamic>> _buildBody({
    required MessageViewModel msgViewModel,
    required String? phoneNumber,
    required bool hasWallet,
    required WalletController walletController,
  }) async {
    Map<String, dynamic> body = {};
    String? fileId;
    String? fileTitle;

    if (msgViewModel.carousalList.isEmpty) {
      if (mainContentFile != null && phoneNumber != null) {
        final uploadResponse =
            await msgViewModel.uploadFile(mainContentFile!, phoneNumber);

        if (uploadResponse == null) {
          debugPrint('Upload failed: No response');
          return {};
        }

        final documentId = jsonDecode(uploadResponse)['id'];
        debugPrint('Uploaded File ID: $documentId');

        final dbResponse = await msgViewModel.uploadFiledb(
            mainContentFile!, phoneNumber, widget.ledid);
        fileId = jsonDecode(dbResponse)['records']?[0]?['id'];
        fileTitle = p.basename(mainContentFile!.path);

        debugPrint("Uploaded to DB. File ID: $fileId");
        print("file id and title after uploading ::: $fileId   $fileTitle");
      }

      body = {
        "id": msgViewModel.selectedTempId,
        "name": msgViewModel.selectedTempName,
        "contact_name": widget.leadName,
        "whatsapp_number": widget.leadNum,
        "amount": hasWallet ? walletController.finalAmount : 0,
        "parameters": <String, dynamic>{
          ..._mapControllers(widget.controllers),
          "sendToAdmin": isChecked,
        },
      };
    } else {
      if (msgViewModel.mainBodyParams["parameters"] == null) {
        EasyLoading.showToast("Save Carousal before sending...");
        return {};
      }

      final Map<String, dynamic> finalParams = {};

      if (msgViewModel.mainBodyParams["parameters"] != null) {
        finalParams.addAll(
          Map<String, dynamic>.from(
            msgViewModel.mainBodyParams["parameters"] as Map,
          ),
        );
      }

      final mainInputs = _mapControllers(widget.controllers);
      if (mainInputs.isNotEmpty) {
        finalParams["main"] = mainInputs;
      }

      body = {
        "id": msgViewModel.selectedTempId,
        "name": msgViewModel.selectedTempName,
        "contact_name": widget.leadName,
        "whatsapp_number": widget.leadNum,
        "amount": hasWallet ? walletController.finalAmount : 0,
        "parameters": finalParams,
      };
    }

    if (mainContentFile != null && fileId != null && fileTitle != null) {
      (body["parameters"] as Map<String, dynamic>).addAll({
        "file": <String, dynamic>{},
        "file_id": fileId,
        "file_title": fileTitle,
      });
    }

    return body;
  }

  Map<String, String> _mapControllers(List<TextEditingController> controllers) {
    return Map.fromEntries(
      controllers.asMap().entries.map(
            (entry) => MapEntry("${entry.key + 1}", entry.value.text.trim()),
          ),
    );
  }

  bool _isImageFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith(".jpg") ||
        ext.endsWith(".jpeg") ||
        ext.endsWith(".png") ||
        ext.endsWith(".gif") ||
        ext.endsWith(".bmp") ||
        ext.endsWith(".webp");
  }
}

Widget buildChatButtonTag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey[200],
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
  final String wpleadNum;
  final String leadId;

  const CarousalCard(
      {Key? key,
      required this.msgViewModel,
      required this.wpleadNum,
      required this.leadId})
      : super(key: key);

  @override
  _CarousalCardState createState() => _CarousalCardState();
}

class _CarousalCardState extends State<CarousalCard> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  late List<List<TextEditingController>> allCarousalControllers;
  late List<List<String>> allCarousalPlaceholders;
  List<File?> carousalFiles = []; // allow null to mean "no file"
  bool isSavingCarousal = false;
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

      carousalFiles.add(null); // prepare slot for this slide
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
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Carousel Section with fixed height
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    autoPlay: false,
                    enableInfiniteScroll: false,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    height: 500,
                    onPageChanged: (index, reason) {
                      setState(() => _currentIndex = index);
                    },
                  ),
                  items: widget.msgViewModel.carousalList
                      .asMap()
                      .entries
                      .map((entry) {
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

                    return Container(
                      padding: const EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        // Added scroll for content
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            if (selectedCarousalBody != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  selectedCarousalBody.text ?? "",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                            // Media - Fixed size
                            if (selectedCarousalHeader != null)
                              Container(
                                height: 220, // Fixed height
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: carousalFiles[index] == null
                                      ? buildMediaWidget(
                                          selectedCarousalHeader.format ?? "",
                                          selectedCarousalHeader
                                                  .example?.headerHandle?[0] ??
                                              "",
                                          fromCarousal: true,
                                        )
                                      : selectedCarousalHeader.format == "IMAGE"
                                          ? Image.file(
                                              carousalFiles[index]!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : Container(
                                              color: Colors.black,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                ),
                              ),

                            // Placeholder Inputs
                            buildPlaceholderInputs(
                              allCarousalControllers[index],
                              allCarousalPlaceholders[index],
                            ),

                            const SizedBox(height: 12),

                            // Buttons - Wrap with limited lines
                            if (selectedCarousalButtons != null)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  selectedCarousalButtons.buttons!.length,
                                  (btnIndex) {
                                    return ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                      ),
                                      child: buildChatButtonTag(
                                        selectedCarousalButtons
                                                ?.buttons?[btnIndex].text ??
                                            "",
                                      ),
                                    );
                                  },
                                ).take(4).toList(),
                              ),

                            const SizedBox(height: 12),

                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final allowedExtensions =
                                        selectedCarousalHeader?.format ==
                                                'IMAGE'
                                            ? ["jpg", "jpeg", "png"]
                                            : ["mp4", "mkv", "mov"];

                                    final pickedFile =
                                        await FilePicker.platform.pickFiles(
                                      allowMultiple: false,
                                      type: FileType.custom,
                                      allowedExtensions: allowedExtensions,
                                    );

                                    if (pickedFile != null) {
                                      EasyLoading.showToast("File selected");
                                      setState(() {
                                        carousalFiles[index] =
                                            File(pickedFile.files.first.path!);
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.navBarIconColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    "Pick Carousal File",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Footer
                            if (selectedCarousalFooter?.text != null)
                              Text(
                                selectedCarousalFooter!.text!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCarousal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.navBarIconColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSavingCarousal
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Save Carousal",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 8),

              // Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.msgViewModel.carousalList.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentIndex == index
                          ? AppColor.navBarIconColor
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCarousal() async {
    setState(() {
      isSavingCarousal = true;
    });
    // Validate text inputs for each carousel
    for (int i = 0; i < allCarousalControllers.length; i++) {
      bool allFilled = allCarousalControllers[i]
          .every((controller) => controller.text.trim().isNotEmpty);
      if (!allFilled) {
        EasyLoading.showToast("Please fill the value of all placeholders");
        setState(() {
          isSavingCarousal = false;
        });
        return;
      }
    }

    // Validate files for each carousel
    for (int index = 0; index < carousalFiles.length; index++) {
      if (carousalFiles[index] == null) {
        EasyLoading.showToast("Please pick files for all Carousel");
        setState(() {
          isSavingCarousal = false;
        });
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');

    Map<String, dynamic> parameters = {}; // Final map to send in API

    for (int index = 0; index < carousalFiles.length; index++) {
      final file = carousalFiles[index]!;
      final allowedExts = ['jpg', 'jpeg', 'png'];
      final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
      final isImg = allowedExts.contains(ext);

      // Upload file
      final uploadResponse =
          await widget.msgViewModel.uploadFile(file, phoneNumber);
      if (uploadResponse == null) {
        debugPrint('Upload failed: No response');
        return;
      }

      final documentId = jsonDecode(uploadResponse)['id'];
      String type = isImg ? "image" : "video";

      // Send to WhatsApp API
      Map<String, dynamic> body = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": widget.wpleadNum,
        "type": type,
        type: {
          "id": documentId,
        },
      };
      await widget.msgViewModel.uploadimagewithdoucmentid(
        bodyy: body,
        number: phoneNumber,
      );

      // Upload to internal DB
      final leadId = widget.leadId;
      final dbResponse =
          await widget.msgViewModel.uploadFiledb(file, phoneNumber, leadId);
      final fileId = jsonDecode(dbResponse)['records']?[0]?['id'];

      // Build map entry for this carousel index
      Map<String, dynamic> carousalData = {};

      // Add placeholder values (1, 2, etc.)
      for (int placeholderIndex = 0;
          placeholderIndex < allCarousalControllers[index].length;
          placeholderIndex++) {
        carousalData["${placeholderIndex + 1}"] =
            allCarousalControllers[index][placeholderIndex].text.trim();
      }

      // Add file details
      carousalData.addAll({
        "file": {},
        // "fileURL": file.path, // Or actual file URL if you have it
        "fileType": type,
        "file_id": fileId ?? "",
        "file_title": p.basename(file.path),
      });

      // Add to parameters map
      parameters["$index"] = carousalData;
    }

    // Final API payload
    Map<String, dynamic> payload = {
      "parameters": parameters,
    };

    widget.msgViewModel.setMainBodyParams(payload);
    setState(() {
      isSavingCarousal = false;
    });

    debugPrint("Final Payload: of the parameters ${jsonEncode(payload)}");
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
