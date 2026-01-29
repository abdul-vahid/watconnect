// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:whatsapp/core/models/base_model.dart';

class LeadResponseModel extends BaseModel {
  bool? success;
  List<LeadModel>? records;

  LeadResponseModel({this.success = false, this.records});

  factory LeadResponseModel.fromMap(Map<String, dynamic> data) {
    return LeadResponseModel(
      success: data['success'] ?? false,
      records: (data['records'] as List<dynamic>? ?? [])
          .map((e) => LeadModel.fromJson(e))
          .toList(),
    );
  }

  @override
  LeadResponseModel fromMap(Map<String, dynamic> data) {
    return LeadResponseModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': records?.map((e) => e.toJson()).toList() ?? [],
      };

  @override
  factory LeadResponseModel.fromJson(String data) {
    return LeadResponseModel.fromMap(json.decode(data));
  }

  String toJson() => json.encode(toMap());
}

class LeadModel {
  String? id;
  String? full_number;
  String? lead_id;
  String? firstname;
  String? lastname;
  String? leadsource;
  String? leadstatus;
  String? contactname;
  String? createdbyid;
  String? lastmodifiedbyid;
  String? createddate;
  String? lastmodifieddate;
  String? email;
  String? ownerid;
  String? whatsappNumber;
  bool? blocked;
  String? countryCode;
  String? dob;
  String? description;

  String? address;
  List<TagName>? tagNames;
  String? leadname;
  String? ownername;
  String? createdbyname;
  String? lastmodifiedbyname;
  bool? pinned;
  bool? isArchived;

  LeadModel(
      {this.id,
      this.firstname,
      this.lastname,
      this.leadsource,
      this.lead_id,
      this.leadstatus,
      this.createdbyid,
      this.lastmodifiedbyid,
      this.createddate,
      this.lastmodifieddate,
      this.full_number,
      this.email,
      this.contactname,
      this.ownerid,
      this.description,
      this.whatsappNumber,
      this.blocked,
      this.countryCode,
      this.dob,
      this.address,
      this.tagNames,
      this.leadname,
      this.ownername,
      this.createdbyname,
      this.lastmodifiedbyname,
      this.pinned,
      this.isArchived
      });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
        id: json['id'] ?? '',
        firstname: json['firstname'] ?? '',
        lead_id: json['lead_id'] ?? "",
        lastname: json['lastname'] ?? '',
        leadsource: json['leadsource'] ?? '',
        leadstatus: json['leadstatus'] ?? '',
        description: json['description'] ?? "",
        createdbyid: json['createdbyid'] ?? '',
        contactname: json['contactname'] ?? "",
        lastmodifiedbyid: json['lastmodifiedbyid'] ?? '',
        createddate: json['createddate'] ?? '',
        lastmodifieddate: json['lastmodifieddate'] ?? '',
        email: json['email'] ?? '',
        ownerid: json['ownerid'] ?? '',
        full_number: json['full_number'] ?? "",
        whatsappNumber: json['whatsapp_number'] ?? '',
        blocked: json['blocked'] ?? false,
        countryCode: json['country_code'] ?? '',
        dob: json['dob'] ?? '',
        address: json['address'] ?? '',
        tagNames: (json['tag_names'] as List<dynamic>? ?? [])
            .map((v) => TagName.fromJson(v))
            .toList(),
        leadname: json['leadname'] ?? '',
        ownername: json['ownername'] ?? '',
        createdbyname: json['createdbyname'] ?? '',
        lastmodifiedbyname: json['lastmodifiedbyname'] ?? '',
        pinned: json['pinned'] ?? false,
        isArchived: json['is_archived']??false
        
        );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? '',
      'firstname': firstname ?? '',
      'lastname': lastname ?? '',
      'full_number': full_number ?? "",
      'leadsource': leadsource ?? '',
      'leadstatus': leadstatus ?? '',
      'lead_id': lead_id ?? "",
      'createdbyid': createdbyid ?? '',
      'lastmodifiedbyid': lastmodifiedbyid ?? '',
      'createddate': createddate ?? '',
      'lastmodifieddate': lastmodifieddate ?? '',
      'email': email ?? '',
      'contactname': contactname ?? "",
      'ownerid': ownerid ?? '',
      'description': description ?? "",
      'whatsapp_number': whatsappNumber ?? '',
      'blocked': blocked ?? false,
      'country_code': countryCode ?? '',
      'dob': dob ?? '',
      'address': address ?? '',
      'tag_names': tagNames?.map((v) => v.toJson()).toList() ?? [],
      'leadname': leadname ?? '',
      'ownername': ownername ?? '',
      'createdbyname': createdbyname ?? '',
      'lastmodifiedbyname': lastmodifiedbyname ?? '',
      'pinned': pinned ?? false,
      "is_archived":isArchived??false
    };
  }
}

class TagName {
  String? id;
  String? name;

  TagName({this.id, this.name});

  factory TagName.fromJson(Map<String, dynamic> json) {
    return TagName(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? '',
      'name': name ?? '',
    };
  }
}
