import 'dart:convert';

import '../core/models/base_model.dart';

class GetUser extends BaseModel {
  String? id;
  String? email;
  String? firstname;
  String? lastname;
  String? userrole;
  String? phone;
  bool? isactive;
  String? managerid;
  String? managername;

  GetUser({
    this.id,
    this.email,
    this.firstname,
    this.lastname,
    this.userrole,
    this.phone,
    this.isactive,
    this.managerid,
    this.managername,
  });

  factory GetUser.fromMap(Map<String, dynamic> data) => GetUser(
        id: data['id']?.toString(),
        email: data['email']?.toString(),
        firstname: data['firstname']?.toString(),
        lastname: data['lastname']?.toString(),
        userrole: data['userrole']?.toString(),
        phone: data['phone']?.toString(),
        isactive: data['isactive']?.toString().contains("true"),
        managerid: data['managerid']?.toString(),
        managername: data['managername']?.toString(),
      );
  @override
  GetUser fromMap(Map<String, dynamic> data) {
    return GetUser.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        if (email != null) 'email': email,
        if (firstname != null) 'firstname': firstname,
        if (lastname != null) 'lastname': lastname,
        if (userrole != null) 'userrole': userrole,
        if (phone != null) 'phone': phone,
        if (isactive != null) 'isactive': isactive,
        if (managerid != null) 'managerid': managerid,
        if (managername != null) 'managername': managername,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [GetUser].
  @override
  factory GetUser.fromJson(String data) {
    return GetUser.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [GetUser] to a JSON string.
  String toJson() => json.encode(toMap());
}
