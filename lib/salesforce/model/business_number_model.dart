class BusinessNumberModel {
  String? isDefault;
  String? whasappSettingNumber;
  String? whasappSettingName;

  BusinessNumberModel({
    this.isDefault,
    this.whasappSettingNumber,
    this.whasappSettingName,
  });

  factory BusinessNumberModel.fromJson(Map<String, dynamic> json) {
    return BusinessNumberModel(
      isDefault: json['Is_Default__c'] ?? "false",
      whasappSettingNumber: json['WhatsApp_Setting__r.Phone__c'] ?? "",
      whasappSettingName: json['WhatsApp_Setting__r.Name'] ?? "",
    );
  }
}
