import 'dart:convert';

PinnedLeadModel pinnedLeadModelFromJson(String str) =>
    PinnedLeadModel.fromJson(json.decode(str));

String pinnedLeadModelToJson(PinnedLeadModel data) =>
    json.encode(data.toJson());

class PinnedLeadModel {
  bool? success;
  List<PinnedLeadRecord>? records;
  int? total;
  bool? hasMore;
  int? page;
  int? pageSize;
  int? totalPages;

  PinnedLeadModel({
    this.success,
    this.records,
    this.total,
    this.hasMore,
    this.page,
    this.pageSize,
    this.totalPages,
  });

  factory PinnedLeadModel.fromJson(Map<String, dynamic> json) {
    return PinnedLeadModel(
      success: json['success'],
      records: json['records'] != null
          ? List<PinnedLeadRecord>.from(
              json['records'].map((x) => PinnedLeadRecord.fromJson(x)))
          : [],
      total: json['total'],
      hasMore: json['hasMore'],
      page: json['page'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'records': records != null
          ? List<dynamic>.from(records!.map((x) => x.toJson()))
          : [],
      'total': total,
      'hasMore': hasMore,
      'page': page,
      'pageSize': pageSize,
      'totalPages': totalPages,
    };
  }
}

class PinnedLeadRecord {
  String? id;
  String? name;
  String? fullNumber;
  bool? pinned;

  PinnedLeadRecord({
    this.id,
    this.name,
    this.fullNumber,
    this.pinned,
  });

  factory PinnedLeadRecord.fromJson(Map<String, dynamic> json) {
    return PinnedLeadRecord(
      id: json['id'],
      name: json['name'],
      fullNumber: json['full_number'],
      pinned: json['pinned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_number': fullNumber,
      'pinned': pinned,
    };
  }
}