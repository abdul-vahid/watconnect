import 'dart:convert';

import '../../core/models/base_model.dart';
import 'record.dart';

class GroupsModel extends BaseModel {
  bool? success;
  List<Record>? records;

  GroupsModel({this.success, this.records});

  factory GroupsModel.fromMap(Map<String, dynamic> data) => GroupsModel(
        success: data['success'] as bool?,
        records: (data['records'] as List<dynamic>?)
            ?.map((e) => Record.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
  @override
  GroupsModel fromMap(Map<String, dynamic> data) {
    return GroupsModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': records?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [GroupsModel].
  @override
  factory GroupsModel.fromJson(String data) {
    return GroupsModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [GroupsModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
