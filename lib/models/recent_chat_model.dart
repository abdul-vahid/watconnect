// ignore: file_names
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
  String? parent_id;
  String? contactname;
  String? country_code;
  String? message;
  String? countrycode;
  String? whatsapp_number;
  String? full_number;
  DateTime? createddate;

  Records(
      {this.id,
      this.parent_id,
      this.contactname,
      this.country_code,
      this.full_number,
      this.countrycode,
      this.whatsapp_number,
      this.createddate,
      this.message});

  factory Records.fromMap(Map<String, dynamic> data) {
    return Records(
      id: data['id']?.toString(),
      parent_id: data['parent_id']?.toString(),
      country_code: data['country_code'].toString(),
      countrycode: data['countrycode'].toString(),
      message: data['message'] ?? "",
      contactname: data['contactname']?.toString(),
      full_number: data['full_number']?.toString(),
      whatsapp_number: data['whatsapp_number']?.toString(),
      createddate: data['createddate'] != null
          ? DateTime.tryParse(data['createddate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'parent_id': parent_id,
        'contactname': contactname,
        'full_number': full_number,
        'countrycode': countrycode,
        'whatsapp_number': whatsapp_number,
        'createddate': createddate,
      };

  factory Records.fromJson(String data) {
    return Records.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());
}

// class RecentChatModel extends BaseModel {
//   String? id;
//   String? parent_id;
//   String? contactname;

//   String? whatsapp_number;
//   String? full_number;

//   DateTime? createddate;

//   RecentChatModel({
//     this.id,
//     this.parent_id,
//     this.contactname,
//     this.full_number,
//     this.whatsapp_number,
//     this.createddate,
//   });

//   factory RecentChatModel.fromMap(Map<String, dynamic> data) => RecentChatModel(
//         id: data['id']?.toString(),
//         parent_id: data['parent_id']?.toString(),
//         contactname: data['contactname']?.toString(),
//         full_number: data['full_number']?.toString(),
//         whatsapp_number: data['whatsapp_number']?.toString(),
//         createddate: data['createddate'] == null
//             ? null
//             : DateTime.tryParse(data['createddate'].toString()),
//       );
//   @override
//   RecentChatModel fromMap(Map<String, dynamic> data) {
//     return RecentChatModel.fromMap(data);
//   }

//   @override
//   Map<String, dynamic> toMap() => {
//         if (id != null) 'id': id,
//         if (parent_id != null) 'parent_id': parent_id,
//         if (contactname != null) 'contactname': contactname,
//         if (full_number != null) 'full_number': full_number,
//         if (whatsapp_number != null) 'whatsapp_number': whatsapp_number,
//         if (createddate != null) 'createddate': createddate,
//       };

//   @override
//   factory RecentChatModel.fromJson(String data) {
//     return RecentChatModel.fromMap(json.decode(data) as Map<String, dynamic>);
//   }

//   String toJson() => json.encode(toMap());

//   void removeAt(RecentChatModel model) {}
// }
