import 'dart:convert';

import '../core/models/base_model.dart';

class CampaigndetailModel extends BaseModel {
  String? id;
  String? name;
  String? type;
  String? status;
  DateTime? startDate;
  String? templateName;
  DateTime? createddate;
  DateTime? lastmodifieddate;
  String? createdbyid;
  String? lastmodifiedbyid;
  String? groupIds;
  String? businessNumber;

  CampaigndetailModel({
    this.id,
    this.name,
    this.type,
    this.status,
    this.startDate,
    this.templateName,
    this.createddate,
    this.lastmodifieddate,
    this.createdbyid,
    this.lastmodifiedbyid,
    this.groupIds,
    this.businessNumber,
  });

  factory CampaigndetailModel.fromMap(Map<String, dynamic> data) {
    return CampaigndetailModel(
      id: data['id'] as String?,
      name: data['name'] as String?,
      type: data['type'] as String?,
      status: data['status'] as String?,
      startDate: data['start_date'] == null
          ? null
          : DateTime.parse(data['start_date'] as String),
      templateName: data['template_name'] as String?,
      createddate: data['createddate'] == null
          ? null
          : DateTime.parse(data['createddate'] as String),
      lastmodifieddate: data['lastmodifieddate'] == null
          ? null
          : DateTime.parse(data['lastmodifieddate'] as String),
      createdbyid: data['createdbyid'] as String?,
      lastmodifiedbyid: data['lastmodifiedbyid'] as String?,
      groupIds: data['group_ids'] as String?,
      businessNumber: data['business_number'] as String?,
    );
  }
  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'status': status,
        'start_date': startDate?.toIso8601String(),
        'template_name': templateName,
        'createddate': createddate?.toIso8601String(),
        'lastmodifieddate': lastmodifieddate?.toIso8601String(),
        'createdbyid': createdbyid,
        'lastmodifiedbyid': lastmodifiedbyid,
        'group_ids': groupIds,
        'business_number': businessNumber,
      };
  @override
  CampaigndetailModel fromMap(Map<String, dynamic> data) {
    return CampaigndetailModel.fromMap(data);
  }

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [CampaigndetailModel].
  @override
  factory CampaigndetailModel.fromJson(String data) {
    return CampaigndetailModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [CampaigndetailModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
