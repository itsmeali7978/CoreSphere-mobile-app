import 'request_approval_history.dart';

class ApprovalRequest {
  final int requestId;
  final String requestNo;
  final int requestTypeId;
  final String requestTypeName;
  final String employeeCode;
  final String employeeName;
  final String subject;
  final String? description;
  final String status;
  final String statusDisplayName;
  final int currentLevel;
  final String? currentApproverEmployeeCode;
  final String? currentApproverName;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? leaveDays;
  final String? attachmentUrl;
  final List<DateTime>? selectedDates;
  final List<String>? attachmentUrls;
  final DateTime createdDate;
  final DateTime? completedDate;
  final int? daysSinceLastVacation;
  final String? employeeNameArabic;
  final String? iqamaNo;
  final DateTime? joinDate;
  final DateTime? resumptionDate;
  final List<RequestApprovalHistory> approvalHistory;

  ApprovalRequest({
    required this.requestId,
    required this.requestNo,
    required this.requestTypeId,
    required this.requestTypeName,
    required this.employeeCode,
    required this.employeeName,
    required this.subject,
    this.description,
    required this.status,
    required this.statusDisplayName,
    required this.currentLevel,
    this.currentApproverEmployeeCode,
    this.currentApproverName,
    this.startDate,
    this.endDate,
    this.leaveDays,
    this.attachmentUrl,
    this.selectedDates,
    this.attachmentUrls,
    required this.createdDate,
    this.completedDate,
    this.daysSinceLastVacation,
    this.employeeNameArabic,
    this.iqamaNo,
    this.joinDate,
    this.resumptionDate,
    this.approvalHistory = const [],
  });

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) {
    final rawResumption = json['resumptionDate'] ?? json['ResumptionDate'] ?? json['resumptiondate'] ?? json['Resumptiondate'];
    final rawJoin = json['joinDate'] ?? json['JoinDate'] ?? json['joindate'] ?? json['Joindate'];
    return ApprovalRequest(
      requestId: json['requestId'] ?? 0,
      requestNo: json['requestNo'] ?? '',
      requestTypeId: json['requestTypeId'] ?? 0,
      requestTypeName: json['requestTypeName'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      employeeName: json['employeeName'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'Pending',
      statusDisplayName: json['statusDisplayName'] ?? json['status'] ?? 'Pending',
      currentLevel: json['currentLevel'] ?? 0,
      currentApproverEmployeeCode: json['currentApproverEmployeeCode'],
      currentApproverName: json['currentApproverName'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      leaveDays: json['leaveDays'] != null ? (json['leaveDays'] as num).toDouble() : null,
      attachmentUrl: json['attachmentUrl'],
      selectedDates: (json['selectedDates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList(),
      attachmentUrls: (json['attachmentUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate']) : DateTime.now(),
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
      daysSinceLastVacation: json['daysSinceLastVacation'] ?? json['DaysSinceLastVacation'],
      employeeNameArabic: json['employeeNameArabic'] ?? json['EmployeeNameArabic'],
      iqamaNo: json['iqamaNo'] ?? json['IqamaNo'],
      joinDate: rawJoin != null ? DateTime.tryParse(rawJoin.toString()) : null,
      resumptionDate: rawResumption != null ? DateTime.tryParse(rawResumption.toString()) : null,
      approvalHistory: (json['approvalHistory'] as List<dynamic>?)
              ?.map((e) => RequestApprovalHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
