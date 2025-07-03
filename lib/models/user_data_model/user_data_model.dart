import 'dart:convert';
import 'package:whatsapp/core/models/base_model.dart';

class UserDataModel extends BaseModel {
  String? id;
  String? username;
  String? managername;
  String? managerid;
  String? firstname;
  String? lastname;
  String? email;
  String? userrole;
  String? phone;
  bool? isactive;
  String? password;
  String? country_code;
  String? whatsappNumber;
  List<String>? whatsapp_settings;

  UserDataModel({
    this.id,
    this.username,
    this.managername,
    this.managerid,
    this.firstname,
    this.lastname,
    this.email,
    this.password,
    this.userrole,
    this.phone,
    this.isactive,
    this.country_code,
    this.whatsappNumber,
    this.whatsapp_settings,
  });

  factory UserDataModel.fromMap(Map<String, dynamic> data) => UserDataModel(
        id: data['id'] as String?,
        username: data['username'] as String?,
        managername: data['managername'] as String?,
        managerid: data['managerid'] as String?,
        firstname: data['firstname'] as String?,
        lastname: data['lastname'] as String?,
        email: data['email'] as String?,
        password: data['password'] as String?,
        userrole: data['userrole'] as String?,
        phone: data['phone'] as String?,
        isactive: data['isactive'] as bool?,
        country_code: data['country_code'] as String?,
        whatsappNumber: data['whatsapp_number'] as String?,
        whatsapp_settings: (data['whatsapp_settings'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  @override
  UserDataModel fromMap(Map<String, dynamic> data) {
    return UserDataModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'username': username,
      'managername': managername,
      'managerid': managerid,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'userrole': userrole,
      'phone': phone,
      'isactive': isactive,
      'country_code': country_code,
      'whatsapp_number': whatsappNumber,
      'whatsapp_settings': whatsapp_settings ?? [],
    };

    if (password != null) {
      map['password'] = password;
    }

    return map;
  }

  @override
  factory UserDataModel.fromJson(String data) {
    return UserDataModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());
}
