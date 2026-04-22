class TemplateModel {
  final List<TemplateData>? data;
  final Paging? paging;

  TemplateModel({this.data, this.paging});

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      data: json['data'] != null
          ? List<TemplateData>.from(
              json['data'].map((x) => TemplateData.fromJson(x)))
          : [],
      paging:
          json['paging'] != null ? Paging.fromJson(json['paging']) : null,
    );
  }
}

class TemplateData {
  final String? name;
  final String? parameterFormat;
  final List<Component>? components;
  final String? language;
  final String? status;
  final String? category;
  final bool? isPrimaryDeviceDeliveryOnly;
  final String? id;
  final String? previousCategory;

  TemplateData({
    this.name,
    this.parameterFormat,
    this.components,
    this.language,
    this.status,
    this.category,
    this.isPrimaryDeviceDeliveryOnly,
    this.id,
    this.previousCategory,
  });

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    return TemplateData(
      name: json['name'],
      parameterFormat: json['parameter_format'],
      components: json['components'] != null
          ? List<Component>.from(
              json['components'].map((x) => Component.fromMap(x)))
          : [],
      language: json['language'],
      status: json['status'],
      category: json['category'],
      isPrimaryDeviceDeliveryOnly:
          json['is_primary_device_delivery_only'],
      id: json['id'],
      previousCategory: json['previous_category'],
    );
  }
}

class Component {
  String? type;
  String? text;
  String? format;
  List<Button>? buttons;
  Example? example;
  List<CardComponent>? cards; // NEW

  Component({
    this.type,
    this.text,
    this.format,
    this.buttons,
    this.example,
    this.cards,
  });

  factory Component.fromMap(Map<String, dynamic> data) => Component(
        type: data['type'] as String?,
        text: data['text'] as String?,
        format: data['format'] as String?,
        buttons: (data['buttons'] as List<dynamic>?)
            ?.map((e) => Button.fromMap(e as Map<String, dynamic>))
            .toList(),
        example: data['example'] != null
            ? Example.fromJson(data['example'] as Map<String, dynamic>)
            : null,
        cards: (data['cards'] as List<dynamic>?)
            ?.map((e) => CardComponent.fromMap(e as Map<String, dynamic>))
            .toList(), // NEW
      );



  @override
  String toString() {
    return 'Component(type: $type, text: $text, format: $format, buttons: $buttons, example: $example, cards: $cards)';
  }
}

class CardComponent {
  List<Component>? components;

  CardComponent({this.components});

  factory CardComponent.fromMap(Map<String, dynamic> data) => CardComponent(
        components: (data['components'] as List<dynamic>?)
            ?.map((e) => Component.fromMap(e as Map<String, dynamic>))
            .toList(),
      );



  @override
  String toString() => 'CardComponent(components: $components)';
}
class Example {
  final List<String>? headerHandle;
  final List<List<String>>? bodyText;

  Example({
    this.headerHandle,
    this.bodyText,
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      headerHandle: json['header_handle'] != null
          ? List<String>.from(json['header_handle'])
          : [],
      bodyText: json['body_text'] != null
          ? List<List<String>>.from(
              json['body_text'].map((x) => List<String>.from(x)))
          : [],
    );
  }
}

class Paging {
  final Cursors? cursors;

  Paging({this.cursors});

  factory Paging.fromJson(Map<String, dynamic> json) {
    return Paging(
      cursors:
          json['cursors'] != null ? Cursors.fromJson(json['cursors']) : null,
    );
  }
}
class Cursors {
  final String? before;
  final String? after;

  Cursors({this.before, this.after});

  factory Cursors.fromJson(Map<String, dynamic> json) {
    return Cursors(
      before: json['before'],
      after: json['after'],
    );
  }
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
