class LeadDetailModel {
  final bool? success;
  final LeadDetail? records;

  LeadDetailModel({
    this.success,
    this.records,
  });

  factory LeadDetailModel.fromJson(Map<String, dynamic> json) {
    return LeadDetailModel(
      success: json['success'],
      records: json['records'] != null
          ? LeadDetail.fromJson(json['records'])
          : null,
    );
  }
}

class LeadDetail {
  final String? id;
  final String? firstname;
  final String? lastname;
  final String? company;
  final String? leadsource;
  final String? leadstatus;
  final String? createddate;
  final String? lastmodifieddate;
  final String? phone;
  final String? email;
  final String? description;
  final String? ownerid;
  final String? whatsappNumber;
  final String? countryCode;
  final String? address;
  final List<Tag>? tagNames;
  final List<String>? ownerIds;
  final bool? isArchived;
  final String? leadNo;
  final String? fullNumber;
  final String? contactname;
  final String? lastmodifiedbyname;
  final String? ownername;
  final String? owneremail;
  final List<OwnerName>? allOwnerNames;

  LeadDetail({
    this.id,
    this.firstname,
    this.lastname,
    this.company,
    this.leadsource,
    this.leadstatus,
    this.createddate,
    this.lastmodifieddate,
    this.phone,
    this.email,
    this.description,
    this.ownerid,
    this.whatsappNumber,
    this.countryCode,
    this.address,
    this.tagNames,
    this.ownerIds,
    this.isArchived,
    this.leadNo,
    this.fullNumber,
    this.contactname,
    this.lastmodifiedbyname,
    this.ownername,
    this.owneremail,
    this.allOwnerNames,
  });

  factory LeadDetail.fromJson(Map<String, dynamic> json) {
    return LeadDetail(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      company: json['company'],
      leadsource: json['leadsource'],
      leadstatus: json['leadstatus'],
      createddate: json['createddate'],
      lastmodifieddate: json['lastmodifieddate'],
      phone: json['phone'],
      email: json['email'],
      description: json['description'],
      ownerid: json['ownerid'],
      whatsappNumber: json['whatsapp_number'],
      countryCode: json['country_code'],
      address: json['address'],
      tagNames: json['tag_names'] != null
          ? List<Tag>.from(
              json['tag_names'].map((x) => Tag.fromJson(x)))
          : [],
      ownerIds: json['ownerids'] != null
          ? List<String>.from(json['ownerids'])
          : [],
      isArchived: json['is_archived'],
      leadNo: json['lead_no'],
      fullNumber: json['full_number'],
      contactname: json['contactname'],
      lastmodifiedbyname: json['lastmodifiedbyname'],
      ownername: json['ownername'],
      owneremail: json['owneremail'],
      allOwnerNames: json['all_owner_names'] != null
          ? List<OwnerName>.from(
              json['all_owner_names']
                  .map((x) => OwnerName.fromJson(x)))
          : [],
    );
  }
}

class Tag {
  final String? id;
  final String? name;

  Tag({this.id, this.name});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
    );
  }
}

class OwnerName {
  final String? id;
  final String? name;

  OwnerName({this.id, this.name});

  factory OwnerName.fromJson(Map<String, dynamic> json) {
    return OwnerName(
      id: json['id'],
      name: json['name'],
    );
  }
}