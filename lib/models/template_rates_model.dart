class TemplateRateModel {
  String? id;
  String? countryCode;
  String? marketing;
  String? utility;
  String? createdAt;

  TemplateRateModel({
    this.id,
    this.countryCode,
    this.marketing,
    this.utility,
    this.createdAt,
  });

  factory TemplateRateModel.fromJson(Map<String, dynamic> json) {
    return TemplateRateModel(
      id: json['id'] ?? "",
      countryCode: json['country_code'] ?? "",
      marketing: json['marketing'] ?? "",
      utility: json['utility'] ?? "",
      createdAt: json['created_at'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country_code': countryCode,
      'marketing': marketing,
      'utility': utility,
      'created_at': createdAt,
    };
  }
}
