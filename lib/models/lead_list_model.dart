class LeadListModel {
  String? id;
  String? firstname;
  String? lastname;
  String? leadsource;
  String? leadstatus;
  String? createdbyid;
  String? lastmodifiedbyid;
  DateTime? createddate;
  DateTime? lastmodifieddate;
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

  LeadListModel();

  LeadListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    firstname = json['firstname'] ?? "";
    lastname = json['lastname'] ?? "";
    leadsource = json['leadsource'] ?? "";
    leadstatus = json['leadstatus'] ?? "";
    createdbyid = json['createdbyid'] ?? "";
    lastmodifiedbyid = json['lastmodifiedbyid'] ?? "";
    createddate = json['createddate'] != null
        ? DateTime.tryParse(json['createddate'])
        : null;
    lastmodifieddate = json['lastmodifieddate'] != null
        ? DateTime.tryParse(json['lastmodifieddate'])
        : null;
    email = json['email'] ?? "";
    ownerid = json['ownerid'] ?? "";
    whatsappNumber = json['whatsapp_number'] ?? "";
    blocked = json['blocked'] ?? false;
    countryCode = json['country_code'] ?? "";
    dob = json['dob'] ?? "";
    address = json['address'] ?? "";
    tagNames = (json['tag_names'] as List?)
            ?.map((e) => TagName.fromJson(e))
            .toList() ??
        [];
    leadname = json['leadname'] ?? "";
    ownername = json['ownername'] ?? "";
    createdbyname = json['createdbyname'] ?? "";
    lastmodifiedbyname = json['lastmodifiedbyname'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id ?? "";
    data['firstname'] = firstname ?? "";
    data['lastname'] = lastname ?? "";
    data['leadsource'] = leadsource ?? "";
    data['leadstatus'] = leadstatus ?? "";
    data['createdbyid'] = createdbyid ?? "";
    data['lastmodifiedbyid'] = lastmodifiedbyid ?? "";
    data['createddate'] = createddate?.toIso8601String() ?? "";
    data['lastmodifieddate'] = lastmodifieddate?.toIso8601String() ?? "";
    data['email'] = email ?? "";
    data['ownerid'] = ownerid ?? "";
    data['whatsapp_number'] = whatsappNumber ?? "";
    data['blocked'] = blocked ?? false;
    data['country_code'] = countryCode ?? "";
    data['dob'] = dob ?? "";
    data['address'] = address ?? "";
    data['tag_names'] = tagNames?.map((e) => e.toJson()).toList() ?? [];
    data['leadname'] = leadname ?? "";
    data['ownername'] = ownername ?? "";
    data['createdbyname'] = createdbyname ?? "";
    data['lastmodifiedbyname'] = lastmodifiedbyname ?? "";
    return data;
  }
}

class TagName {
  String? id;
  String? name;

  TagName();

  TagName.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    name = json['name'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id ?? "";
    data['name'] = name ?? "";
    return data;
  }
}
