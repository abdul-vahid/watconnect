import 'dart:convert';
import 'package:whatsapp/models/campaign_model/clone_record_model.dart';

import '../../core/models/base_model.dart';

class CampaignCloneModel extends BaseModel {
  bool? success;
  CloneRecord? record;

  CampaignCloneModel({this.success, this.record});

  factory CampaignCloneModel.fromMap(Map<String, dynamic> data) =>
      CampaignCloneModel(
        success: data['success'] as bool?,
        record: data['record'] == null
            ? null
            : CloneRecord.fromMap(data['record'] as Map<String, dynamic>),
      );

  @override
  CampaignCloneModel fromMap(Map<String, dynamic> data) {
    return CampaignCloneModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'record': record?.toMap(),
      };

  @override
  factory CampaignCloneModel.fromJson(String data) {
    return CampaignCloneModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());
}
