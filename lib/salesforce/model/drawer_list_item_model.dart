class SfDrawerItemModel {
  String? countryCode;
  String? whatsappNumber;
  String? name;
  String? id;

  SfDrawerItemModel({
    this.countryCode,
    this.whatsappNumber,
    this.name,
    this.id,
  });

  factory SfDrawerItemModel.fromJson(Map<String, dynamic> json) {
    return SfDrawerItemModel(
      countryCode: json['country_code'] ?? "",
      whatsappNumber: json['whatsapp_number'] ?? "",
      name: json['name'] ?? "",
      id: json['id'],
    );
  }
}
