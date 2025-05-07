import 'dart:convert';

class CloneRecord {
  String? campaignId;
  String? campaignName;
  String? templateName;
  String? campaignType;
  String? campaignStatus;
  DateTime? startDate;
  String? recurrence;

  String? customRecurrenceUnit;
  String? selectedDays;
  String? selectedDate;
  String? recurrenceEndType;
  String? recurrenceEndDate;
  String? createdbyid;
  String? businessNumber;
  String? bodyTextParams;
  String? paramsFileId;
  String? paramsFileTitle;
  String? whatsappNumberAdmin;
  String? groupName;
  List<Map<String, String>>? groups;
  List<Map<String, String>>? lead_ids;
  String? fileId;
  String? fileTitle;
  String? fileType;
  String? fileSize;
  String? fileDescription;

  CloneRecord({
    this.campaignId,
    this.campaignName,
    this.templateName,
    this.campaignType,
    this.campaignStatus,
    this.startDate,
    this.recurrence,
    this.customRecurrenceUnit,
    this.selectedDays,
    this.selectedDate,
    this.recurrenceEndType,
    this.recurrenceEndDate,
    this.createdbyid,
    this.businessNumber,
    this.bodyTextParams,
    this.paramsFileId,
    this.paramsFileTitle,
    this.whatsappNumberAdmin,
    this.groupName,
    this.groups,
    this.lead_ids,
    this.fileId,
    this.fileTitle,
    this.fileType,
    this.fileSize,
    this.fileDescription,
  });

  factory CloneRecord.fromMap(Map<String, dynamic> data) => CloneRecord(
        campaignId: data['campaign_id'] as String?,
        campaignName: data['campaign_name'] as String?,
        templateName: data['template_name'] as String?,
        campaignType: data['campaign_type'] as String?,
        campaignStatus: data['campaign_status'] as String?,
        startDate: data['start_date'] == null
            ? null
            : DateTime.tryParse(data['start_date']),
        recurrence: data['recurrence'] as String?,
        customRecurrenceUnit: data['custom_recurrence_unit'] as String?,
        selectedDays: data['selected_days'] as String?,
        // selectedDate: data['selected_date'] as String?,
        recurrenceEndType: data['recurrence_end_type'] as String?,
        recurrenceEndDate: data['recurrence_end_date'] as String?,
        createdbyid: data['createdbyid'] as String?,
        businessNumber: data['business_number'] as String?,
        bodyTextParams: data['body_text_params'] as String?,
        paramsFileId: data['params_file_id'] as String?,
        paramsFileTitle: data['params_file_title'] as String?,
        whatsappNumberAdmin: data['whatsapp_number_admin'] as String?,
        groupName: data['group_name'] as String?,
        groups: (data['groups'] as List<dynamic>?)
            ?.map((e) => Map<String, String>.from(e as Map))
            .toList(),
        lead_ids: (data['lead_ids'] as List<dynamic>?)
            ?.map((e) => Map<String, String>.from(e as Map))
            .toList(),
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
        'recurrence': recurrence,
        'custom_recurrence_unit': customRecurrenceUnit,
        'selected_days': selectedDays,
        'selected_date': selectedDate,
        'recurrence_end_type': recurrenceEndType,
        'recurrence_end_date': recurrenceEndDate,
        'createdbyid': createdbyid,
        'business_number': businessNumber,
        'body_text_params': bodyTextParams,
        'params_file_id': paramsFileId,
        'params_file_title': paramsFileTitle,
        'whatsapp_number_admin': whatsappNumberAdmin,
        'group_name': groupName,
        'groups': groups,
        'lead_ids': lead_ids,
        'file_id': fileId,
        'file_title': fileTitle,
        'file_type': fileType,
        'file_size': fileSize,
        'file_description': fileDescription,
      };

  factory CloneRecord.fromJson(String data) =>
      CloneRecord.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}
