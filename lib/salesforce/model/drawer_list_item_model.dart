class SfDrawerItemModel {
  String? countryCode;
  String? whatsappNumber;
  String? name;
  String? id;
  String? lastMsg;

  SfDrawerItemModel(
      {this.countryCode,
      this.whatsappNumber,
      this.name,
      this.id,
      this.lastMsg});

  factory SfDrawerItemModel.fromJson(Map<String, dynamic> json) {
    return SfDrawerItemModel(
        countryCode: json['country_code'] ?? "",
        whatsappNumber: json['whatsapp_number'] ?? "",
        name: json['name'] ?? "",
        id: json['id'],
        lastMsg: json['last_message']);
  }
}
