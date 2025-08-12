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

  SfCallHistoryModel(
      {this.whatsAppNumber,
      this.businessNum,
      this.startTime,
      this.name,
      this.event,
      this.endTime,
      this.duration,
      this.callStatus,
      this.id,
      this.statusC});

  factory SfCallHistoryModel.fromJson(Map<String, dynamic> json) {
    return SfCallHistoryModel(
        whatsAppNumber: json['WhatsApp_Number__c'] ?? "",
        businessNum: json['WhatsApp_Bussiness_Number__c'] ?? "",
        startTime: json['Start_Time__c'] ?? "",
        name: json['Name'],
        event: json['Event__c'],
        endTime: json['End_Time__c'] ?? "",
        duration: json['Duration__c'] ?? 0,
        callStatus: json['Call_Status__c'] ?? "",
        id: json['Id'] ?? "",
        statusC: json['Status__c'] ?? "");
  }
}
