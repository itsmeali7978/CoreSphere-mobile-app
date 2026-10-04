class RequestApprovalHistory {
  final int approvalId;
  final int requestId;
  final int levelNo;
  final String? approverEmployeeCode;
  final String? approverName;
  final String action;
  final String? comments;
  final DateTime? actionDate;

  RequestApprovalHistory({
    required this.approvalId,
    required this.requestId,
    required this.levelNo,
    this.approverEmployeeCode,
    this.approverName,
    required this.action,
    this.comments,
    this.actionDate,
  });

  factory RequestApprovalHistory.fromJson(Map<String, dynamic> json) {
    return RequestApprovalHistory(
      approvalId: json['approvalId'] ?? 0,
      requestId: json['requestId'] ?? 0,
      levelNo: json['levelNo'] ?? 0,
      approverEmployeeCode: json['approverEmployeeCode'],
      approverName: json['approverName'],
      action: json['action'] ?? '',
      comments: json['comments'],
      actionDate: json['actionDate'] != null ? DateTime.parse(json['actionDate']) : null,
    );
  }
}
