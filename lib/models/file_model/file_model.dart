import 'dart:convert';

import 'package:whatsapp/models/file_model/datum.dart';

import '../../../core/models/base_model.dart';

class FileModel extends BaseModel {
  bool? success;
  List<Datum>? data;

  FileModel({this.success, this.data});

  factory FileModel.fromMap(Map<String, dynamic> data) => FileModel(
        success: data['success'] as bool?,
        data: (data['data'] as List<dynamic>?)
            ?.map((e) => Datum.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  FileModel fromMap(Map<String, dynamic> data) {
    return FileModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'data': data?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [FileModel].
  @override
  factory FileModel.fromJson(String data) {
    return FileModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [FileModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
