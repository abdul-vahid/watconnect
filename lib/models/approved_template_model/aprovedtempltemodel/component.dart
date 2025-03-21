import 'dart:convert';

import 'example.dart';

class Component {
	String? type;
	String? text;
	bool? addSecurityRecommendation;
	Example? example;

	Component({
		this.type, 
		this.text, 
		this.addSecurityRecommendation, 
		this.example, 
	});

	factory Component.fromMap(Map<String, dynamic> data) => Component(
				type: data['type'] as String?,
				text: data['text'] as String?,
				addSecurityRecommendation: data['add_security_recommendation'] as bool?,
				example: data['example'] == null
						? null
						: Example.fromMap(data['example'] as Map<String, dynamic>),
			);

	Map<String, dynamic> toMap() => {
				'type': type,
				'text': text,
				'add_security_recommendation': addSecurityRecommendation,
				'example': example?.toMap(),
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Component].
	factory Component.fromJson(String data) {
		return Component.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Component] to a JSON string.
	String toJson() => json.encode(toMap());
}
