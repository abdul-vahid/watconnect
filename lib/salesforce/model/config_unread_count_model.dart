class SfConfigUnreadCountModel {
  String? name;
  String? id;

  int? unreadCount;

  SfConfigUnreadCountModel({this.name, this.id, this.unreadCount});

  factory SfConfigUnreadCountModel.fromJson(Map<String, dynamic> json) {
    return SfConfigUnreadCountModel(
        name: json['name'] ?? "",
        id: json['id'] ?? "",
        unreadCount: json['unread_count']);
  }
}
