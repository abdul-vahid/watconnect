import 'dart:convert';

class UnreadRecord {
  String? whatsappNumber;
  String? unreadMsgCount;
  String? name;
  String? parentId;

  UnreadRecord({this.whatsappNumber, this.unreadMsgCount, this.name, this.parentId});

  factory UnreadRecord.fromMap(Map<String, dynamic> data) => UnreadRecord(
        whatsappNumber: data['whatsapp_number'] as String?,
        unreadMsgCount: data['unread_msg_count'] as String?,
        name: data['name'] as String?,
        parentId: data['parent_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'whatsapp_number': whatsappNumber,
        'unread_msg_count': unreadMsgCount,
        'name': name,
        'parent_id': parentId
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [UnreadRecord].
  factory UnreadRecord.fromJson(String data) {
    return UnreadRecord.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [UnreadRecord] to a JSON string.
  String toJson() => json.encode(toMap());
}
