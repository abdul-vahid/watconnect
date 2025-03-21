import 'dart:convert';

class Cursors {
	String? before;
	String? after;

	Cursors({this.before, this.after});

	factory Cursors.fromMap(Map<String, dynamic> data) => Cursors(
				before: data['before'] as String?,
				after: data['after'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'before': before,
				'after': after,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Cursors].
	factory Cursors.fromJson(String data) {
		return Cursors.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Cursors] to a JSON string.
	String toJson() => json.encode(toMap());
}
