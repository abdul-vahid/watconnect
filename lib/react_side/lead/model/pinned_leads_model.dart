class PinnedLeadsModel {
  final bool success;
  final List<PinnedLeadRecord> records;

  PinnedLeadsModel({
    required this.success,
    required this.records,
  });

  factory PinnedLeadsModel.fromJson(Map<String, dynamic> json) {
    return PinnedLeadsModel(
      success: json['success'] ?? false,
      records: (json['records'] as List<dynamic>?)
              ?.map((e) => PinnedLeadRecord.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'records': records.map((e) => e.toJson()).toList(),
    };
  }
}

class PinnedLeadRecord {
  final String id;
  final String name;
  final String fullNumber;
  final bool pinned;

  PinnedLeadRecord({
    required this.id,
    required this.name,
    required this.fullNumber,
    required this.pinned,
  });

  factory PinnedLeadRecord.fromJson(Map<String, dynamic> json) {
    return PinnedLeadRecord(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      fullNumber: json['full_number'] ?? '',
      pinned: json['pinned'] ?? false,
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