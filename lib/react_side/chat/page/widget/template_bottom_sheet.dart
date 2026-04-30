import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/react_side/chat/controller/chat_controller.dart';
import 'package:whatsapp/react_side/template/controller/whatsapp_template_controller.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:whatsapp/views/widgets/review_edit_temp_sheet.dart';

class TemplateBottomSheet {
  static Future<void> show({
    required BuildContext context,
    required String leadName,
    required String leadNumber,
    required String leadId,
  }) async {
    final ctrl2 = context.read<WhatsappTemplateController>();

    List<String> templateCategories = [
      'All Categories',
      'UTILITY',
      'MARKETING',
    ];

    String? selectedCategory;
    String? selectedTemplateName;
    List<String> templateNames = [];
    List<TextEditingController> controllers = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Category And Template"),

                  /// CATEGORY DROPDOWN
                  AppUtils.getDropdown(
                    'Select Category',
                    data: templateCategories,
                    value: selectedCategory,
                    onChanged: (val) {
                      setState(() {
                        selectedCategory = val;
                        selectedTemplateName = null;
                        templateNames = [];

                        if (selectedCategory != null) {
                          if (selectedCategory != 'All Categories') {
                            templateNames = ctrl2.approvedTemplatedList
                                .map((e) => e.name ?? '')
                                .toSet()
                                .toList();
                          } else {
                            ctrl2.getApprovedTemplates();
                          }
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  AppUtils.getDropdown(
                    'Select Template Name',
                    data: templateNames,
                    value: selectedTemplateName,
                    onChanged: (val) {
                      setState(() {
                        selectedTemplateName = val;
                      });

                      _setSelectedTemplate(context, selectedTemplateName);
                    },
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      if (selectedTemplateName == null) {
                        EasyLoading.showToast("Select Template Name");
                        return;
                      }

                      final msgVM = context.read<ChatController>();
                      msgVM.setMainBodyParams({});

                      Navigator.pop(context);

                      /// OPEN TEMPLATE EDIT SHEET
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => TemplateSheetHelper(
                          controllers: controllers,
                          leadName: leadName,
                          leadNum: leadNumber,
                          ledid: leadId,
                        ),
                      ).then((onValue){

                        
                      });
                    },
                    child: const Text("Send"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// TEMPLATE SELECTION LOGIC
  static void _setSelectedTemplate(
      BuildContext context, String? selectedTemplateName) {
    final templateCtrl = context.read<WhatsappTemplateController>();
    final msgVM = context.read<ChatController>();

    for (var record in templateCtrl.approvedTemplatedList) {
      if (record.status == "APPROVED" &&
          selectedTemplateName == record.name) {
        msgVM.setSelectedTempId(record.id);
        msgVM.setSelectedTempName(record.name);

        for (var e in record.components ?? []) {
          switch (e.type) {
            case "HEADER":
              msgVM.setSelectedHeader(e);
              break;
            case "BODY":
              msgVM.setSelectedBody(e);
              break;
            case "FOOTER":
              msgVM.setSelectedFooter(e);
              break;
            case "BUTTONS":
              msgVM.setSelectedButton(e);
              break;
          }
        }
        return;
      }
    }
  }
}