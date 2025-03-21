import 'dart:convert';

import '../core/models/base_model.dart';

class LeadCountAgentModel extends BaseModel {
  String? ownername;
  String? leadstatus;
  String? count;

  LeadCountAgentModel({this.ownername, this.leadstatus, this.count});

  factory LeadCountAgentModel.fromMap(Map<String, dynamic> data) {
    return LeadCountAgentModel(
      ownername: data['ownername']?.toString(),
      leadstatus: data['leadstatus']?.toString(),
      count: data['count']?.toString(),
    );
  }
  @override
  LeadCountAgentModel fromMap(Map<String, dynamic> data) {
    return LeadCountAgentModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        if (ownername != null) 'ownername': ownername,
        if (leadstatus != null) 'leadstatus': leadstatus,
        if (count != null) 'count': count,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [LeadCountAgentModel].
  @override
  factory LeadCountAgentModel.fromJson(String data) {
    return LeadCountAgentModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [LeadCountAgentModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
