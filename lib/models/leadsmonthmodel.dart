import 'dart:convert';

import '../core/models/base_model.dart';

class Leadsmonthmodel extends BaseModel {
  String? totalnew;
  String? leadstatus;
  String? createdmonth;
  DateTime? createddate;

  Leadsmonthmodel({
    this.totalnew,
    this.leadstatus,
    this.createdmonth,
    this.createddate,
  });

  factory Leadsmonthmodel.fromMap(Map<String, dynamic> data) {
    return Leadsmonthmodel(
      totalnew: data['totalnew']?.toString(),
      leadstatus: data['leadstatus']?.toString(),
      createdmonth: data['createdmonth']?.toString(),
      createddate: data['createddate'] == null
          ? null
          : DateTime.tryParse(data['createddate'].toString()),
    );
  }
  @override
  Leadsmonthmodel fromMap(Map<String, dynamic> data) {
    return Leadsmonthmodel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        if (totalnew != null) 'totalnew': totalnew,
        if (leadstatus != null) 'leadstatus': leadstatus,
        if (createdmonth != null) 'createdmonth': createdmonth,
        if (createddate != null) 'createddate': createddate?.toIso8601String(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Leadsmonthmodel].
  @override
  factory Leadsmonthmodel.fromJson(String data) {
    return Leadsmonthmodel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Leadsmonthmodel] to a JSON string.
  String toJson() => json.encode(toMap());
}
