import 'dart:convert';

import 'member.dart';

class Record {
  String? id;
  String? name;
  bool? status;
  DateTime? createddate;
  List<Member>? members;

  Record({this.id, this.name, this.status, this.createddate, this.members});

  factory Record.fromMap(Map<String, dynamic> data) => Record(
        id: data['id'] as String?,
        name: data['name'] as String?,
        status: data['status'] as bool?,
        createddate: data['createddate'] == null
            ? null
            : DateTime.parse(data['createddate'] as String),
        members: (data['members'] as List<dynamic>?)
            ?.map((e) => Member.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'status': status,
        'createddate': createddate?.toIso8601String(),
        'members': members?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Record].
  factory Record.fromJson(String data) {
    return Record.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Record] to a JSON string.
  String toJson() => json.encode(toMap());
}
