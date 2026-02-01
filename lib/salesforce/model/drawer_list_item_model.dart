// class SfDrawerItemModel {
//   String? countryCode;
//   String? whatsappNumber;
//   String? name;
//   String? id;
//   String? status;
//   String? lastMsg;
//   int? lastMsgTime;
//   bool? isPinned;
//   int? unreadCount;

//   SfDrawerItemModel(
//       {this.countryCode,
//       this.whatsappNumber,
//       this.name,
//       this.id,
//       this.lastMsg,
//       this.status,
//       this.isPinned,
//       this.lastMsgTime,
//       this.unreadCount});

//   factory SfDrawerItemModel.fromJson(Map<String, dynamic> json) {
//     return SfDrawerItemModel(
//         countryCode: json['country_code'] ?? "",
//         lastMsgTime: json['lastMessageTime'] ?? 0,
//         whatsappNumber: json['whatsapp_number'] ?? "",
//         name: json['name'] ?? "",
//         isPinned: json['isPinned'] ?? false,
//         status: json['status'] ?? "",
//         id: json['id'] ?? "",
//         lastMsg: json['last_message'] ?? "",
//         unreadCount: json['unread_count']);
//   }
// }


class SfDrawerItemModel {
  String? countryCode;
  String? whatsappNumber;
  String? name;
  String? id;
  String? status;
  String? lastMsg;
  int? lastMsgTime;
  bool? isPinned;
  int? unreadCount;
  
  // ✅ **ADD THESE NEW FIELDS for phone matching**
  String? phone_number;     // For "phone_number" field from API
  String? mobilePhone;      // For "mobilePhone" field from API
  String? whatsAppNumberField; // For "whatsAppNumberField" from API
  String? phone;            // For "phone" field from API
  String? full_number;      // For "full_number" field from API
  String? sObjectName;      // For object type (Lead, Contact, etc.)
  bool? configName;         // For pinned status

  SfDrawerItemModel({
    this.countryCode,
    this.whatsappNumber,
    this.name,
    this.id,
    this.lastMsg,
    this.status,
    this.isPinned,
    this.lastMsgTime,
    this.unreadCount,
    
    // ✅ Add new fields to constructor
    this.phone_number,
    this.mobilePhone,
    this.whatsAppNumberField,
    this.phone,
    this.full_number,
    this.sObjectName,
    this.configName,
  });

  factory SfDrawerItemModel.fromJson(Map<String, dynamic> json) {
    return SfDrawerItemModel(
      countryCode: json['country_code'] ?? "",
      lastMsgTime: json['lastMessageTime'] ?? 0,
      whatsappNumber: json['whatsapp_number'] ?? "",
      name: json['name'] ?? "",
      isPinned: json['isPinned'] ?? false,
      status: json['status'] ?? "",
      id: json['id'] ?? "",
      lastMsg: json['last_message'] ?? "",
      unreadCount: json['unread_count'],
      
      // ✅ **ADD THESE for phone matching**
      phone_number: json['phone_number'] ?? "",
      mobilePhone: json['mobilePhone'] ?? "",
      whatsAppNumberField: json['whatsAppNumberField'] ?? "",
      phone: json['phone'] ?? "",
      full_number: json['full_number'] ?? "",
      sObjectName: json['sObjectName'] ?? "",
      configName: json['configName'] ?? false,
    );
  }
}