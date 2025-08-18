// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

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

  TemplateSheetHelper(
      {super.key,
      required this.controllers,
      required this.leadName,
      required this.leadNum,
      required this.ledid});

  @override
  State<TemplateSheetHelper> createState() => _TemplateSheetHelperState();
}

class _TemplateSheetHelperState extends State<TemplateSheetHelper> {
  late MessageViewModel msgViewModel;
  bool isChecked = false;
  bool isOtherFileSelected = false;
  String imgToShow = "";
  List<TextEditingController> carousalController = [];
  File? mainContentFile;
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
                _buildTemplateCard(),
                msgViewModel.carousalList.isEmpty
                    ? const SizedBox()
                    : CarousalCard(
                        msgViewModel: msgViewModel,
                        wpleadNum: widget.leadNum,
                        leadId: widget.ledid,
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.navBarIconColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side:
                              const BorderSide(color: AppColor.navBarIconColor),
                        ),
                      ),
                      onPressed: () async {
                        final msgViewModel = Provider.of<MessageViewModel>(
                            context,
                            listen: false);
                        final walletController = Provider.of<WalletController>(
                            context,
                            listen: false);
                        final prefs = await SharedPreferences.getInstance();
                        final phoneNumber = prefs.getString('phoneNumber');
                        final hasWallet =
                            prefs.getBool(SharedPrefsConstants.hasWalletKey) ??
                                false;

                        // 1. Validate file requirements
                        if (_requiresFile(msgViewModel) &&
                            mainContentFile == null) {
                          EasyLoading.showToast(
                              "Please pick a file to send this template");
                          return;
                        }

                        //  2. Debit wallet if available
                        if (hasWallet) walletController.debitWalletBalApiCall();

                        //  3. Validate placeholders
                        // if (!_allFilled(carousalController)) {
                        //   EasyLoading.showToast(
                        //       "Fill the values of all carousel placeholders..");
                        //   return;
                        // }
                        if (!_allFilled(widget.controllers)) {
                          EasyLoading.showToast(
                              "Fill the values of all placeholders..");
                          return;
                        }

                        //  4. Build request body
                        final body = await _buildBody(
                          msgViewModel: msgViewModel,
                          phoneNumber: phoneNumber,
                          hasWallet: hasWallet,
                          walletController: walletController,
                        );

                        debugPrint("send temp api call body::: $body");

                        // ✅ 5. Send API call
                        final response = await msgViewModel.sendTemplateApiCall(
                          tempBody: body,
                          number: phoneNumber,
                        );

                        debugPrint("onValue of send template::: $response");

                        if (response['success'] == true) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text("Send",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
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
    print(
        "msgViewModel.selectedHeade::::::      ${msgViewModel.selectedHeader}");
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xffE3FFC9).withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Body text
            if (msgViewModel.selectedBody != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  msgViewModel.selectedBody!.text ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

            // Placeholder inputs
            buildPlaceholderInputs(widget.controllers),
            const SizedBox(height: 12),

            // Buttons (chips style)
            if (msgViewModel.selectedButtons != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  msgViewModel.selectedButtons!.buttons!.length,
                  (index) {
                    return buildChatButtonTag(
                      msgViewModel.selectedButtons?.buttons?[index].text ?? "",
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Footer
            if (msgViewModel.selectedFooter != null)
              Text(
                msgViewModel.selectedFooter?.text ?? "",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 16),

            // Media preview
            if (msgViewModel.selectedHeader != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: buildMediaWidget(
                        msgViewModel.selectedHeader!.format ?? "",
                        msgViewModel
                                .selectedHeader?.example?.headerHandle?[0] ??
                            "",
                      ),
                    ),
                  ),
                  if (msgViewModel.selectedHeader!.format == "IMAGE" ||
                      msgViewModel.selectedHeader!.format == "VIDEO" ||
                      msgViewModel.selectedHeader!.format == "DOCUMENT")
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          print(
                              "Selected format: ${msgViewModel.selectedHeader!.format}");
                          // final allowedExtensions =
                          //     msgViewModel.selectedHeader!.format == 'IMAGE'
                          //         ? ["jpg", "jpeg", "png"]
                          //         : ["mp4", "mkv", "mov"];

                          final format = msgViewModel.selectedHeader!.format;

                          final allowedExtensions = format == 'IMAGE'
                              ? ["jpg", "jpeg", "png"]
                              : format == 'VIDEO'
                                  ? ["mp4", "mkv", "mov"]
                                  : [
                                      "pdf",
                                      "doc",
                                      "docx",
                                      "xls",
                                      "xlsx",
                                      "ppt",
                                      "pptx"
                                    ];

                          final pickedFile =
                              await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.custom,
                            allowedExtensions: allowedExtensions,
                          );

                          if (pickedFile != null) {
                            EasyLoading.showToast("Picked Successfully");
                            setState(() {
                              mainContentFile =
                                  File(pickedFile.files.first.path!);
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.upload_file,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Pick File",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: AppColor.navBarIconColor,
                        ),
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 14),

            // if (msgViewModel.selectedHeader != null)

            // Checkbox
            Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    activeColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    value: isChecked,
                    onChanged: (bool? value) => setState(() {
                      isChecked = value ?? false;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Send on login user WhatsApp number also",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

    if (msgViewModel.mainBodyParams.isEmpty) {
      // 🔹 Handle file upload if exists
      if (mainContentFile != null && phoneNumber != null) {
        final fileType = _getFileType(mainContentFile!.path);
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
      // 🔹 Merge params with main inputs
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

    // ✅ Safely add file data into parameters
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

  String _getFileType(String path) {
    final ext = p.extension(path).replaceFirst('.', '').toLowerCase();
    if (["jpg", "jpeg", "png"].contains(ext)) return "image";
    if (["mp4", "mkv", "mov"].contains(ext)) return "video";
    if (["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx"].contains(ext))
      return "document";
    return "UNKNOWN";
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

  CarousalCard(
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                height: 380,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedCarousalBody != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            selectedCarousalBody.text ?? "",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                      if (selectedCarousalHeader != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: carousalFiles[index] == null
                              ? buildMediaWidget(
                                  selectedCarousalHeader.format ?? "",
                                  selectedCarousalHeader
                                          .example?.headerHandle?[0] ??
                                      "",
                                  fromCarousal: true,
                                )
                              : selectedCarousalHeader.format == "IMAGE"
                                  ? Image.file(carousalFiles[index]!,
                                      fit: BoxFit.cover)
                                  : Container(
                                      height: 180,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.play_arrow_rounded,
                                            color: Colors.white, size: 40),
                                      ),
                                    ),
                        ),

                      const SizedBox(height: 12),

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

                      const SizedBox(height: 20),

                      // Pick File Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            print(
                                "Selected format: ${selectedCarousalHeader?.format}");
                            final allowedExtensions =
                                selectedCarousalHeader?.format == 'IMAGE'
                                    ? ["jpg", "jpeg", "png"]
                                    : ["mp4", "mkv", "mov"];

                            final pickedFile =
                                await FilePicker.platform.pickFiles(
                              allowMultiple: false,
                              type: FileType.custom,
                              allowedExtensions: allowedExtensions,
                            );

                            if (pickedFile != null) {
                              EasyLoading.showToast("Picked Successfully");
                              setState(() {
                                carousalFiles[index] =
                                    File(pickedFile.files.first.path!);
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.upload_file,
                            size: 20,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Pick File",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: AppColor.navBarIconColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (selectedCarousalFooter?.text != null)
                        Text(
                          selectedCarousalFooter!.text!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCarousal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.navBarIconColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Save Carousel",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
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
                  height: _currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? AppColor.navBarIconColor
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

  Future<void> _saveCarousal() async {
    // Validate text inputs for each carousel
    for (int i = 0; i < allCarousalControllers.length; i++) {
      bool allFilled = allCarousalControllers[i]
          .every((controller) => controller.text.trim().isNotEmpty);
      if (!allFilled) {
        EasyLoading.showToast("Please fill the value of all placeholders");
        return;
      }
    }

    // Validate files for each carousel
    for (int index = 0; index < carousalFiles.length; index++) {
      if (carousalFiles[index] == null) {
        EasyLoading.showToast("Please pick files for all Carousel");
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
