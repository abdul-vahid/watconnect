class SfProfileModel {
  bool? isActive;
  String? userRole;
  String? profile;
  String? username;
  String? phone;
  String? email;
  String? name;
  String? id;

  SfProfileModel({
    this.isActive,
    this.userRole,
    this.profile,
    this.username,
    this.phone,
    this.email,
    this.name,
    this.id,
  });

  factory SfProfileModel.fromJson(Map<String, dynamic> json) {
    return SfProfileModel(
      isActive: json['IsActive'] ?? true,
      userRole: json['UserRole'] ?? "",
      profile: json['Profile'] ?? "",
      username: json['Username'] ?? "",
      phone: json['Phone'] ?? "",
      email: json['Email'] ?? "",
      name: json['Name'] ?? "",
      id: json['Id'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IsActive': isActive,
      'UserRole': userRole,
      'Profile': profile,
      'Username': username,
      'Phone': phone,
      'Email': email,
      'Name': name,
      'Id': id,
    };
  }
}
