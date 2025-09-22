class SfCallHistoryModel {
  String? whatsAppNumber;
  String? businessNum;
  String? startTime;
  String? name;
  String? event;
  String? endTime;
  int? duration;
  String? callStatus;
  String? id;
  String? statusC;

  SfCallHistoryModel({
    this.whatsAppNumber,
    this.businessNum,
    this.startTime,
    this.name,
    this.event,
    this.endTime,
    this.duration,
    this.callStatus,
    this.id,
    this.statusC,
  });

  factory SfCallHistoryModel.fromJson(Map<String, dynamic> json) {
    return SfCallHistoryModel(
      whatsAppNumber: json['WatConnect__WhatsApp_Number__c'] ?? "",
      businessNum: json['WatConnect__WhatsApp_Bussiness_Number__c'] ?? "",
      startTime: json['WatConnect__Start_Time__c'] ?? "",
      name: json['Name'] ?? "",
      event: json['WatConnect__Event__c'] ?? "",
      endTime: json['WatConnect__End_Time__c'] ?? "",
      duration: json['WatConnect__Duration__c'] ?? 0,
      callStatus: json['WatConnect__Call_Status__c'] ?? "",
      id: json['Id'] ?? "",
      statusC: json['WatConnect__Status__c'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "WatConnect__WhatsApp_Number__c": whatsAppNumber,
      "WatConnect__WhatsApp_Bussiness_Number__c": businessNum,
      "WatConnect__Start_Time__c": startTime,
      "Name": name,
      "WatConnect__Event__c": event,
      "WatConnect__End_Time__c": endTime,
      "WatConnect__Duration__c": duration,
      "WatConnect__Call_Status__c": callStatus,
      "Id": id,
      "WatConnect__Status__c": statusC,
    };
  }
}
