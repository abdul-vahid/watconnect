import 'dart:convert';

import 'package:whatsapp/core/models/base_model.dart';

import 'result.dart';

class CampaignCountModel extends BaseModel {
  Result? result;

  CampaignCountModel({this.result});

  factory CampaignCountModel.fromMap(Map<String, dynamic> data) {
    return CampaignCountModel(
      result: data['result'] == null
          ? null
          : Result.fromMap(data['result'] as Map<String, dynamic>),
    );
  }

  @override
  CampaignCountModel fromMap(Map<String, dynamic> data) {
    return CampaignCountModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'result': result?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [CampaignCountModel].
  @override
  factory CampaignCountModel.fromJson(String data) {
    return CampaignCountModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [CampaignCountModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
