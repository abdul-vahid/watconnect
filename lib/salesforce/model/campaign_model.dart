class SfCampaignModel {
  String? id;
  String? totalRead;
  String? totalFail;
  String? whatsAppTemplate;
  String? whatsAppCustomerNo;
  String? whatsAppObjConfigration;
  String? responseRate;
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
    this.totalRead,
    this.responseRate,
    this.totalFail,
    this.whatsAppTemplate,
    this.status,
    this.whatsAppObjConfigration,
    this.whatsAppCustomerNo,
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
      responseRate: json['Response_Rate__c'],
      totalFail: json['Total_Failed__c'],
      totalRead: json['Total_Read__c'],
      whatsAppTemplate: json['WhatsApp_Template__c'],
      whatsAppObjConfigration: json['WhatsApp_Object_Configuration__c'],
      whatsAppCustomerNo: json['WhatsApp_Customer_Number__c'],
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
