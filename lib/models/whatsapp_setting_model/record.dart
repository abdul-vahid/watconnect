import 'dart:convert';

class Record {
  String? id;
  String? name;
  String? businessNumberId;
  String? whatsappBusinessAccountId;
  String? endPointUrl;
  String? accessToken;
  String? phone;
  DateTime? createddate;
  DateTime? lastmodifieddate;
  String? createdbyid;
  String? lastmodifiedbyid;
  String? appId;

  Record({
    this.id,
    this.name,
    this.businessNumberId,
    this.whatsappBusinessAccountId,
    this.endPointUrl,
    this.accessToken,
    this.phone,
    this.createddate,
    this.lastmodifieddate,
    this.createdbyid,
    this.lastmodifiedbyid,
    this.appId,
  });

  factory Record.fromMap(Map<String, dynamic> data) => Record(
        id: data['id'] as String?,
        name: data['name'] as String?,
        businessNumberId: data['business_number_id'] as String?,
        whatsappBusinessAccountId:
            data['whatsapp_business_account_id'] as String?,
        endPointUrl: data['end_point_url'] as String?,
        accessToken: data['access_token'] as String?,
        phone: data['phone'] as String?,
        createddate: data['createddate'] == null
            ? null
            : DateTime.parse(data['createddate'] as String),
        lastmodifieddate: data['lastmodifieddate'] == null
            ? null
            : DateTime.parse(data['lastmodifieddate'] as String),
        createdbyid: data['createdbyid'] as String?,
        lastmodifiedbyid: data['lastmodifiedbyid'] as String?,
        appId: data['app_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'business_number_id': businessNumberId,
        'whatsapp_business_account_id': whatsappBusinessAccountId,
        'end_point_url': endPointUrl,
        'access_token': accessToken,
        'phone': phone,
        'createddate': createddate?.toIso8601String(),
        'lastmodifieddate': lastmodifieddate?.toIso8601String(),
        'createdbyid': createdbyid,
        'lastmodifiedbyid': lastmodifiedbyid,
        'app_id': appId,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Record].
  factory Record.fromJson(String data) {
    return Record.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Record] to a JSON string.
  String toJson() => json.encode(toMap());
}
