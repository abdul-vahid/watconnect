import 'dart:convert';

import 'package:whatsapp/core/models/base_model.dart';

class LeadResponseModel extends BaseModel {
  bool? success;
  List<LeadModel>? records;

  LeadResponseModel({this.success, this.records});

  factory LeadResponseModel.fromMap(Map<String, dynamic> data) {
    return LeadResponseModel(
      success: data['success'] as bool?,
      records: (data['records'] as List<dynamic>?)
          ?.map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
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
        'records': records?.map((e) => e.toJson()).toList(),
      };

  @override
  factory LeadResponseModel.fromJson(String data) {
    return LeadResponseModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());
}

class LeadModel {
  String? id;
  String? firstname;
  String? lastname;
  String? leadsource;
  String? leadstatus;
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
  String? address;
  List<TagName>? tagNames;
  String? leadname;
  String? ownername;
  String? createdbyname;
  String? lastmodifiedbyname;

  LeadModel({
    this.id,
    this.firstname,
    this.lastname,
    this.leadsource,
    this.leadstatus,
    this.createdbyid,
    this.lastmodifiedbyid,
    this.createddate,
    this.lastmodifieddate,
    this.email,
    this.ownerid,
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
  });

  LeadModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    leadsource = json['leadsource'];
    leadstatus = json['leadstatus'];
    createdbyid = json['createdbyid'];
    lastmodifiedbyid = json['lastmodifiedbyid'];
    createddate = json['createddate'];
    lastmodifieddate = json['lastmodifieddate'];
    email = json['email'];
    ownerid = json['ownerid'];
    whatsappNumber = json['whatsapp_number'];
    blocked = json['blocked'];
    countryCode = json['country_code'];
    dob = json['dob'];
    address = json['address'];

    if (json['tag_names'] != null) {
      tagNames = <TagName>[];
      json['tag_names'].forEach((v) {
        tagNames!.add(TagName.fromJson(v));
      });
    }

    leadname = json['leadname'];
    ownername = json['ownername'];
    createdbyname = json['createdbyname'];
    lastmodifiedbyname = json['lastmodifiedbyname'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'leadsource': leadsource,
      'leadstatus': leadstatus,
      'createdbyid': createdbyid,
      'lastmodifiedbyid': lastmodifiedbyid,
      'createddate': createddate,
      'lastmodifieddate': lastmodifieddate,
      'email': email,
      'ownerid': ownerid,
      'whatsapp_number': whatsappNumber,
      'blocked': blocked,
      'country_code': countryCode,
      'dob': dob,
      'address': address,
      'tag_names': tagNames?.map((v) => v.toJson()).toList(),
      'leadname': leadname,
      'ownername': ownername,
      'createdbyname': createdbyname,
      'lastmodifiedbyname': lastmodifiedbyname,
    };
  }
}

class TagName {
  String? id;
  String? name;

  TagName({this.id, this.name});

  TagName.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
