import 'dart:convert';

class Record {
  String? campaignId;
  String? campaignName;
  String? templateName;
  String? campaignType;
  String? campaignStatus;
  DateTime? startDate;
  String? createdbyid;
  dynamic groups;
  String? fileId;
  String? fileTitle;
  String? fileType;
  String? fileSize;
  String? fileDescription;

  Record({
    this.campaignId,
    this.campaignName,
    this.templateName,
    this.campaignType,
    this.campaignStatus,
    this.startDate,
    this.createdbyid,
    this.groups,
    this.fileId,
    this.fileTitle,
    this.fileType,
    this.fileSize,
    this.fileDescription,
  });

  factory Record.fromMap(Map<String, dynamic> data) => Record(
        campaignId: data['campaign_id'] as String?,
        campaignName: data['campaign_name'] as String?,
        templateName: data['template_name'] as String?,
        campaignType: data['campaign_type'] as String?,
        campaignStatus: data['campaign_status'] as String?,
        startDate: data['start_date'] == null
            ? null
            : DateTime.parse(data['start_date'] as String),
        createdbyid: data['createdbyid'] as String?,
        groups: data['groups'] as dynamic,
        fileId: data['file_id'] as String?,
        fileTitle: data['file_title'] as String?,
        fileType: data['file_type'] as String?,
        fileSize: data['file_size'] as String?,
        fileDescription: data['file_description'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'campaign_id': campaignId,
        'campaign_name': campaignName,
        'template_name': templateName,
        'campaign_type': campaignType,
        'campaign_status': campaignStatus,
        'start_date': startDate?.toIso8601String(),
        'createdbyid': createdbyid,
        'groups': groups,
        'file_id': fileId,
        'file_title': fileTitle,
        'file_type': fileType,
        'file_size': fileSize,
        'file_description': fileDescription,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Record].
  factory Record.fromJson(String data) {
    return Record.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Record] to a JSON string.
  String toJson() => json.encode(toMap());
}
