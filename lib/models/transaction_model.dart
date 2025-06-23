class TransactionModel {
  String? id;
  String? amount;
  String? type;
  String? reason;
  String? balanceAfter;
  String? createdDate;
  String? status;
  String? tenantCode;

  TransactionModel({
    this.id,
    this.amount,
    this.balanceAfter,
    this.reason,
    this.type,
    this.createdDate,
    this.status,
    this.tenantCode,
  });

  TransactionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    balanceAfter = json['balance_after'] ?? "";
    reason = json['reason'] ?? "";
    type = json['type'] ?? "";
    amount = json['amount'] ?? "";
    createdDate = json['createddate'] ?? "";
    status = json['status'] ?? "";
    tenantCode = json['tenantcode'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'balanceAfter': balanceAfter,
      'reason': reason,
      'type': type,
      'amount': amount,
      'createddate': createdDate,
      'status': status,
      'tenantcode': tenantCode,
    };
  }
}
