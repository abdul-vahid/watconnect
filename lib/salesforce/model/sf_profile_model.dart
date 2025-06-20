class SfProfileModel {
  bool? isActive;
  String? userRole;
  String? profile;
  String? username;
  String? phone;
  String? email;
  String? name;
  String? userId;

  SfProfileModel({
    this.isActive,
    this.userRole,
    this.profile,
    this.username,
    this.phone,
    this.email,
    this.name,
    this.userId,
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
      userId: json['Id'] ?? "",
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
      'Id': userId,
    };
  }
}
