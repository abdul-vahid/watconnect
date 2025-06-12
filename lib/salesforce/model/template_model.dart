import 'dart:convert';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';

class TemplateModel {
  List<Param>? params;
  String? body;
  String? button;
  String? status;
  String? name;
  List<StoredParam>? storedParameterValues;
  String? templateId;
  String? headerType;
  String? headerText;
  dynamic footerData;
  String? footer;
  String? fileName;
  String? publicUrl;
  String? fileCode;
  String? contentVersionId;
  String? contentDocumentId;
  dynamic codeExpirationMinutes;
  String? category;
  String? businessNumber;
  String? id;

  TemplateModel({
    this.params,
    this.body,
    this.button,
    this.status,
    this.name,
    this.storedParameterValues,
    this.templateId,
    this.headerType,
    this.headerText,
    this.footerData,
    this.footer,
    this.fileName,
    this.publicUrl,
    this.fileCode,
    this.contentVersionId,
    this.contentDocumentId,
    this.codeExpirationMinutes,
    this.category,
    this.businessNumber,
    this.id,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      params: _decodeList<Param>(json['params'], (e) => Param.fromJson(e)),
      button: json['button'] ?? "",
      body: json['Body__c'] ?? "",
      status: json['Status__c'],
      name: json['Name'],
      storedParameterValues: _decodeList<StoredParam>(
        json['Stored_Parameter_Values__c'],
        (e) => StoredParam.fromJson(e),
      ),
      templateId: json['TemplateId__c'],
      headerType: json['Header_Type__c'],
      headerText: json['Header_Text__c'],
      footerData: json['footerData__c'],
      footer: json['Footer__c'],
      fileName: json['fileName__c'],
      publicUrl: json['public url'],
      fileCode: json['fileCode__c'],
      contentVersionId: json['Content_Version_Id__c'],
      contentDocumentId: json['Content_Document_Id__c'],
      codeExpirationMinutes: json['Code_Expiration_Minutes__c'],
      category: json['Category__c'],
      businessNumber: json['Business_Number__c'],
      id: json['Id'],
    );
  }

  List<ButtonItem> getParsedButtons() {
    if (button == null || button!.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(button!);
      final buttons = decoded.map((e) => ButtonItem.fromJson(e)).toList();
      print("Parsed buttons: $buttons");
      return buttons;
    } catch (e) {
      print("Error decoding button JSON: $e");
      return [];
    }
  }

  static List<T>? _decodeList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (source == null) return [];
      final decoded = source is String ? jsonDecode(source) : source;
      if (decoded is List) {
        return decoded
            .map((e) => fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      print('Error decoding list: $e');
    }
    return [];
  }
}

class Param {
  String? documentUrl;
  String? currencyIsoCode;
  String? contentVersionId;
  String? contentType;
  String? contentDocumentId;

  Param({
    this.documentUrl,
    this.currencyIsoCode,
    this.contentVersionId,
    this.contentType,
    this.contentDocumentId,
  });

  factory Param.fromJson(Map<String, dynamic> json) => Param(
        documentUrl: json['Document_url__c'],
        currencyIsoCode: json['CurrencyIsoCode'],
        contentVersionId: json['Content_Version_Id__c'],
        contentType: json['Content_Type__c'],
        contentDocumentId: json['Content_Document_Id__c'],
      );

  Map<String, dynamic> toJson() => {
        'Document_url__c': documentUrl,
        'CurrencyIsoCode': currencyIsoCode,
        'Content_Version_Id__c': contentVersionId,
        'Content_Type__c': contentType,
        'Content_Document_Id__c': contentDocumentId,
      };
}

class StoredParam {
  String? name;
  String? value;

  StoredParam({
    this.name,
    this.value,
  });

  factory StoredParam.fromJson(Map<String, dynamic> json) => StoredParam(
        name: json['name'],
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };
}
