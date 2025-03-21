import 'dart:convert';

import 'package:whatsapp/core/models/base_model.dart';

import 'record.dart';

class UnreadMsgModel extends BaseModel {
  bool? success;
  List<Record>? records;

  UnreadMsgModel({this.success, this.records});

  factory UnreadMsgModel.fromMap(Map<String, dynamic> data) {
    return UnreadMsgModel(
      success: data['success'] as bool?,
      records: (data['records'] as List<dynamic>?)
          ?.map((e) => Record.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
  @override
  UnreadMsgModel fromMap(Map<String, dynamic> data) {
    return UnreadMsgModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': records?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [UnreadMsgModel].
  @override
  factory UnreadMsgModel.fromJson(String data) {
    return UnreadMsgModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [UnreadMsgModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
