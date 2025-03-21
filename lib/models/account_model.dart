import 'dart:convert';

import '../core/models/base_model.dart';

class AccountModel extends BaseModel {
  String? id;
  String? name;
  String? website;
  String? street;
  String? city;
  String? state;
  String? country;
  String? pincode;
  String? phone;
  String? email;
  DateTime? lastmodifieddate;
  DateTime? createddate;
  String? createdbyid;
  String? lastmodifiedbyid;
  String? createdbyname;
  String? lastmodifiedbyname;

  AccountModel({
    this.id,
    this.name,
    this.website,
    this.street,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.phone,
    this.email,
    this.lastmodifieddate,
    this.createddate,
    this.createdbyid,
    this.lastmodifiedbyid,
    this.createdbyname,
    this.lastmodifiedbyname,
  });

  factory AccountModel.fromMap(Map<String, dynamic> data) => AccountModel(
        id: data['id']?.toString(),
        name: data['name']?.toString(),
        website: data['website']?.toString(),
        street: data['street']?.toString(),
        city: data['city']?.toString(),
        state: data['state']?.toString(),
        country: data['country']?.toString(),
        pincode: data['pincode']?.toString(),
        phone: data['phone']?.toString(),
        email: data['email']?.toString(),
        lastmodifieddate: data['lastmodifieddate'] == null
            ? null
            : DateTime.tryParse(data['lastmodifieddate'].toString()),
        createddate: data['createddate'] == null
            ? null
            : DateTime.tryParse(data['createddate'].toString()),
        createdbyid: data['createdbyid']?.toString(),
        lastmodifiedbyid: data['lastmodifiedbyid']?.toString(),
        createdbyname: data['createdbyname']?.toString(),
        lastmodifiedbyname: data['lastmodifiedbyname']?.toString(),
      );
  @override
  AccountModel fromMap(Map<String, dynamic> data) {
    return AccountModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (website != null) 'website': website,
        if (street != null) 'street': street,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (country != null) 'country': country,
        if (pincode != null) 'pincode': pincode,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (lastmodifieddate != null)
          'lastmodifieddate': lastmodifieddate?.toIso8601String(),
        if (createddate != null) 'createddate': createddate?.toIso8601String(),
        if (createdbyid != null) 'createdbyid': createdbyid,
        if (lastmodifiedbyid != null) 'lastmodifiedbyid': lastmodifiedbyid,
        if (createdbyname != null) 'createdbyname': createdbyname,
        if (lastmodifiedbyname != null)
          'lastmodifiedbyname': lastmodifiedbyname,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [AccountModel].
  @override
  factory AccountModel.fromJson(String data) {
    return AccountModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [AccountModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
