// ignore: unused_import
import '../../core/apis/app_exception.dart';

class BaseModel {
  BaseModel();
  factory BaseModel.fromMap(Map<String, dynamic> data) {
    return BaseModel();
  }
  factory BaseModel.fromJson(String data) {
    return BaseModel();
  }

  Map<String, dynamic> toMap() => {};

  BaseModel fromMap(Map<String, dynamic> data) {
    return BaseModel.fromMap(data);
  }
}
