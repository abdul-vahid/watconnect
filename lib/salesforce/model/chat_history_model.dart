// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:whatsapp/utils/text_sanitizer.dart';

class SfChatHistoryModel {
  static String _safe(dynamic value) => TextSanitizer.sanitize(value?.toString());

  String? name;
  String? button;
  String? templateParams;
  String? templateBody;
  String? templateName;
  String? messageId;
  String? createdDate;
  String? contentType;
  String? attachmentUrl;
  String? messageType;
  String? message;
  String? templateId;
  String? id;
  String? publicUrl;
  String? Delivery_Status;
  String? Error_Msg;

  SfChatHistoryModel({
    this.templateBody,
    this.button,
    this.templateName,
    this.templateParams,
    this.messageId,
    this.createdDate,
    this.name,
    this.contentType,
    this.attachmentUrl,
    this.messageType,
    this.message,
    this.id,
    this.templateId,
    this.publicUrl,
    this.Delivery_Status,
    this.Error_Msg,
  });

  factory SfChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return SfChatHistoryModel(
      name: _safe(json['Name']),
      button: _safe(json['button']),
      templateBody: _safe(json['Tempalate_Body']),
      templateParams: _safe(json["Template_Params__r.Params_value__c"]),
      templateName: _safe(json['Tempalate_Name']),
      messageId: _safe(json['Meta_Message_Id__c']),
      createdDate: _safe(json['CreatedDate']),
      contentType: _safe(json['content_type']),
      attachmentUrl: _safe(json['Attachment_URL__c']),
      messageType: _safe(json['Message_Type__c']),
      message: _safe(json['Message']),
      templateId: _safe(json['templateId']),
      id: _safe(json['Id']),
      publicUrl: _safe(json['Public_Url__c']),
      Delivery_Status: _safe(json['Delivery_Status']),
      Error_Msg: _safe(json['Error_Msg']),
    );
  }

  List<ButtonItem> getParsedButtons() {
    if (button == null || button!.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(button!);
      return decoded.map((e) => ButtonItem.fromJson(e)).toList();
    } catch (e) {
      print("Error decoding button JSON: $e");
      return [];
    }
  }
}

class ButtonItem {
  String? url;
  String? action;

  String? value;
  String? textInput;
  String? template;
  String? label;

  ButtonItem({
    this.url,
    this.value,
    this.action,
    this.textInput,
    this.template,
    this.label,
  });

  factory ButtonItem.fromJson(Map<String, dynamic> json) {
    return ButtonItem(
      url: TextSanitizer.sanitize(json['Url__c']?.toString()),
      value: TextSanitizer.sanitize(json['Value__c']?.toString()),
      action: TextSanitizer.sanitize(json['Action_c']?.toString()),
      textInput: TextSanitizer.sanitize(json['Text_Input__c']?.toString()),
      template:
          TextSanitizer.sanitize(json['WhatsApp_Template__c']?.toString()),
      label: TextSanitizer.sanitize(json['Label__c']?.toString()),
    );
  }
}
