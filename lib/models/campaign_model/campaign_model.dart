import 'dart:convert';

import '../../core/models/base_model.dart';
import 'record.dart';

class CampaignModel extends BaseModel {
  bool? success;
  List<Record>? records;

  // static CampaignModel model;

  CampaignModel({this.success, this.records});

  factory CampaignModel.fromMap(Map<String, dynamic> data) => CampaignModel(
        success: data['success'] as bool?,
        records: (data['records'] as List<dynamic>?)
            ?.map((e) => Record.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
  @override
  CampaignModel fromMap(Map<String, dynamic> data) {
    return CampaignModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': records?.map((e) => e.toMap()).toList(),
      };

  @override
  factory CampaignModel.fromJson(String data) {
    return CampaignModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());
}
