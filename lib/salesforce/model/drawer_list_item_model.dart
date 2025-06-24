class SfDrawerItemModel {
  String? countryCode;
  String? whatsappNumber;
  String? name;
  String? id;
  String? status;
  String? lastMsg;
  int? unreadCount;

  SfDrawerItemModel(
      {this.countryCode,
      this.whatsappNumber,
      this.name,
      this.id,
      this.lastMsg,
      this.status,
      this.unreadCount});

  factory SfDrawerItemModel.fromJson(Map<String, dynamic> json) {
    return SfDrawerItemModel(
        countryCode: json['country_code'] ?? "",
        whatsappNumber: json['whatsapp_number'] ?? "",
        name: json['name'] ?? "",
        status: json['status'],
        id: json['id'],
        lastMsg: json['last_message'],
        unreadCount: json['unread_count']);
  }
}
