import 'dart:convert';

import '../core/models/base_model.dart';

class NewLeadCountModel extends BaseModel {
  String? total;

  NewLeadCountModel({this.total});

  factory NewLeadCountModel.fromMap(Map<String, dynamic> data) {
    return NewLeadCountModel(
      total: data['total']?.toString(),
    );
  }

  @override
  NewLeadCountModel fromMap(Map<String, dynamic> data) {
    return NewLeadCountModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        if (total != null) 'total': total,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [NewLeadCountModel].
  @override
  factory NewLeadCountModel.fromJson(String data) {
    return NewLeadCountModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [NewLeadCountModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
