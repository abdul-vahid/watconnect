import 'dart:convert';

class Record {
  String? whatsappNumber;
  String? unreadMsgCount;

  Record({this.whatsappNumber, this.unreadMsgCount});

  factory Record.fromMap(Map<String, dynamic> data) => Record(
        whatsappNumber: data['whatsapp_number'] as String?,
        unreadMsgCount: data['unread_msg_count'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'whatsapp_number': whatsappNumber,
        'unread_msg_count': unreadMsgCount,
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
