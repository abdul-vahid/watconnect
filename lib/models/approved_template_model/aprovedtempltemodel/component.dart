class Component {
  String? type;
  String? text;
  String? format;
  List<Button>? buttons;
  Example? example;

  Component({this.type, this.text, this.format, this.buttons, this.example});

  factory Component.fromMap(Map<String, dynamic> data) => Component(
        type: data['type'] as String?,
        text: data['text'] as String?,
        format: data['format'] as String?,
        buttons: (data['buttons'] as List<dynamic>?)
            ?.map((e) => Button.fromMap(e as Map<String, dynamic>))
            .toList(),
        example: data['example'] != null
            ? Example.fromMap(data['example'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        'text': text,
        'format': format,
        'buttons': buttons?.map((e) => e.toMap()).toList(),
        'example': example?.toMap(),
      };

  @override
  String toString() {
    return 'Component(type: $type, text: $text, format: $format,buttons: $buttons, example: $example)';
  }
}

class Example {
  List<String>? headerHandle;
  List<List<String>>? bodyText;

  Example({this.headerHandle, this.bodyText});

  factory Example.fromMap(Map<String, dynamic> data) => Example(
        headerHandle:
            (data['header_handle'] as List?)?.map((e) => e as String).toList(),
        bodyText: (data['body_text'] as List?)
            ?.map((e) => (e as List).map((x) => x as String).toList())
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'header_handle': headerHandle,
        'body_text': bodyText,
      };
}

class Button {
  String? type;
  String? text;
  String? phoneNumber;
  String? url;

  Button({this.type, this.text, this.phoneNumber, this.url});

  factory Button.fromMap(Map<String, dynamic> data) => Button(
        type: data['type'] as String?,
        text: data['text'] as String?,
        phoneNumber: data['phone_number'] as String?,
        url: data['url'] as String?,
      );

  Map<String, dynamic> toMap() {
    final map = {
      'type': type,
      'text': text,
      'phone_number': phoneNumber,
      'url': url,
    };

    map.removeWhere((key, value) => value == null);
    return map;
  }
}
