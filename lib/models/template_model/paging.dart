import 'dart:convert';

import 'cursors.dart';

class Paging {
  Cursors? cursors;

  Paging({this.cursors});

  factory Paging.fromMap(Map<String, dynamic> data) => Paging(
        cursors: data['cursors'] == null
            ? null
            : Cursors.fromMap(data['cursors'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'cursors': cursors?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Paging].
  factory Paging.fromJson(String data) {
    return Paging.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Paging] to a JSON string.
  String toJson() => json.encode(toMap());
}
