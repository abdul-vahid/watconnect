import 'dart:convert';

import 'package:whatsapp/core/models/base_model.dart';

import 'datum.dart';
import 'paging.dart';

class TemplateModel extends BaseModel {
  List<Datum>? data;
  Paging? paging;

  TemplateModel({this.data, this.paging});

  factory TemplateModel.fromMap(Map<String, dynamic> data) => TemplateModel(
        data: (data['data'] as List<dynamic>?)
            ?.map((e) => Datum.fromMap(e as Map<String, dynamic>))
            .toList(),
        paging: data['paging'] == null
            ? null
            : Paging.fromMap(data['paging'] as Map<String, dynamic>),
      );

  @override
  TemplateModel fromMap(Map<String, dynamic> data) {
    return TemplateModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'data': data?.map((e) => e.toMap()).toList(),
        'paging': paging?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [TemplateModel].
  @override
  factory TemplateModel.fromJson(String data) {
    return TemplateModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [TemplateModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
