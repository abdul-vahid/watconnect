class HomeSummaryModel {
  bool? success;
  HomeSummaryData? data;

  HomeSummaryModel({this.success, this.data});

  factory HomeSummaryModel.fromJson(Map<String, dynamic> json) {
    return HomeSummaryModel(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? HomeSummaryData.fromJson(json['data'])
          : null,
    );
  }
}

class HomeSummaryData {
  int? leadCount;
  CampaignStatus? campaignStatus;
  TemplateCategoryCount? templateCategoryCount;

  HomeSummaryData({
    this.leadCount,
    this.campaignStatus,
    this.templateCategoryCount,
  });

  factory HomeSummaryData.fromJson(Map<String, dynamic> json) {
    return HomeSummaryData(
      leadCount: json['leadCount'] ?? 0,
      campaignStatus: json['campaignStatus'] != null
          ? CampaignStatus.fromJson(json['campaignStatus'])
          : null,
      templateCategoryCount: json['templateCategoryCount'] != null
          ? TemplateCategoryCount.fromJson(json['templateCategoryCount'])
          : null,
    );
  }
}

class CampaignStatus {
  int? pending;
  int? inProgress;
  int? completed;
  int? aborted;

  CampaignStatus({
    this.pending,
    this.inProgress,
    this.completed,
    this.aborted,
  });

  factory CampaignStatus.fromJson(Map<String, dynamic> json) {
    return CampaignStatus(
      pending: json['Pending'] ?? 0,
      inProgress: json['In Progress'] ?? 0,
      completed: json['Completed'] ?? 0,
      aborted: json['Aborted'] ?? 0,
    );
  }
}

class TemplateCategoryCount {
  int? marketing;
  int? utility;

  TemplateCategoryCount({
    this.marketing,
    this.utility,
  });

  factory TemplateCategoryCount.fromJson(Map<String, dynamic> json) {
    return TemplateCategoryCount(
      marketing: json['Marketing'] ?? 0,
      utility: json['Utility'] ?? 0,
    );
  }
}