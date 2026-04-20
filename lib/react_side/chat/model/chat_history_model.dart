class ChatHistoryModel {
  final bool? success;
  final List<ChatRecord>? records;

  ChatHistoryModel({
    this.success,
    this.records,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      success: json['success'],
      records: json['records'] != null
          ? List<ChatRecord>.from(
              json['records'].map((x) => ChatRecord.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'records': records?.map((x) => x.toJson()).toList(),
    };
  }
}

class ChatRecord {
  final String? messageHistoryId;
  final String? id;
  final String? parentId;
  final String? name;
  final String? messageTemplateId;
  final String? whatsappNumber;
  final String? message;
  final String? status;
  final String? recordTypeName;
  final String? fileId;
  final String? createdById;
  final String? lastModifiedById;
  final String? createdDate;
  final String? lastModifiedDate;
  final bool? isRead;
  final String? businessNumber;
  final String? messageId;
  final String? deliveryStatus;
  final String? errMessage;
  final String? receivedTime;
  final String? interactiveId;
  final bool? clicked;
  final String? adId;
  final String? contextId;
  final String? chatMsg;

  // Ad fields
  final String? adPlatform;
  final String? adUrl;
  final String? adHeadline;
  final String? adBody;
  final String? adMediaUrl;
  final String? adMediaType;
  final String? adFileUrl;

  // Template / media fields
  final String? templateName;
  final String? templateId;
  final String? language;
  final String? category;
  final String? header;
  final String? headerBody;
  final String? messageBody;
  final String? exampleBodyText;
  final String? footer;
  final dynamic buttons;
  final dynamic templateCards;
  final String? templateType;
  final String? title;
  final String? fileType;
  final String? description;

  // Interactive fields
  final String? headerType;
  final String? headerContent;
  final String? bodyText;
  final String? footerText;
  final dynamic interactiveButtons;
  final dynamic sections;
  final String? interactiveName;
  final String? interactiveType;
  final String? interactiveFileId;
  final String? interactiveFileTitle;
  final String? interactiveFileType;

  // Context & params
  final String? contextMessage;
  final String? contextMessageId;
  final String? paramsFileId;
  final dynamic paramsFileIds;
  final dynamic bodyTextParams;
  final List<dynamic>? paramFileDetails;
  final String? campaignParamsFileId;
  final dynamic campaignFileIds;

  final String? firstName;
  final String? lastName;

  ChatRecord({
    this.messageHistoryId,
    this.id,
    this.parentId,
    this.name,
    this.messageTemplateId,
    this.whatsappNumber,
    this.message,
    this.status,
    this.recordTypeName,
    this.fileId,
    this.createdById,
    this.lastModifiedById,
    this.createdDate,
    this.lastModifiedDate,
    this.isRead,
    this.businessNumber,
    this.messageId,
    this.deliveryStatus,
    this.errMessage,
    this.receivedTime,
    this.interactiveId,
    this.clicked,
    this.adId,
    this.contextId,
    this.chatMsg,
    this.adPlatform,
    this.adUrl,
    this.adHeadline,
    this.adBody,
    this.adMediaUrl,
    this.adMediaType,
    this.adFileUrl,
    this.templateName,
    this.templateId,
    this.language,
    this.category,
    this.header,
    this.headerBody,
    this.messageBody,
    this.exampleBodyText,
    this.footer,
    this.buttons,
    this.templateCards,
    this.templateType,
    this.title,
    this.fileType,
    this.description,
    this.headerType,
    this.headerContent,
    this.bodyText,
    this.footerText,
    this.interactiveButtons,
    this.sections,
    this.interactiveName,
    this.interactiveType,
    this.interactiveFileId,
    this.interactiveFileTitle,
    this.interactiveFileType,
    this.contextMessage,
    this.contextMessageId,
    this.paramsFileId,
    this.paramsFileIds,
    this.bodyTextParams,
    this.paramFileDetails,
    this.campaignParamsFileId,
    this.campaignFileIds,
    this.firstName,
    this.lastName,
  });

  factory ChatRecord.fromJson(Map<String, dynamic> json) {
    return ChatRecord(
      messageHistoryId: json['message_history_id'],
      id: json['id'],
      parentId: json['parent_id'],
      name: json['name'],
      messageTemplateId: json['message_template_id'],
      whatsappNumber: json['whatsapp_number'],
      message: json['message'],
      status: json['status'],
      recordTypeName: json['recordtypename'],
      fileId: json['file_id'],
      createdById: json['createdbyid'],
      lastModifiedById: json['lastmodifiedbyid'],
      createdDate: json['createddate'],
      lastModifiedDate: json['lastmodifieddate'],
      isRead: json['is_read'],
      businessNumber: json['business_number'],
      messageId: json['message_id'],
      deliveryStatus: json['delivery_status'],
      errMessage: json['err_message'],
      receivedTime: json['received_time'],
      interactiveId: json['interactive_id'],
      clicked: json['clicked'],
      adId: json['ad_id'],
      contextId: json['context_id'],
      chatMsg: json['chatmsg'],
      adPlatform: json['ad_platform'],
      adUrl: json['ad_url'],
      adHeadline: json['ad_headline'],
      adBody: json['ad_body'],
      adMediaUrl: json['ad_media_url'],
      adMediaType: json['ad_media_type'],
      adFileUrl: json['ad_file_url'],
      templateName: json['template_name'],
      templateId: json['template_id'],
      language: json['language'],
      category: json['category'],
      header: json['header'],
      headerBody: json['header_body'],
      messageBody: json['message_body'],
      exampleBodyText: json['example_body_text'],
      footer: json['footer'],
      buttons: json['buttons'],
      templateCards: json['template_cards'],
      templateType: json['template_type'],
      title: json['title'],
      fileType: json['filetype'],
      description: json['description'],
      headerType: json['header_type'],
      headerContent: json['header_content'],
      bodyText: json['body_text'],
      footerText: json['footer_text'],
      interactiveButtons: json['interactive_buttons'],
      sections: json['sections'],
      interactiveName: json['interactive_name'],
      interactiveType: json['interactive_type'],
      interactiveFileId: json['interactive_file_id'],
      interactiveFileTitle: json['interactive_file_title'],
      interactiveFileType: json['interactive_file_type'],
      contextMessage: json['context_message'],
      contextMessageId: json['context_message_id'],
      paramsFileId: json['params_file_id'],
      paramsFileIds: json['params_file_ids'],
      bodyTextParams: json['body_text_params'],
      paramFileDetails: json['param_file_details'] ?? [],
      campaignParamsFileId: json['campaign_params_file_id'],
      campaignFileIds: json['campaign_file_ids'],
      firstName: json['firstname'],
      lastName: json['lastname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_history_id': messageHistoryId,
      'id': id,
      'parent_id': parentId,
      'name': name,
      'message_template_id': messageTemplateId,
      'whatsapp_number': whatsappNumber,
      'message': message,
      'status': status,
      'recordtypename': recordTypeName,
      'file_id': fileId,
      'createdbyid': createdById,
      'lastmodifiedbyid': lastModifiedById,
      'createddate': createdDate,
      'lastmodifieddate': lastModifiedDate,
      'is_read': isRead,
      'business_number': businessNumber,
      'message_id': messageId,
      'delivery_status': deliveryStatus,
      'err_message': errMessage,
      'received_time': receivedTime,
      'interactive_id': interactiveId,
      'clicked': clicked,
      'ad_id': adId,
      'context_id': contextId,
      'chatmsg': chatMsg,
      'ad_platform': adPlatform,
      'ad_url': adUrl,
      'ad_headline': adHeadline,
      'ad_body': adBody,
      'ad_media_url': adMediaUrl,
      'ad_media_type': adMediaType,
      'ad_file_url': adFileUrl,
      'template_name': templateName,
      'template_id': templateId,
      'language': language,
      'category': category,
      'header': header,
      'header_body': headerBody,
      'message_body': messageBody,
      'example_body_text': exampleBodyText,
      'footer': footer,
      'buttons': buttons,
      'template_cards': templateCards,
      'template_type': templateType,
      'title': title,
      'filetype': fileType,
      'description': description,
      'header_type': headerType,
      'header_content': headerContent,
      'body_text': bodyText,
      'footer_text': footerText,
      'interactive_buttons': interactiveButtons,
      'sections': sections,
      'interactive_name': interactiveName,
      'interactive_type': interactiveType,
      'interactive_file_id': interactiveFileId,
      'interactive_file_title': interactiveFileTitle,
      'interactive_file_type': interactiveFileType,
      'context_message': contextMessage,
      'context_message_id': contextMessageId,
      'params_file_id': paramsFileId,
      'params_file_ids': paramsFileIds,
      'body_text_params': bodyTextParams,
      'param_file_details': paramFileDetails,
      'campaign_params_file_id': campaignParamsFileId,
      'campaign_file_ids': campaignFileIds,
      'firstname': firstName,
      'lastname': lastName,
    };
  }
}