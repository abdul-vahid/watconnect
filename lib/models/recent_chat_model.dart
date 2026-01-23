import 'dart:convert';

import '../core/models/base_model.dart';

class RecentChatModel extends BaseModel {
  bool? success;
  List<Records>? records;

  RecentChatModel({this.success, this.records});

  factory RecentChatModel.fromMap(Map<String, dynamic> data) {
    return RecentChatModel(
      success: data['success'] as bool?,
      records: (data['records'] as List<dynamic>?)
          ?.map((e) => Records.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  RecentChatModel fromMap(Map<String, dynamic> data) {
    return RecentChatModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': records?.map((e) => e.toMap()).toList(),
      };

  @override
  factory RecentChatModel.fromJson(String data) {
    return RecentChatModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());
}

class Records {
  String? id;
  String? lead_id;
  String? parent_id;
  String? contactname;
  String? country_code;
  String? message;
  String? countrycode;
  String? whatsapp_number;
  String? full_number;
  DateTime? createddate;
  bool? pinned;

  List<dynamic>? tag_names;

  Records(
      {this.id,
      this.parent_id,
      this.lead_id,
      this.contactname,
      this.country_code,
      this.full_number,
      this.countrycode,
      this.whatsapp_number,
      this.createddate,
      this.pinned,
      this.message,
      this.tag_names});

  factory Records.fromMap(Map<String, dynamic> data) {
    // Handle tag_names which could be List<dynamic> or null
    List<dynamic>? tagNamesList;
    if (data['tag_names'] != null && data['tag_names'] is List) {
      tagNamesList = data['tag_names'] as List<dynamic>;
    }

    return Records(
      id: data['id']?.toString(),
      parent_id: data['parent_id']?.toString(),
      lead_id: data['lead_id']?.toString(),
      country_code: data['country_code']?.toString(),
      countrycode: data['countrycode']?.toString(),
      message: data['message']?.toString() ?? "",
      pinned: data['pinned'] ?? false,
      contactname: data['contactname']?.toString(),
      full_number: data['full_number']?.toString(),
      whatsapp_number: data['whatsapp_number']?.toString(),
      createddate: data['createddate'] != null
          ? DateTime.tryParse(data['createddate'].toString())
          : null,
      tag_names: tagNamesList, // Use the properly handled list
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'parent_id': parent_id,
        'lead_id': lead_id,
        'pinned': pinned,
        'contactname': contactname,
        'full_number': full_number,
        'countrycode': countrycode,
        'whatsapp_number': whatsapp_number,
        'createddate': createddate?.toIso8601String(),
        'tag_names': tag_names,
      };

  factory Records.fromJson(String data) {
    return Records.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());
}
