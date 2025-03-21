import 'dart:convert';

import 'package:whatsapp/core/models/base_model.dart';

class AutoResponseModel extends BaseModel {
  String? total;

  AutoResponseModel({this.total});

  factory AutoResponseModel.fromMap(Map<String, dynamic> data) {
    return AutoResponseModel(
      total: data['total'] as String?,
    );
  }

  @override
  AutoResponseModel fromMap(Map<String, dynamic> data) {
    return AutoResponseModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'total': total,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [AutoResponseModel].
  @override
  factory AutoResponseModel.fromJson(String data) {
    return AutoResponseModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [AutoResponseModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
