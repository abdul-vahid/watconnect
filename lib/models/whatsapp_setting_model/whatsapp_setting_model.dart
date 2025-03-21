import 'dart:convert';
import 'package:whatsapp/core/models/base_model.dart';
import 'record.dart'; // Import the Record class

class WhatsappSettingModel extends BaseModel {
  bool? success;
  List<Record>? record; 
  // Constructor
  WhatsappSettingModel({this.success, this.record});

  // Factory constructor to map JSON to the WhatsappSettingModel object
  factory WhatsappSettingModel.fromMap(Map<String, dynamic> data) {
    return WhatsappSettingModel(
      success: data['success'] as bool?,
      record: (data['record'] as List<dynamic>?)
          ?.map((e) => Record.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  WhatsappSettingModel fromMap(Map<String, dynamic> data) {
    return WhatsappSettingModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        'success': success,
        'records': record
            ?.map((e) => e.toMap())
            .toList(), // Use `records` instead of `record`
      };

  // Parsing from JSON string
  @override
  factory WhatsappSettingModel.fromJson(String data) {
    return WhatsappSettingModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  // Converts to JSON string
  String toJson() => json.encode(toMap());
}
