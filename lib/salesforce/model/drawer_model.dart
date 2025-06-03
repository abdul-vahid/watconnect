class SfDrawerModel {
  String? whatsAppNumberField;
  String? sObjectName;
  String? lastNameFieldAPIName;
  bool? isFullName;
  bool? isDefaultLeadObject;
  String? fullNameFieldAPIName;
  String? firstNameFieldAPIName;
  List<FieldConfigModel>? fieldConfigModels;
  String? countryCodeField;
  String? configName;
  String? configId;

  SfDrawerModel({
    this.whatsAppNumberField,
    this.sObjectName,
    this.lastNameFieldAPIName,
    this.isFullName,
    this.isDefaultLeadObject,
    this.fullNameFieldAPIName,
    this.firstNameFieldAPIName,
    this.fieldConfigModels,
    this.countryCodeField,
    this.configName,
    this.configId,
  });

  factory SfDrawerModel.fromJson(Map<String, dynamic> json) {
    return SfDrawerModel(
      whatsAppNumberField: json['whatsAppNumberField'] ?? "",
      sObjectName: json['sObjectName'] ?? "",
      lastNameFieldAPIName: json['lastNameFieldAPIName'] ?? "",
      isFullName: json['isFullName'],
      isDefaultLeadObject: json['isDefaultLeadObject'],
      fullNameFieldAPIName: json['fullNameFieldAPIName'] ?? "",
      firstNameFieldAPIName: json['firstNameFieldAPIName'] ?? "",
      fieldConfigModels: (json['fieldConfigModels'] as List<dynamic>?)
          ?.map((e) => FieldConfigModel.fromJson(e))
          .toList(),
      countryCodeField: json['countryCodeField'] ?? "",
      configName: json['configName'] ?? "",
      configId: json['configId'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whatsAppNumberField': whatsAppNumberField,
      'sObjectName': sObjectName,
      'lastNameFieldAPIName': lastNameFieldAPIName,
      'isFullName': isFullName,
      'isDefaultLeadObject': isDefaultLeadObject,
      'fullNameFieldAPIName': fullNameFieldAPIName,
      'firstNameFieldAPIName': firstNameFieldAPIName,
      'fieldConfigModels': fieldConfigModels?.map((e) => e.toJson()).toList(),
      'countryCodeField': countryCodeField,
      'configName': configName,
      'configId': configId,
    };
  }
}

class FieldConfigModel {
  String? fieldDefaultValue;
  String? fieldAPIName;

  FieldConfigModel({
    this.fieldDefaultValue,
    this.fieldAPIName,
  });

  factory FieldConfigModel.fromJson(Map<String, dynamic> json) {
    return FieldConfigModel(
      fieldDefaultValue: json['fieldDefaultValue'] ?? "",
      fieldAPIName: json['fieldAPIName'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldDefaultValue': fieldDefaultValue,
      'fieldAPIName': fieldAPIName,
    };
  }
}
