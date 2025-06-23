class BalanceModel {
  String? id;
  String? availableCredits;
  String? totalCredited;
  String? totalDebited;
  String? lastRechargedOn;
  String? createdDate;
  String? lastModifiedDate;
  String? tenantCode;

  BalanceModel({
    this.id,
    this.availableCredits,
    this.totalCredited,
    this.totalDebited,
    this.lastRechargedOn,
    this.createdDate,
    this.lastModifiedDate,
    this.tenantCode,
  });

  BalanceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    availableCredits = json['available_credits'] ?? "";
    totalCredited = json['total_credited'] ?? "";
    totalDebited = json['total_debited'] ?? "";
    lastRechargedOn = json['last_recharged_on'] ?? "";
    createdDate = json['createddate'] ?? "";
    lastModifiedDate = json['lastmodifieddate'] ?? "";
    tenantCode = json['tenantcode'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'available_credits': availableCredits,
      'total_credited': totalCredited,
      'total_debited': totalDebited,
      'last_recharged_on': lastRechargedOn,
      'createddate': createdDate,
      'lastmodifieddate': lastModifiedDate,
      'tenantcode': tenantCode,
    };
  }
}
