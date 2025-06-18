class SfCampaignHistoryModel {
  String? errorMsg;
  String? templateName;
  String? readNotReponsed;
  String? isClicked;
  String? deliveryStatus;
  String? whatsAppBusinessNumber;
  String? whatsAppCustomerNumber;
  String? whatsAppCustomerName;
  String? whatsAppCampaignName;
  String? id;

  SfCampaignHistoryModel(
      {this.errorMsg,
      this.templateName,
      this.readNotReponsed,
      this.isClicked,
      this.deliveryStatus,
      this.whatsAppBusinessNumber,
      this.whatsAppCustomerName,
      this.whatsAppCustomerNumber,
      this.whatsAppCampaignName,
      this.id});

  factory SfCampaignHistoryModel.fromJson(Map<String, dynamic> json) {
    return SfCampaignHistoryModel(
      errorMsg: json['error_msg'] ?? "",
      templateName: json['Template_Name'] ?? "",
      readNotReponsed: json['Read_But_Not_Responded__c'] ?? "",
      isClicked: json['Is_Clicked__c'] ?? "",
      deliveryStatus: json['Delivery_Status__c'] ?? "",
      whatsAppBusinessNumber: json['WhatsApp_Business_Number'] ?? "",
      whatsAppCustomerName: json['WhatsApp_Customer_Name'] ?? "",
      whatsAppCustomerNumber: json['WhatsApp_Customer_Number'] ?? "",
      whatsAppCampaignName: json['WhatsApp_Campaign__r.Name'] ?? "",
      id: json['Id'] ?? "",
    );
  }
}
