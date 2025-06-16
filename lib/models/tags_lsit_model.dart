import 'dart:convert';

import 'package:whatsapp/core/models/base_model.dart';

class TagsModel extends BaseModel {
  final bool? success;
  final List<TagRecord>? records;

  TagsModel({this.success, this.records});

  factory TagsModel.fromMap(Map<String, dynamic> data) {
    return TagsModel(
      success: data['success'] as bool?,
      records: (data['records'] as List<dynamic>?)
          ?.map((e) => TagRecord.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  TagsModel fromMap(Map<String, dynamic> data) => TagsModel.fromMap(data);

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': records?.map((e) => e.toMap()).toList(),
      };

  @override
  factory TagsModel.fromJson(String data) =>
      TagsModel.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

class TagRecord {
  final String? id;
  final String? name;
  final bool? status;
  final String? createddate;
  final String? lastmodifieddate;
  final String? createdbyid;
  final String? lastmodifiedbyid;
  final String? firstMessage;
  final List<AutoTagRule>? autoTagRules;

  TagRecord({
    this.id,
    this.name,
    this.status,
    this.createddate,
    this.lastmodifieddate,
    this.createdbyid,
    this.lastmodifiedbyid,
    this.firstMessage,
    this.autoTagRules,
  });

  factory TagRecord.fromMap(Map<String, dynamic> json) {
    return TagRecord(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      createddate: json['createddate'],
      lastmodifieddate: json['lastmodifieddate'],
      createdbyid: json['createdbyid'],
      lastmodifiedbyid: json['lastmodifiedbyid'],
      firstMessage: json['first_message'],
      autoTagRules: (json['auto_tag_rules'] as List<dynamic>?)
              ?.map((v) => AutoTagRule.fromJson(v))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'createddate': createddate,
      'lastmodifieddate': lastmodifieddate,
      'createdbyid': createdbyid,
      'lastmodifiedbyid': lastmodifiedbyid,
      'first_message': firstMessage,
      'auto_tag_rules': autoTagRules?.map((v) => v.toJson()).toList(),
    };
  }

  factory TagRecord.fromJson(String data) =>
      TagRecord.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

class AutoTagRule {
  final String? id;
  final String? tagId;
  final String? keyword;
  final String? matchType;

  const AutoTagRule({
    this.id,
    this.tagId,
    this.keyword,
    this.matchType,
  });

  factory AutoTagRule.fromJson(Map<String, dynamic> json) {
    return AutoTagRule(
      id: json['id'],
      tagId: json['tag_id'],
      keyword: json['keyword'],
      matchType: json['match_type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tag_id': tagId,
        'keyword': keyword,
        'match_type': matchType,
      };
}
