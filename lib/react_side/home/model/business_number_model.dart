class BusinessNumberModels {
  final bool? success;
  final List<BusinessRecord>? record;

  BusinessNumberModels({
    this.success,
    this.record,
  });

  factory BusinessNumberModels.fromJson(Map<String, dynamic> json) {
    return BusinessNumberModels(
      success: json['success'],
      record: json['record'] != null
          ? List<BusinessRecord>.from(
              json['record'].map((x) => BusinessRecord.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'record': record?.map((x) => x.toJson()).toList(),
    };
  }
}

class BusinessRecord {
  final String? id;
  final String? name;
  final String? businessNumberId;
  final String? whatsappBusinessAccountId;
  final String? endPointUrl;
  final String? accessToken;
  final String? phone;
  final DateTime? createdDate;
  final DateTime? lastModifiedDate;
  final String? createdById;
  final String? lastModifiedById;
  final String? appId;
  final String? environment;

  BusinessRecord({
    this.id,
    this.name,
    this.businessNumberId,
    this.whatsappBusinessAccountId,
    this.endPointUrl,
    this.accessToken,
    this.phone,
    this.createdDate,
    this.lastModifiedDate,
    this.createdById,
    this.lastModifiedById,
    this.appId,
    this.environment,
  });

  factory BusinessRecord.fromJson(Map<String, dynamic> json) {
    return BusinessRecord(
      id: json['id'],
      name: json['name'],
      businessNumberId: json['business_number_id'],
      whatsappBusinessAccountId: json['whatsapp_business_account_id'],
      endPointUrl: json['end_point_url'],
      accessToken: json['access_token'],
      phone: json['phone'],
      createdDate: json['createddate'] != null
          ? DateTime.parse(json['createddate'])
          : null,
      lastModifiedDate: json['lastmodifieddate'] != null
          ? DateTime.parse(json['lastmodifieddate'])
          : null,
      createdById: json['createdbyid'],
      lastModifiedById: json['lastmodifiedbyid'],
      appId: json['app_id'],
      environment: json['environment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_number_id': businessNumberId,
      'whatsapp_business_account_id': whatsappBusinessAccountId,
      'end_point_url': endPointUrl,
      'access_token': accessToken,
      'phone': phone,
      'createddate': createdDate?.toIso8601String(),
      'lastmodifieddate': lastModifiedDate?.toIso8601String(),
      'createdbyid': createdById,
      'lastmodifiedbyid': lastModifiedById,
      'app_id': appId,
      'environment': environment,
    };
  }
}