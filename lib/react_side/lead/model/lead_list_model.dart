class LeadListModel {
  final bool? success;
  final List<LeadRecord> records;
  final int total;
  final bool hasMore;

  LeadListModel({
    this.success,
    required this.records,
    required this.total,
    required this.hasMore,
  });

  factory LeadListModel.fromJson(Map<String, dynamic> json) {
  
    return LeadListModel(
      success: json['success'],
      records: json['records'] != null
          ? List<LeadRecord>.from(
              json['records'].map((x) => LeadRecord.fromJson(x)))
          : [],
      total: json['total'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }


}

class LeadRecord {
  final String? id;
  final String? parentId;
  final String? contactName;
  final String? whatsappNumber;
  final String? fullNumber;
  final List<Tag>? tagNames;
  final String? leadId;
  final String? countryCode;
  final bool? isArchived;
  final String? lastMessageTime;
  final bool? pinned;
  final String? message;
  final bool? hasFile;
  final bool? hasTemplate;
  final String? unreadCount;
  final String? ownerId;
  final List<String>? ownerIds;
  final String? createdDate;

  LeadRecord({
    this.id,
    this.parentId,
    this.contactName,
    this.whatsappNumber,
    this.fullNumber,
    this.tagNames,
    this.leadId,
    this.countryCode,
    this.isArchived,
    this.lastMessageTime,
    this.pinned,
    this.message,
    this.hasFile,
    this.hasTemplate,
    this.unreadCount,
    this.ownerId,
    this.ownerIds,
    this.createdDate,
  });

  factory LeadRecord.fromJson(Map<String, dynamic> json) {
    return LeadRecord(
      id: json['id'],
      parentId: json['parent_id'],
      contactName: json['contactname'],
      whatsappNumber: json['whatsapp_number'],
      fullNumber: json['full_number'],
      tagNames: json['tag_names'] != null
          ? List<Tag>.from(json['tag_names'].map((x) => Tag.fromJson(x)))
          : [],
      leadId: json['lead_id'],
      countryCode: json['countrycode'],
      isArchived: json['is_archived'],
      lastMessageTime: json['last_message_time'],
      pinned: json['pinned'],
      message: json['message'],
      hasFile: json['has_file'],
      hasTemplate: json['has_template'],
      unreadCount: json['unread_count'],
      ownerId: json['ownerid'],
      ownerIds: json['ownerids'] != null
          ? List<String>.from(json['ownerids'])
          : [],
      createdDate: json['createddate'],
    );
  }


}

class Tag {
  final String? id;
  final String? name;

  Tag({
    this.id,
    this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
    );
  }


}