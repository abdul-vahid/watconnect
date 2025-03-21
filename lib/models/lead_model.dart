// ignore: file_names
import 'dart:convert';

import '../core/models/base_model.dart';

class LeadModel extends BaseModel {
  String? id;
  String? firstname;
  String? lastname;
  String? company;
  dynamic leadsource;
  String? leadstatus;
  dynamic rating;
  String? createdbyid;
  String? lastmodifiedbyid;
  DateTime? createddate;
  DateTime? lastmodifieddate;
  String? salutation;
  String? phone;
  String? whatsapp_number;
  String? email;
  dynamic fax;
  dynamic industry;
  String? title;
  dynamic street;
  dynamic city;
  dynamic state;
  dynamic country;
  dynamic zipcode;
  dynamic description;
  String? ownerid;
  String? convertedcontactid;
  dynamic lostreason;
  String? amount;
  dynamic paymentmodel;
  dynamic paymentterms;
  bool? iswon;
  dynamic pageid;
  dynamic formid;
  dynamic adid;
  dynamic legacyid;
  String? leadname;
  String? ownername;
  String? createdbyname;
  String? lastmodifiedbyname;

  LeadModel({
    this.id,
    this.firstname,
    this.lastname,
    this.company,
    this.leadsource,
    this.leadstatus,
    this.rating,
    this.createdbyid,
    this.lastmodifiedbyid,
    this.createddate,
    this.lastmodifieddate,
    this.salutation,
    this.phone,
    this.whatsapp_number,
    this.email,
    this.fax,
    this.industry,
    this.title,
    this.street,
    this.city,
    this.state,
    this.country,
    this.zipcode,
    this.description,
    this.ownerid,
    this.convertedcontactid,
    this.lostreason,
    this.amount,
    this.paymentmodel,
    this.paymentterms,
    this.iswon,
    this.pageid,
    this.formid,
    this.adid,
    this.legacyid,
    this.leadname,
    this.ownername,
    this.createdbyname,
    this.lastmodifiedbyname,
  });

  factory LeadModel.fromMap(Map<String, dynamic> data) => LeadModel(
        id: data['id']?.toString(),
        firstname: data['firstname']?.toString(),
        lastname: data['lastname']?.toString(),
        company: data['company']?.toString(),
        leadsource: data['leadsource'],
        leadstatus: data['leadstatus']?.toString(),
        rating: data['rating'],
        createdbyid: data['createdbyid']?.toString(),
        lastmodifiedbyid: data['lastmodifiedbyid']?.toString(),
        createddate: data['createddate'] == null
            ? null
            : DateTime.tryParse(data['createddate'].toString()),
        lastmodifieddate: data['lastmodifieddate'] == null
            ? null
            : DateTime.tryParse(data['lastmodifieddate'].toString()),
        salutation: data['salutation']?.toString(),
        phone: data['phone']?.toString(),
        whatsapp_number: data['whatsapp_number']?.toString(),
        email: data['email']?.toString(),
        fax: data['fax'],
        industry: data['industry'],
        title: data['title']?.toString(),
        street: data['street'],
        city: data['city'],
        state: data['state'],
        country: data['country'],
        zipcode: data['zipcode'],
        description: data['description'],
        ownerid: data['ownerid']?.toString(),
        convertedcontactid: data['convertedcontactid']?.toString(),
        lostreason: data['lostreason'],
        amount: data['amount']?.toString(),
        paymentmodel: data['paymentmodel'],
        paymentterms: data['paymentterms'],
        iswon: data['iswon']?.toString().contains("true"),
        pageid: data['pageid'],
        formid: data['formid'],
        adid: data['adid'],
        legacyid: data['legacyid'],
        leadname: data['leadname']?.toString(),
        ownername: data['ownername']?.toString(),
        createdbyname: data['createdbyname']?.toString(),
        lastmodifiedbyname: data['lastmodifiedbyname']?.toString(),
      );
  @override
  LeadModel fromMap(Map<String, dynamic> data) {
    return LeadModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        if (firstname != null) 'firstname': firstname,
        if (lastname != null) 'lastname': lastname,
        if (company != null) 'company': company,
        if (leadsource != null) 'leadsource': leadsource,
        if (leadstatus != null) 'leadstatus': leadstatus,
        if (rating != null) 'rating': rating,
        if (createdbyid != null) 'createdbyid': createdbyid,
        if (lastmodifiedbyid != null) 'lastmodifiedbyid': lastmodifiedbyid,
        if (createddate != null) 'createddate': createddate?.toIso8601String(),
        if (lastmodifieddate != null)
          'lastmodifieddate': lastmodifieddate?.toIso8601String(),
        if (salutation != null) 'salutation': salutation,
        if (phone != null) 'phone': phone,
        if (whatsapp_number != null) 'whatsapp_number': whatsapp_number,
        if (email != null) 'email': email,
        if (fax != null) 'fax': fax,
        if (industry != null) 'industry': industry,
        if (title != null) 'title': title,
        if (street != null) 'street': street,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (country != null) 'country': country,
        if (zipcode != null) 'zipcode': zipcode,
        if (description != null) 'description': description,
        if (ownerid != null) 'ownerid': ownerid,
        if (convertedcontactid != null)
          'convertedcontactid': convertedcontactid,
        if (lostreason != null) 'lostreason': lostreason,
        if (amount != null) 'amount': amount,
        if (paymentmodel != null) 'paymentmodel': paymentmodel,
        if (paymentterms != null) 'paymentterms': paymentterms,
        if (iswon != null) 'iswon': iswon,
        if (pageid != null) 'pageid': pageid,
        if (formid != null) 'formid': formid,
        if (adid != null) 'adid': adid,
        if (legacyid != null) 'legacyid': legacyid,
        if (leadname != null) 'leadname': leadname,
        if (ownername != null) 'ownername': ownername,
        if (createdbyname != null) 'createdbyname': createdbyname,
        if (lastmodifiedbyname != null)
          'lastmodifiedbyname': lastmodifiedbyname,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [LeadModel].
  @override
  factory LeadModel.fromJson(String data) {
    return LeadModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [LeadModel] to a JSON string.
  String toJson() => json.encode(toMap());

  void removeAt(LeadModel model) {}
}
