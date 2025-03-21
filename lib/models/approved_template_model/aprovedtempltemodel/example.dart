import 'dart:convert';

class Example {
	List<List<String>>? bodyText;

	Example({this.bodyText});

	factory Example.fromMap(Map<String, dynamic> data) => Example(
				bodyText: data['body_text'] as List<List<String>>?,
			);

	Map<String, dynamic> toMap() => {
				'body_text': bodyText,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Example].
	factory Example.fromJson(String data) {
		return Example.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Example] to a JSON string.
	String toJson() => json.encode(toMap());
}
