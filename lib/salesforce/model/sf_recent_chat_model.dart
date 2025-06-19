class SfRecentChatModel {
  String? whatsappNumber;
  int? unreadCount;
  String? sObjectName;
  String? recordId;
  String? lastWhatsAppMessage;
  String? fullName;
  Fields? fields;
  DateTime? createdDate;
  String? countryCodeValue;

  SfRecentChatModel({
    this.whatsappNumber,
    this.unreadCount,
    this.sObjectName,
    this.recordId,
    this.lastWhatsAppMessage,
    this.fullName,
    this.fields,
    this.createdDate,
    this.countryCodeValue,
  });

  SfRecentChatModel.fromJson(Map<String, dynamic> json) {
    whatsappNumber = json['whatsappNumber'];
    unreadCount = json['unreadCount'];
    sObjectName = json['sObjectName'];
    recordId = json['recordId'];
    lastWhatsAppMessage = json['lastWhatsAppMessage'];
    fullName = json['fullName'];
    fields = json['fields'] != null ? Fields.fromJson(json['fields']) : null;
    createdDate = json['createdDate'] != null
        ? DateTime.tryParse(json['createdDate'])
        : null;
    countryCodeValue = json['countryCodeValue'];
  }

  Map<String, dynamic> toJson() {
    return {
      'whatsappNumber': whatsappNumber,
      'unreadCount': unreadCount,
      'sObjectName': sObjectName,
      'recordId': recordId,
      'lastWhatsAppMessage': lastWhatsAppMessage,
      'fullName': fullName,
      'fields': fields?.toJson(),
      'createdDate': createdDate?.toIso8601String(),
      'countryCodeValue': countryCodeValue,
    };
  }
}

class Fields {
  String? leadSource;
  String? company;
  String? status;
  String? lastName;
  String? firstName;
  String? countryCode;
  String? whatsAppNumber;

  Fields({
    this.leadSource,
    this.company,
    this.status,
    this.lastName,
    this.firstName,
    this.countryCode,
    this.whatsAppNumber,
  });

  Fields.fromJson(Map<String, dynamic> json) {
    leadSource = json['LeadSource'];
    company = json['Company'];
    status = json['Status'];
    lastName = json['LastName'];
    firstName = json['FirstName'];
    countryCode = json['Country_code__c'];
    whatsAppNumber = json['WhatsApp_Number__c'];
  }

  Map<String, dynamic> toJson() {
    return {
      'LeadSource': leadSource,
      'Company': company,
      'Status': status,
      'LastName': lastName,
      'FirstName': firstName,
      'Country_code__c': countryCode,
      'WhatsApp_Number__c': whatsAppNumber,
    };
  }
}
