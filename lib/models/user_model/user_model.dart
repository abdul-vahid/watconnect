import 'dart:convert';

import '../../core/models/base_model.dart';
import 'permission.dart';

class UserModel extends BaseModel {
  bool? success;
  String? authToken;
  String? username;
  String? userrole;
  String? companyname;
  String? logourl;
  String? sidebarbgurl;
  List<Permission>? permissions;
  String? id;

  UserModel({
    this.success,
    this.authToken,
    this.username,
    this.userrole,
    this.companyname,
    this.logourl,
    this.sidebarbgurl,
    this.permissions,
    this.id,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) => UserModel(
        success: data['success'] as bool?,
        authToken: data['authToken'] as String?,
        username: (data['username'] as String?)?.trim(), // Trimmed
        userrole: (data['userrole'] as String?)?.trim(), // Trimmed
        companyname: (data['companyname'] as String?)?.trim(), // Trimmed
        logourl: (data['logourl'] as String?)?.trim(), // Trimmed
        sidebarbgurl: data['sidebarbgurl'] as String?,
        id: data['id'] as String?,
        permissions: (data['permissions'] as List<dynamic>?)
            ?.map((e) => Permission.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  BaseModel fromMap(Map<String, dynamic> data) {
    return UserModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'authToken': authToken,
        'username': username?.trim(), // Trimmed
        'userrole': userrole?.trim(), // Trimmed
        'companyname': companyname?.trim(), // Trimmed
        'logourl': logourl?.trim(), // Trimmed
        'sidebarbgurl': sidebarbgurl,
        'id': id,
        'permissions': permissions?.map((e) => e.toMap()).toList(),
      };

  /// Parses the string and returns the resulting JSON object as [UserModel].
  @override
  factory UserModel.fromJson(String data) {
    return UserModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// Converts [UserModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
