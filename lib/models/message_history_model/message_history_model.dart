import 'dart:convert';

import '../../core/models/base_model.dart';
import 'record.dart';

class MessageHistoryModel extends BaseModel {
  bool? success;
  List<Record>? records;

  MessageHistoryModel({this.success, this.records});

  factory MessageHistoryModel.fromMap(Map<String, dynamic> data) {
    return MessageHistoryModel(
      success: data['success'] as bool?,
      records: (data['records'] as List<dynamic>?)
          ?.map((e) => Record.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
  @override
  MessageHistoryModel fromMap(Map<String, dynamic> data) {
    return MessageHistoryModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': records?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [MessageHistoryModel].
  @override
  factory MessageHistoryModel.fromJson(String data) {
    return MessageHistoryModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [MessageHistoryModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
