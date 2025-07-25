// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
import 'package:whatsapp/salesforce/controller/template_controller.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';

class SfAddCampScreen extends StatefulWidget {
  const SfAddCampScreen({super.key});

  @override
  State<SfAddCampScreen> createState() => _SfAddCampScreenState();
}

class _SfAddCampScreenState extends State<SfAddCampScreen> {
  final GlobalKey<FormState> _addCampFormKey = GlobalKey<FormState>();

  TextEditingController campName = TextEditingController();
  TextEditingController campDesc = TextEditingController();
  TextEditingController fileNameController = TextEditingController();
  TextEditingController templateController = TextEditingController();

  File? image;
  File? csvFile;
  XFile? pickedFile;
  String? base64Img;

  PlatformFile? file;

  @override
  void initState() {
    TemplateController templateController = Provider.of(context, listen: false);

    templateController.resetController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        // decoration: InputDecoration(border: Border.all(12)),

        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            // First button (Submit/Update)
            Expanded(
              child: InkWell(
                onTap: () {
                  addCampaignApiCall();
                },
                child: Consumer<SfcampaignController>(
                    builder: (context, campCntroller, child) {
                  return Container(
                    height: 45,
                    decoration: BoxDecoration(
                        color: AppColor.navBarIconColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: campCntroller.addCampLoader
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
        title: const Text(
          "Add Campaign",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _addCampFormKey,
            child: Consumer<TemplateController>(
                builder: (context, tempCtrl, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: AppColor.navBarIconColor,
                        borderRadius: BorderRadius.circular(08)),
                    height: 40,
                    width: double.infinity,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Campaign Information',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Campaign Name'),
                  const SizedBox(height: 5),
                  AppUtils.getTextFormField(
                    'Enter Campaign Name',
                    controller: campName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide Campaign Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text('Campaign Description'),
                  const SizedBox(height: 5),
                  AppUtils.getTextFormField(
                    'Enter Campaign Description',
                    controller: campDesc,
                    maxLines: 2,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide Campaign Description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text('Template'),
                      const SizedBox(
                        width: 10,
                      ),
                      tempCtrl.getTempLoader
                          ? const SizedBox(
                              height: 10,
                              width: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ))
                          : const SizedBox()
                    ],
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    readOnly: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please choose Template';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(08),
                      ),
                      hintText: 'Select Template',
                    ),
                    controller: tempCtrl.campTempController,
                    onTap: () async {
                      if (tempCtrl.getTempLoader) {
                      } else {
                        tempCtrl.setSelectedTemp(null);
                        tempCtrl.setSelectedTempName("Select");

                        // selectedCategory = "ALL";
                        tempCtrl.setSeletcedTempCate("ALL");
                        await tempCtrl.getTemplateApiCall(
                            category: tempCtrl.selectedTempCategory);
                        TemplatebottomSheetShow(context, isFromCamp: true);
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text('Upload CSV'),
                  const SizedBox(height: 5),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please choose CSV to upload';
                      }
                      return null;
                    },
                    controller: fileNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(08),
                      ),
                      hintText: 'Choose File',
                      suffixIcon: const Icon(Icons.add),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        allowMultiple: false,
                        type: FileType.custom,
                        allowedExtensions: ['csv'],
                      );

                      result == null
                          ? const Text(
                              'No File Selected',
                              style: TextStyle(color: Colors.black),
                            )
                          : file = result.files.first;

                      csvFile = File(file!.path.toString());

                      final convertBytes =
                          File(file!.path.toString()).readAsBytesSync();
                      base64Img = base64Encode(convertBytes);
                      String fileName = file!.path.toString().split('/').last;
                      fileNameController.text = fileName;

                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                      onTap: () async {
                        downloadCSV(context);
                      },
                      child: Container(
                        // width: 180,
                        decoration: BoxDecoration(
                            color: AppColor.navBarIconColor,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                            child: Text(
                              "Download Sample CSV",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> downloadCSV(BuildContext context) async {
    List<List<dynamic>> rows = [
      ["Name", "Country Code", "Number"],
      ["John", "+91", "XXXXXXXXXX"]
    ];
    String csv = const ListToCsvConverter().convert(rows);

    final Directory downloadsDir = await getApplicationDocumentsDirectory();

    final String downloadsPath =
        downloadsDir.path.replaceAll("Android/data", "Download");
    final file = File('$downloadsPath/sample.csv');
    await file.create(recursive: true);
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("CSV saved"),
        action: SnackBarAction(
          label: "Open",
          onPressed: () {
            OpenFilex.open(file.path);
          },
        ),
      ),
    );
  }

  Future<void> addCampaignApiCall() async {
    if (_addCampFormKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final busNum =
          prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      TemplateController templateController =
          Provider.of(context, listen: false);

      var paramToSend =
          templateController.buildParamsJson(templateController.tempParamsList);

      Map<String, dynamic> body = {
        "name": campName.text.trim(),
        "businessNumber": busNum,
        "WhatsAppTemplate": templateController.selectedTemplate?.id ?? "",
        "description": campDesc.text.trim(),
        "FileContentBase64": "TmFtZSxQaG9uZQpKb2huIERvZSw5ODc2NTQzMjIK",
        "FileName": fileNameController.text.trim(),
        "params": templateController.tempParamsList.isEmpty ? [] : paramToSend
      };

      List addCampList = [];
      addCampList.add(body);

      // SfcampaignController sfcampaignController =
      //     Provider.of(context, listen: false);

      // sfcampaignController.sfAddCampaignCall(addCampList).then((onValue) {
      // Navigator.pop(context);
      // });

      // print("Sf add camp body::::::::: ${jsonEncode(body)}");
    }
  }
}
