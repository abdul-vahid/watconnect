import 'dart:convert';

class Permission {
  String? name;

  Permission({this.name});

  factory Permission.fromMap(Map<String, dynamic> data) => Permission(
        name: data['name'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Permission].
  factory Permission.fromJson(String data) {
    return Permission.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Permission] to a JSON string.
  String toJson() => json.encode(toMap());
}
