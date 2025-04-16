import 'dart:convert';
import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/component.dart';

class Datum {
  String? name;
  String? parameterFormat;
  List<Component>? components;
  String? language;
  String? status;
  String? category;
  String? id;
  int? messageSendTtlSeconds;
  String? subCategory;

  Datum({
    this.name,
    this.parameterFormat,
    this.components,
    this.language,
    this.status,
    this.category,
    this.id,
    this.messageSendTtlSeconds,
    this.subCategory,
  });

  /// ✅ **Fix: Parse `components` properly**
  factory Datum.fromMap(Map<String, dynamic> data) {
    // print("Parsing Datum: ${data['name']}");

    return Datum(
      name: data['name'] as String?,
      parameterFormat: data['parameter_format'] as String?,
      components: (data['components'] != null)
          ? (data['components'] as List)
              .map((e) => Component.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      language: data['language'] as String?,
      status: data['status'] as String?,
      category: data['category'] as String?,
      id: data['id'] as String?,
      messageSendTtlSeconds: data['message_send_ttl_seconds'] as int?,
      subCategory: data['sub_category'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'parameter_format': parameterFormat,
        'components': components?.map((e) => e.toMap()).toList(),
        'language': language,
        'status': status,
        'category': category,
        'id': id,
        'message_send_ttl_seconds': messageSendTtlSeconds,
        'sub_category': subCategory,
      };

  factory Datum.fromJson(String data) {
    return Datum.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Datum(name: $name, parameterFormat: $parameterFormat, language: $language, status: $status, category: $category, id: $id, messageSendTtlSeconds: $messageSendTtlSeconds, subCategory: $subCategory, components: $components)';
  }
}
