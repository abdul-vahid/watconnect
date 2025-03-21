import 'dart:convert';

import 'package:whatsapp/core/models/base_model.dart';

import 'result.dart';

class CampaignChartModel extends BaseModel {
  Result? result;

  CampaignChartModel({this.result});

  factory CampaignChartModel.fromMap(Map<String, dynamic> data) {
    return CampaignChartModel(
      result: data['result'] == null
          ? null
          : Result.fromMap(data['result'] as Map<String, dynamic>),
    );
  }
  @override
  CampaignChartModel fromMap(Map<String, dynamic> data) {
    return CampaignChartModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'result': result?.toMap(),
      };

  /// dart:convert
  ///
  /// Parses the string and returns the resulting Json object as [CampaignChartModel].
  @override
  factory CampaignChartModel.fromJson(String data) {
    return CampaignChartModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// dart:convert
  ///
  /// Converts [CampaignChartModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
