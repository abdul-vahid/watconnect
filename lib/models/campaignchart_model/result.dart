import 'dart:convert';

class Result {
  String? pending;
  String? inProgress;
  String? completed;
  String? aborted;

  Result({this.pending, this.inProgress, this.completed, this.aborted});

  factory Result.fromMap(Map<String, dynamic> data) => Result(
        pending: data['Pending'] as String?,
        inProgress: data['In Progress'] as String?,
        completed: data['Completed'] as String?,
        aborted: data['Aborted'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'Pending': pending,
        'In Progress': inProgress,
        'Completed': completed,
        'Aborted': aborted,
      };

  /// dart:convert
  ///
  /// Parses the string and returns the resulting Json object as [Result].
  factory Result.fromJson(String data) {
    return Result.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// dart:convert
  ///
  /// Converts [Result] to a JSON string.
  String toJson() => json.encode(toMap());
}
