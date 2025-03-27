import 'dart:convert';

class Record {
  String? messageHistoryId;
  String? id;
  String? parentId;
  String? name;
  String? messageTemplateId;
  String? whatsappNumber;
  String? message;
  String? status;
  String? recordtypename;
  dynamic fileId;
  String? createdbyid;
  String? lastmodifiedbyid;
  DateTime? createddate;
  DateTime? lastmodifieddate;
  bool? isRead;
  String? businessNumber;
  String? messageId;
  String? deliveryStatus;
  String? chatmsg;
  String? templateName;
  String? templateId;
  String? language;
  String? category;
  String? header;
  String? headerBody;
  String? messageBody;
  String? exampleBodyText;
  String? footer;
  String? messagingProduct;
  String? recipientType;
  String? to;
  String? type;
  String? text;
  String? identifier;
  String? title;
  String? body;
  String? unread_msg_count;
  String? erormessage;
  List<dynamic>? buttons;
  dynamic filetype;
  dynamic description;

  Record(
      {this.messageHistoryId,
      this.id,
      this.parentId,
      this.name,
      this.messageTemplateId,
      this.whatsappNumber,
      this.message,
      this.status,
      this.recordtypename,
      this.fileId,
      this.createdbyid,
      this.lastmodifiedbyid,
      this.createddate,
      this.lastmodifieddate,
      this.isRead,
      this.businessNumber,
      this.messageId,
      this.deliveryStatus,
      this.chatmsg,
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
      this.title,
      this.filetype,
      this.description,
      this.messagingProduct,
      this.recipientType,
      this.to,
      this.type,
      this.text,
      this.identifier,
      this.body,
      this.unread_msg_count,
      this.erormessage});

  factory Record.fromMap(Map<String, dynamic> data) => Record(
        messageHistoryId: data['message_history_id'] as String?,
        id: data['id'] as String?,
        parentId: data['parent_id'] as String?,
        name: data['name'] as String?,
        messageTemplateId: data['message_template_id'] as String?,
        whatsappNumber: data['whatsapp_number'] as String?,
        message: data['message'] as String?,
        status: data['status'] as String?,
        recordtypename: data['recordtypename'] as String?,
        fileId: data['file_id'] as dynamic,
        createdbyid: data['createdbyid'] as String?,
        lastmodifiedbyid: data['lastmodifiedbyid'] as String?,
        createddate: parseDate(data['createddate'] as String?),
        lastmodifieddate: parseDate(data['lastmodifieddate'] as String?),
        isRead: data['is_read'] as bool?,
        businessNumber: data['business_number'] as String?,
        messageId: data['message_id'] as String?,
        deliveryStatus: data['delivery_status'] as String?,
        chatmsg: data['chatmsg'] as String?,
        templateName: data['template_name'] as String?,
        templateId: data['template_id'] as String?,
        language: data['language'] as String?,
        category: data['category'] as String?,
        header: data['header'] as String?,
        headerBody: data['header_body'] as String?,
        messageBody: data['message_body'] as String?,
        exampleBodyText: data['example_body_text'] as String?,
        footer: data['footer'] as String?,
        messagingProduct: data['messaging_product'] as String?,
        recipientType: data['recipient_type'] as String?,
        to: data['to'] as String?,
        type: data['type'] as String?,
        identifier: data['identifier'],
        title: data['title'],
        body: data['body'],
        unread_msg_count: data['unread_msg_count'],
        buttons: data['buttons'] as List<dynamic>?,
        filetype: data['filetype'] as dynamic,
        description: data['description'] as dynamic,
        erormessage: data['err_message'] as String?,
      );

  static DateTime? parseDate(String? date) {
    try {
      return date == null ? null : DateTime.parse(date);
    } catch (e) {
      print("Error parsing date: $e");
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
        'message_history_id': messageHistoryId,
        'id': id,
        'parent_id': parentId,
        'name': name,
        'message_template_id': messageTemplateId,
        'whatsapp_number': whatsappNumber,
        'message': message,
        'status': status,
        'recordtypename': recordtypename,
        'file_id': fileId,
        'createdbyid': createdbyid,
        'lastmodifiedbyid': lastmodifiedbyid,
        'createddate': createddate?.toIso8601String(),
        'lastmodifieddate': lastmodifieddate?.toIso8601String(),
        'is_read': isRead,
        'business_number': businessNumber,
        'message_id': messageId,
        'delivery_status': deliveryStatus,
        'chatmsg': chatmsg,
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
        'title': title,
        'filetype': filetype,
        'description': description,
        'identifier': identifier,
        'title': title,
        'body': body,
        'unread_msg_count': unread_msg_count,
        'erormessage': erormessage,
      };

  String toJson() => json.encode(toMap());
}
