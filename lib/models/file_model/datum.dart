import 'dart:convert';

class Datum {
  String? messaging_product;
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
  String? data;
  String? file;

  Datum({
    this.messaging_product,
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
    this.data,
    this.file,
  });

  factory Datum.fromMap(Map<String, dynamic> data) => Datum(
        id: data['id'] as String?,
        title: data['title'] as String?,
        filetype: data['filetype'] as String?,
        filesize: data['filesize'] as String?,
        createddate: data['createddate'] == null
            ? null
            : DateTime.parse(data['createddate'] as String),
        createdbyid: data['createdbyid'] as String?,
        description: data['description'] as String?,
        parentid: data['parentid'] as String?,
        lastmodifieddate: data['lastmodifieddate'] == null
            ? null
            : DateTime.parse(data['lastmodifieddate'] as String),
        lastmodifiedbyid: data['lastmodifiedbyid'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'filetype': filetype,
        'filesize': filesize,
        'createddate': createddate?.toIso8601String(),
        'createdbyid': createdbyid,
        'description': description,
        'parentid': parentid,
        'lastmodifieddate': lastmodifieddate?.toIso8601String(),
        'lastmodifiedbyid': lastmodifiedbyid,
        'data': data,
        'file': file
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Datum].
  factory Datum.fromJson(String data) {
    return Datum.fromMap(
      json.decode(data) as Map<String, dynamic>,
    );
  }

  /// `dart:convert`
  ///
  /// Converts [Datum] to a JSON string.
  String toJson() => json.encode(toMap());
}
