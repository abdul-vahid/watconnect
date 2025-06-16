class SfCampaignModel {
  String? id;
  String? status;
  String? createdDate;
  String? read;
  String? delivered;
  String? sent;
  String? totalResponse;
  String? isExecuted;
  String? totalDelivered;
  String? startDateTime;
  String? bussinessNumber;
  String? templateName;
  String? name;

  SfCampaignModel({
    this.id,
    this.status,
    this.createdDate,
    this.read,
    this.delivered,
    this.sent,
    this.totalResponse,
    this.isExecuted,
    this.totalDelivered,
    this.startDateTime,
    this.bussinessNumber,
    this.templateName,
    this.name,
  });

  factory SfCampaignModel.fromJson(Map<String, dynamic> json) {
    return SfCampaignModel(
      id: json['Id'],
      status: json['Status'],
      createdDate: json['Created_Date__c'],
      read: json['Read__c'],
      delivered: json['Delivered__c'],
      sent: json['Sent__c'],
      totalResponse: json['Total_Response__c'],
      isExecuted: json['Is_Executed__c'],
      totalDelivered: json['Total_Delivered__c'],
      startDateTime: json['Start_Date_Time__c'],
      bussinessNumber: json['Bussiness_Number__c'],
      templateName: json['Template_Name__c'],
      name: json['Name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Status': status,
      'Created_Date__c': createdDate,
      'Read__c': read,
      'Delivered__c': delivered,
      'Sent__c': sent,
      'Total_Response__c': totalResponse,
      'Is_Executed__c': isExecuted,
      'Total_Delivered__c': totalDelivered,
      'Start_Date_Time__c': startDateTime,
      'Bussiness_Number__c': bussinessNumber,
      'Template_Name__c': templateName,
      'Name': name,
    };
  }
}
