// class Member {
//   Member();

//   factory Member.fromJson(Map<String, dynamic> json) {
//
//     throw UnimplementedError('Member.fromJson($json) is not implemented');
//   }

//   Map<String, dynamic> toJson() {
//
//     throw UnimplementedError();
//   }
// }
// ignore: unused_import
import 'dart:convert';

class Member {
  String? id;
  String? name;

  Member({this.id, this.name});

  factory Member.fromMap(Map<String, dynamic> json) => Member(
        id: json['id'] as String?,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
      };

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member.fromMap(json);
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
