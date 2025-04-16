import 'dart:convert';
import 'component.dart';

class Datum {
  String? name;
  int? messageSendTtlSeconds;
  String? parameterFormat;
  List<Component>? components;
  String? language;
  String? status;
  String? category;
  String? id;

  Datum({
    this.name,
    this.messageSendTtlSeconds,
    this.parameterFormat,
    this.components,
    this.language,
    this.status,
    this.category,
    this.id,
  });

  factory Datum.fromMap(Map<String, dynamic> data) => Datum(
        name: data['name'] as String?,
        messageSendTtlSeconds: data['message_send_ttl_seconds'] as int?,
        parameterFormat: data['parameter_format'] as String?,
        components: (data['components'] is List)
            ? (data['components'] as List)
                .map((e) => Component.fromMap(e as Map<String, dynamic>))
                .toList()
            : [],
        language: data['language'] as String?,
        status: data['status'] as String?,
        category: data['category'] as String?,
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'message_send_ttl_seconds': messageSendTtlSeconds,
        'parameter_format': parameterFormat,
        'components': components?.map((e) => e.toMap()).toList(),
        'language': language,
        'status': status,
        'category': category,
        'id': id,
      };

  factory Datum.fromJson(String data) {
    return Datum.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Datum(name: $name, parameterFormat: $parameterFormat, language: $language, status: $status, category: $category, id: $id, components: ${components?.map((c) => c.toString()).toList()})';
  }
}
