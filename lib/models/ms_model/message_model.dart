import 'dart:convert';

import 'package:whatsapp/core/models/base_model.dart';

import 'record.dart';

class MsModel extends BaseModel {
  bool? success;
  List<Record>? records;

  MsModel({this.success, this.records});

  factory MsModel.fromMap(Map<String, dynamic> data) => MsModel(
        success: data['success'] as bool?,
        records: (data['records'] as List<dynamic>?)
            ?.map((e) => Record.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
  @override
  MsModel fromMap(Map<String, dynamic> data) {
    return MsModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': records?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [MsModel].
  @override
  factory MsModel.fromJson(String data) {
    return MsModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [MsModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
