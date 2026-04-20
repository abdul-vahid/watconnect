// import 'dart:convert';

// import '../core/models/base_model.dart';

// class RecentChatModel extends BaseModel {
//   bool? success;
//   List<Records>? records;

//   RecentChatModel({this.success, this.records});

//   factory RecentChatModel.fromMap(Map<String, dynamic> data) {
//     return RecentChatModel(
//       success: data['success'] as bool?,
//       records: (data['records'] as List<dynamic>?)
//           ?.map((e) => Records.fromMap(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }

//   @override
//   RecentChatModel fromMap(Map<String, dynamic> data) {
//     return RecentChatModel.fromMap(data);
//   }

//   @override
//   Map<String, dynamic> toMap() => {
//         'success': success,
//         'records': records?.map((e) => e.toMap()).toList(),
//       };

//   @override
//   factory RecentChatModel.fromJson(String data) {
//     return RecentChatModel.fromMap(json.decode(data) as Map<String, dynamic>);
//   }

//   String toJson() => json.encode(toMap());
// }

// class Records {
//   String? id;
//   String? lead_id;
//   String? parent_id;
//   String? contactname;
//   String? country_code;
//   String? message;
//   String? countrycode;
//   String? whatsapp_number;
//   String? full_number;
//   DateTime? createddate;
//   bool? pinned;

//   List<dynamic>? tag_names;

//   Records(
//       {this.id,
//       this.parent_id,
//       this.lead_id,
//       this.contactname,
//       this.country_code,
//       this.full_number,
//       this.countrycode,
//       this.whatsapp_number,
//       this.createddate,
//       this.pinned,
//       this.message,
//       this.tag_names});

//   factory Records.fromMap(Map<String, dynamic> data) {
//     // Handle tag_names which could be List<dynamic> or null
//     List<dynamic>? tagNamesList;
//     if (data['tag_names'] != null && data['tag_names'] is List) {
//       tagNamesList = data['tag_names'] as List<dynamic>;
//     }

//     return Records(
//       id: data['id']?.toString(),
//       parent_id: data['parent_id']?.toString(),
//       lead_id: data['lead_id']?.toString(),
//       country_code: data['country_code']?.toString(),
//       countrycode: data['countrycode']?.toString(),
//       message: data['message']?.toString() ?? "",
//       pinned: data['pinned'] ?? false,
//       contactname: data['contactname']?.toString(),
//       full_number: data['full_number']?.toString(),
//       whatsapp_number: data['whatsapp_number']?.toString(),
//       createddate: data['createddate'] != null
//           ? DateTime.tryParse(data['createddate'].toString())
//           : null,
//       tag_names: tagNamesList, // Use the properly handled list
//     );
//   }

//   Map<String, dynamic> toMap() => {
//         'id': id,
//         'parent_id': parent_id,
//         'lead_id': lead_id,
//         'pinned': pinned,
//         'contactname': contactname,
//         'full_number': full_number,
//         'countrycode': countrycode,
//         'whatsapp_number': whatsapp_number,
//         'createddate': createddate?.toIso8601String(),
//         'tag_names': tag_names,
//       };

//   factory Records.fromJson(String data) {
//     return Records.fromMap(json.decode(data) as Map<String, dynamic>);
//   }

//   String toJson() => json.encode(toMap());
// }

import 'dart:convert';
import '../core/models/base_model.dart';

class RecentChatModel extends BaseModel {
  final bool? success;
  final List<Records>? records;

  RecentChatModel({
    this.success,
     this.records,
  });

  factory RecentChatModel.fromMap(Map<String, dynamic> data) {
    return RecentChatModel(
      success: data['success'] as bool?,
      records: (data['records'] as List<dynamic>? ?? [])
          .map((e) => Records.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  RecentChatModel fromMap(Map<String, dynamic> data) =>
      RecentChatModel.fromMap(data);

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': records?.map((e) => e.toMap()).toList(),
      };

  factory RecentChatModel.fromJson(String data) =>
      RecentChatModel.fromMap(json.decode(data));

  String toJson() => json.encode(toMap());
}

class Records {
  static String sanitizeString(String? input) {
    if (input == null) return '';
    return input.replaceAll(
      RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\uD800-\uDFFF\uFFFE\uFFFF]'),
      '',
    );
  }

  final String? id;
  final String? leadId;
  final String? parentId;
  final String? contactName;
  final String? countryCode;
  final String? whatsappNumber;
  final String? fullNumber;
  final String? message;
  final DateTime? createdDate;
  final DateTime? lastMessageTime;
   bool pinned;
  final bool isArchived;
   List<Tag> tags;
  // String? tag_names;

  Records({
    this.id,
    this.leadId,
    this.parentId,
    this.contactName,
    this.countryCode,
    this.whatsappNumber,
    this.fullNumber,
    this.message,
    this.createdDate,
    this.lastMessageTime,
    required this.pinned,
    required this.isArchived,
    required this.tags,
    // this.tag_names
  });

  factory Records.fromMap(Map<String, dynamic> data) {
    final rawTags = data['tag_names'] as List<dynamic>? ?? [];

    return Records(
      id: data['id']?.toString(),
      parentId: data['parent_id']?.toString(),
      leadId: data['lead_id']?.toString(),
      countryCode: data['country_code']?.toString(),
      message: sanitizeString(data['message']?.toString()),
      pinned: data['pinned'] ?? false,
      isArchived: data['is_archived'] ?? false,
      contactName: sanitizeString(data['contactname']?.toString()),
      // tag_names: data['tag_names']?.toString(),
      fullNumber: sanitizeString(data['full_number']?.toString()),
      whatsappNumber: sanitizeString(data['whatsapp_number']?.toString()),
      createdDate: DateTime.tryParse(data['createddate']?.toString() ?? ''),
      lastMessageTime:
          DateTime.tryParse(data['last_message_time']?.toString() ?? ''),
      tags: rawTags
          .whereType<Map<String, dynamic>>()
          .map((tag) => Tag.fromMap(tag))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'parent_id': parentId,
        'lead_id': leadId,
        'pinned': pinned,
        'is_archived': isArchived,
        'contactname': contactName,
        'full_number': fullNumber,
        'country_code': countryCode,
        'whatsapp_number': whatsappNumber,
        'createddate': createdDate?.toIso8601String(),
        'last_message_time': lastMessageTime?.toIso8601String(),
        'tag_names': tags.map((e) => e.toMap()).toList(),
      };

  factory Records.fromJson(String data) =>
      Records.fromMap(json.decode(data));

  String toJson() => json.encode(toMap());
}

class Tag {
  final String? id;
  final String? name;

  Tag({this.id, this.name});

  factory Tag.fromMap(Map<String, dynamic> data) {
    return Tag(
      id: data['id']?.toString(),
      name: Records.sanitizeString(data['name']?.toString()),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
      };
}