import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:whatsapp/core/models/base_model.dart';

class AllTagsModel extends BaseModel {
  final bool success;
  final List<TagRecord> records;

  AllTagsModel({
    required this.success,
    required this.records,
  });

  /// ✅ FROM MAP (USE THIS)
  factory AllTagsModel.fromMap(Map<String, dynamic> data) {
    try {
      return AllTagsModel(
        success: data['success'] == true,
        records: (data['records'] as List<dynamic>?)
                ?.map((e) => TagRecord.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e) {
      debugPrint("AllTagsModel error: $e");
      return AllTagsModel(success: false, records: []);
    }
  }

  @override
  AllTagsModel fromMap(Map<String, dynamic> data) =>
      AllTagsModel.fromMap(data);

  /// ❌ REMOVE String-only fromJson
  /// ✅ Replace with dynamic-safe version
  factory AllTagsModel.fromJson(dynamic data) {
    try {
      if (data is String) {
        return AllTagsModel.fromMap(json.decode(data));
      } else if (data is Map<String, dynamic>) {
        return AllTagsModel.fromMap(data);
      } else {
        throw Exception("Invalid data type");
      }
    } catch (e) {
      debugPrint("AllTagsModel fromJson error: $e");
      return AllTagsModel(success: false, records: []);
    }
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': records.map((e) => e.toMap()).toList(),
      };

  String toJson() => json.encode(toMap());
}


class TagRecord {
  final String id;
  final String name;
  final bool status;
  final String createddate;
  final String lastmodifieddate;
  final String createdbyid;
  final String lastmodifiedbyid;
  final String firstMessage;
  final List<AutoTagRule> autoTagRules;

  TagRecord({
    required this.id,
    required this.name,
    required this.status,
    required this.createddate,
    required this.lastmodifieddate,
    required this.createdbyid,
    required this.lastmodifiedbyid,
    required this.firstMessage,
    required this.autoTagRules,
  });

  factory TagRecord.fromMap(Map<String, dynamic> json) {
    try {
      return TagRecord(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        status: json['status'] == true,
        createddate: json['createddate']?.toString() ?? '',
        lastmodifieddate: json['lastmodifieddate']?.toString() ?? '',
        createdbyid: json['createdbyid']?.toString() ?? '',
        lastmodifiedbyid: json['lastmodifiedbyid']?.toString() ?? '',
        firstMessage: json['first_message']?.toString() ?? '',
        autoTagRules: (json['auto_tag_rules'] as List<dynamic>?)
                ?.map((e) =>
                    AutoTagRule.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e) {
      debugPrint("TagRecord error: $e");
      return TagRecord(
        id: '',
        name: '',
        status: false,
        createddate: '',
        lastmodifieddate: '',
        createdbyid: '',
        lastmodifiedbyid: '',
        firstMessage: '',
        autoTagRules: [],
      );
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'status': status,
        'createddate': createddate,
        'lastmodifieddate': lastmodifieddate,
        'createdbyid': createdbyid,
        'lastmodifiedbyid': lastmodifiedbyid,
        'first_message': firstMessage,
        'auto_tag_rules': autoTagRules.map((e) => e.toMap()).toList(),
      };
}



class AutoTagRule {
  final String id;
  final String tagId;
  final String keyword;
  final String matchType;

  const AutoTagRule({
    required this.id,
    required this.tagId,
    required this.keyword,
    required this.matchType,
  });

  factory AutoTagRule.fromMap(Map<String, dynamic> json) {
    try {
      return AutoTagRule(
        id: json['id']?.toString() ?? '',
        tagId: json['tag_id']?.toString() ?? '',
        keyword: json['keyword']?.toString() ?? '',
        matchType: json['match_type']?.toString() ?? '',
      );
    } catch (e) {
      debugPrint("AutoTagRule error: $e");
      return const AutoTagRule(
        id: '',
        tagId: '',
        keyword: '',
        matchType: '',
      );
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tag_id': tagId,
        'keyword': keyword,
        'match_type': matchType,
      };
}