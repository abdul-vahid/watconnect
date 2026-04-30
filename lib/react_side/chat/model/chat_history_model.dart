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
  final List<ChatButton>? buttons;// Changed from dynamic to List<dynamic>?
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
  final Map<String, dynamic>? bodyTextParams;  // Changed from dynamic to Map?
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
      messageHistoryId: json['message_history_id'] as String?,
      id: json['id'] as String?,
      parentId: json['parent_id'] as String?,
      name: json['name'] as String?,
      messageTemplateId: json['message_template_id'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String?,
      recordTypeName: json['recordtypename'] as String?,
      fileId: json['file_id'] as String?,
      createdById: json['createdbyid'] as String?,
      lastModifiedById: json['lastmodifiedbyid'] as String?,
      createdDate: json['createddate'] as String?,
      lastModifiedDate: json['lastmodifieddate'] as String?,
      isRead: json['is_read'] as bool?,
      businessNumber: json['business_number'] as String?,
      messageId: json['message_id'] as String?,
      deliveryStatus: json['delivery_status'] as String?,
      errMessage: json['err_message'] as String?,
      receivedTime: json['received_time'] as String?,
      interactiveId: json['interactive_id'] as String?,
      clicked: json['clicked'] as bool?,
      adId: json['ad_id'] as String?,
      contextId: json['context_id'] as String?,
      chatMsg: json['chatmsg'] as String?,
      adPlatform: json['ad_platform'] as String?,
      adUrl: json['ad_url'] as String?,
      adHeadline: json['ad_headline'] as String?,
      adBody: json['ad_body'] as String?,
      adMediaUrl: json['ad_media_url'] as String?,
      adMediaType: json['ad_media_type'] as String?,
      adFileUrl: json['ad_file_url'] as String?,
      templateName: json['template_name'] as String?,
      templateId: json['template_id'] as String?,
      language: json['language'] as String?,
      category: json['category'] as String?,
      header: json['header'] as String?,
      headerBody: json['header_body'] as String?,
      messageBody: json['message_body'] as String?,
      exampleBodyText: json['example_body_text'] as String?,
      footer: json['footer'] as String?,
      buttons: json['buttons'] != null
    ? List<ChatButton>.from(
        json['buttons'].map((x) => ChatButton.fromJson(x)),
      )
    : null,
      templateCards: json['template_cards'],
      templateType: json['template_type'] as String?,
      title: json['title'] as String?,
      fileType: json['filetype'] as String?,
      description: json['description'] as String?,
      headerType: json['header_type'] as String?,
      headerContent: json['header_content'] as String?,
      bodyText: json['body_text'] as String?,
      footerText: json['footer_text'] as String?,
      interactiveButtons: json['interactive_buttons'],
      sections: json['sections'],
      interactiveName: json['interactive_name'] as String?,
      interactiveType: json['interactive_type'] as String?,
      interactiveFileId: json['interactive_file_id'] as String?,
      interactiveFileTitle: json['interactive_file_title'] as String?,
      interactiveFileType: json['interactive_file_type'] as String?,
      contextMessage: json['context_message'] as String?,
      contextMessageId: json['context_message_id'] as String?,
      paramsFileId: json['params_file_id'] as String?,
      paramsFileIds: json['params_file_ids'],
      bodyTextParams: json['body_text_params'] as Map<String, dynamic>?,
      paramFileDetails: json['param_file_details'] as List<dynamic>? ?? [],
      campaignParamsFileId: json['campaign_params_file_id'] as String?,
      campaignFileIds: json['campaign_file_ids'],
      firstName: json['firstname'] as String?,
      lastName: json['lastname'] as String?,
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


class ChatButton {
  final String? text;
  final String? type;
  final String? url;
  final String? phoneNumber;
final List<String>?  example;
  ChatButton({
    this.text,
    this.type,
    this.url,
    this.phoneNumber,
    this.example
  });

  factory ChatButton.fromJson(Map<String, dynamic> json) {
    return ChatButton(
      text: json['text'],
      type: json['type'],
      url: json['url'],
      phoneNumber: json['phone_number'],
      example: json['example'] != null
    ? List<String>.from(json['example'])
    : [],
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'text': text,
  //     'type': type,
  //     'url': url,
  //     'phone_number': phoneNumber,
  //   };
  // }
}