class TemplateStatsModel {
  int? pending;
  int? approved;
  int? rejected;
  String? sObjectName;

  TemplateStatsModel({
    this.pending,
    this.approved,
    this.rejected,
    this.sObjectName,
  });

  TemplateStatsModel.fromJson(Map<String, dynamic> json) {
    pending = json['PENDING'] ?? 0;
    approved = json['APPROVED'] ?? 0;
    rejected = json['REJECTED'] ?? 0;
    sObjectName = json['SObjectName'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      'PENDING': pending,
      'APPROVED': approved,
      'REJECTED': rejected,
      'SObjectName': sObjectName,
    };
  }
}

class CampaignStatsModel {
  int? completed;
  int? pending;
  int? inProgress;
  String? sObjectName;

  CampaignStatsModel({
    this.completed,
    this.pending,
    this.inProgress,
    this.sObjectName,
  });

  CampaignStatsModel.fromJson(Map<String, dynamic> json) {
    completed = json['Completed'] ?? 0;
    pending = json['Pending'] ?? 0;
    inProgress = json['In Progress'] ?? 0;
    sObjectName = json['SObjectName'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      'Completed': completed,
      'Pending': pending,
      'In Progress': inProgress,
      'SObjectName': sObjectName,
    };
  }
}
