import 'dart:convert';

import '../../../core/models/base_model.dart';
import 'datum.dart';
import 'paging.dart';

class Aprovedtempltemodeldata extends BaseModel {
  List<Datum>? data;
  Paging? paging;

  Aprovedtempltemodeldata({this.data, this.paging});

  factory Aprovedtempltemodeldata.fromMap(Map<String, dynamic> data) {
    return Aprovedtempltemodeldata(
      data: (data['data'] as List<dynamic>?)
          ?.map((e) => Datum.fromMap(e as Map<String, dynamic>))
          .toList(),
      paging: data['paging'] == null
          ? null
          : Paging.fromMap(data['paging'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'data': data?.map((e) => e.toMap()).toList(),
        'paging': paging?.toMap(),
      };

  @override
  Aprovedtempltemodeldata fromMap(Map<String, dynamic> data) {
    return Aprovedtempltemodeldata.fromMap(data);
  }

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Aprovedtempltemodeldata].
  @override
  factory Aprovedtempltemodeldata.fromJson(String data) {
    return Aprovedtempltemodeldata.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Aprovedtempltemodeldata] to a JSON string.
  String toJson() => json.encode(toMap());
}
