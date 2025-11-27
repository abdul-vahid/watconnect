// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:convert';
import 'package:whatsapp/core/models/base_model.dart';

class callHistoryModel extends BaseModel {
  bool? success;
  List<CallHistoryData>? records;

  callHistoryModel({this.success = false, this.records});

  factory callHistoryModel.fromMap(Map<String, dynamic> data) {
    return callHistoryModel(
      success: data['success'] ?? false,
      records: (data['records'] as List<dynamic>? ?? [])
          .map((e) => CallHistoryData.fromJson(e))
          .toList(),
    );
  }

  @override
  callHistoryModel fromMap(Map<String, dynamic> data) {
    return callHistoryModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': records?.map((e) => e.toJson()).toList() ?? [],
      };

  @override
  factory callHistoryModel.fromJson(String data) {
    return callHistoryModel.fromMap(json.decode(data));
  }

  String toJson() => json.encode(toMap());
}

class CallHistoryData {
  String? id;
  String? name;
  String? whatsappNumber;
  String? businessNumber;
  String? status;
  String? event;
  String? callId;
  String? startTime;
  String? endTime;
  String? sdp;
  String? sdpType;
  String? direction;
  String? errMessage;
  String? createdById;
  String? lastModifiedById;
  DateTime? createdDate;
  DateTime? lastModifiedDate;
  int? duration;

  String? fileId;
  String? title;

  CallHistoryData();

  CallHistoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    name = json['name'] ?? "";
    whatsappNumber = json['whatsapp_number'] ?? "";
    businessNumber = json['business_number'] ?? "";
    status = json['status'] ?? "";
    event = json['event'] ?? "";
    callId = json['call_id'] ?? "";
    startTime = json['start_time'] ?? "";
    endTime = json['end_time'] ?? "";
    sdp = json['sdp'] ?? "";
    sdpType = json['sdp_type'] ?? "";
    direction = json['direction'] ?? "";
    errMessage = json['err_message'] ?? "";
    createdById = json['createdbyid'] ?? "";
    lastModifiedById = json['lastmodifiedbyid'] ?? "";
    createdDate = json['createddate'] != null
        ? DateTime.tryParse(json['createddate'])
        : null;
    lastModifiedDate = json['lastmodifieddate'] != null
        ? DateTime.tryParse(json['lastmodifieddate'])
        : null;
    duration = json['duration'];
    fileId = json['file_id'] ?? "";
    title = json['title'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'whatsapp_number': whatsappNumber,
      'business_number': businessNumber,
      'status': status,
      'event': event,
      'call_id': callId,
      'start_time': startTime,
      'end_time': endTime,
      'sdp': sdp,
      'sdp_type': sdpType,
      'direction': direction,
      'err_message': errMessage,
      'createdbyid': createdById,
      'lastmodifiedbyid': lastModifiedById,
      'createddate': createdDate?.toIso8601String(),
      'lastmodifieddate': lastModifiedDate?.toIso8601String(),
      'duration': duration,
    };
  }
}
