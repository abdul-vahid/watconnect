import 'dart:convert';

class SfChatHistoryModel {
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

  SfChatHistoryModel(
      {this.templateBody,
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
      this.publicUrl});

  factory SfChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return SfChatHistoryModel(
        name: json['Name'] ?? "",
        button: json['button'] ?? "",
        templateBody: json['Tempalate_Body'] ?? "",
        templateParams: json["Template_Params__r.Params_value__c"] ?? "",
        templateName: json['Tempalate_Name'] ?? "",
        messageId: json['Meta_Message_Id__c'] ?? "",
        createdDate: json['CreatedDate'] ?? "",
        contentType: json['content_type'] ?? "",
        attachmentUrl: json['Attachment_URL__c'] ?? "",
        messageType: json['Message_Type__c'] ?? "",
        message: json['Message'] ?? "",
        templateId: json['templateId'] ?? "",
        id: json['Id'] ?? "",
        publicUrl: json['Public_Url__c'] ?? "");
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
      url: json['Url__c'] ?? "",
      value: json['Value__c'] ?? "",
      action: json['Action_c'] ?? "",
      textInput: json['Text_Input__c'] ?? "",
      template: json['WhatsApp_Template__c'] ?? "",
      label: json['Label__c'] ?? "",
    );
  }
}
