import 'dart:convert';

import '../../core/models/base_model.dart';

class WhatsAppImageModel extends BaseModel {
  String? id;
  String? title;
  String? filetype;
  String? filesize;
  DateTime? createddate;
  String? createdbyid;
  String? description;
  String? parentid;
  DateTime? lastmodifieddate;
  String? lastmodifiedbyid;
  String? createdbyname;
  String? lastmodifiedbyname;

  WhatsAppImageModel({
    this.id,
    this.title,
    this.filetype,
    this.filesize,
    this.createddate,
    this.createdbyid,
    this.description,
    this.parentid,
    this.lastmodifieddate,
    this.lastmodifiedbyid,
    this.createdbyname,
    this.lastmodifiedbyname,
  });

  factory WhatsAppImageModel.fromMap(Map<String, dynamic> data) =>
      WhatsAppImageModel(
        id: data['id']?.toString(),
        title: data['title']?.toString(),
        filetype: data['filetype']?.toString(),
        filesize: data['filesize']?.toString(),
        createddate: data['createddate'] == null
            ? null
            : DateTime.tryParse(data['createddate'].toString()),
        createdbyid: data['createdbyid']?.toString(),
        description: data['description']?.toString(),
        parentid: data['parentid']?.toString(),
        lastmodifieddate: data['lastmodifieddate'] == null
            ? null
            : DateTime.tryParse(data['lastmodifieddate'].toString()),
        lastmodifiedbyid: data['lastmodifiedbyid']?.toString(),
        createdbyname: data['createdbyname']?.toString(),
        lastmodifiedbyname: data['lastmodifiedbyname']?.toString(),
      );
  @override
  WhatsAppImageModel fromMap(Map<String, dynamic> data) {
    return WhatsAppImageModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (filetype != null) 'filetype': filetype,
        if (filesize != null) 'filesize': filesize,
        if (createddate != null) 'createddate': createddate?.toIso8601String(),
        if (createdbyid != null) 'createdbyid': createdbyid,
        if (description != null) 'description': description,
        if (parentid != null) 'parentid': parentid,
        if (lastmodifieddate != null)
          'lastmodifieddate': lastmodifieddate?.toIso8601String(),
        if (lastmodifiedbyid != null) 'lastmodifiedbyid': lastmodifiedbyid,
        if (createdbyname != null) 'createdbyname': createdbyname,
        if (lastmodifiedbyname != null)
          'lastmodifiedbyname': lastmodifiedbyname,
      };

  /// dart:convert
  ///
  /// Parses the string and returns the resulting Json object as [FileModel].
  @override
  factory WhatsAppImageModel.fromJson(String data) {
    return WhatsAppImageModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// dart:convert
  ///
  /// Converts [FileModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
