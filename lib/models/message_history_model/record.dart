import 'dart:convert';

class Record {
  String? id;
  String? name;
  String? number;
  String? status;
  String? message;
  String? parentId;
  String? totalRecords;
  String? successCount;
  String? failedCount;
  String? deliveryStatus;
  String? errormsg;

  Record({
    this.id,
    this.name,
    this.number,
    this.status,
    this.message,
    this.parentId,
    this.totalRecords,
    this.successCount,
    this.failedCount,
    this.deliveryStatus,
    this.errormsg,
  });

  factory Record.fromMap(Map<String, dynamic> data) => Record(
        id: data['id'] as String?,
        name: data['name'] as String?,
        number: data['number'] as String?,
        status: data['status'] as String?,
        message: data['message'] as String?,
        parentId: data['parent_id'] as String?,
        totalRecords: data['total_records'] as String?,
        successCount: data['success_count'] as String?,
        failedCount: data['failed_count'] as String?,
        deliveryStatus: data['delivery_status'] as String?,
        errormsg: data['err_message'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'number': number,
        'status': status,
        'message': message,
        'parent_id': parentId,
        'total_records': totalRecords,
        'success_count': successCount,
        'failed_count': failedCount,
        'delivery_status': deliveryStatus,
        'err_message': errormsg,
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
