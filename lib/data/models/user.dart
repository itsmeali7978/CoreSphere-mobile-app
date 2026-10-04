class User {
  final int userId;
  final String userName;
  final String employeeCode;
  final String? employeeNameEnglish;
  final String? employeeNameArabic;
  final String? mobileNo;
  final String? email;
  final int? departmentId;
  final String? departmentName;
  final int? designationId;
  final String? designationName;
  final int? roleId;
  final String? roleName;
  final String? empSalesmanCode;
  final String status;
  final String? profileImageUrl;
  final String? nationality;
  final bool? isSaudiNational;
  final int? daysSinceLastVacation;
  final DateTime? resumptionDate;

  User({
    required this.userId,
    required this.userName,
    required this.employeeCode,
    this.employeeNameEnglish,
    this.employeeNameArabic,
    this.mobileNo,
    this.email,
    this.departmentId,
    this.departmentName,
    this.designationId,
    this.designationName,
    this.roleId,
    this.roleName,
    this.empSalesmanCode,
    required this.status,
    this.profileImageUrl,
    this.nationality,
    this.isSaudiNational,
    this.daysSinceLastVacation,
    this.resumptionDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawResumption = json['resumptionDate'] ??
        json['ResumptionDate'] ??
        json['employee']?['resumptionDate'] ??
        json['Employee']?['ResumptionDate'] ??
        json['employee']?['resumptiondate'] ??
        json['Employee']?['Resumptiondate'];

    return User(
      userId: json['userId'] ?? json['UserId'] ?? 0,
      userName: (json['userName'] ?? json['UserName'] ?? '').toString(),
      employeeCode: (json['employeeCode'] ?? json['EmployeeCode'] ?? '').toString(),
      employeeNameEnglish: (json['employeeNameEnglish'] ?? json['EmployeeNameEnglish'])?.toString(),
      employeeNameArabic: (json['employeeNameArabic'] ?? json['EmployeeNameArabic'])?.toString(),
      mobileNo: (json['mobileNo'] ?? json['MobileNo'])?.toString(),
      email: (json['email'] ?? json['Email'])?.toString(),
      departmentId: json['departmentId'] ?? json['DepartmentId'],
      departmentName: (json['departmentName'] ?? json['DepartmentName'])?.toString(),
      designationId: json['designationId'] ?? json['DesignationId'],
      designationName: (json['designationName'] ?? json['DesignationName'])?.toString(),
      roleId: json['roleId'] ?? json['RoleId'],
      roleName: (json['roleName'] ?? json['RoleName'])?.toString(),
      empSalesmanCode: (json['empSalesmanCode'] ?? json['EmpSalesmanCode'])?.toString(),
      status: (json['status'] ?? json['Status'])?.toString() ?? '1',
      profileImageUrl: (json['profileImageUrl'] ?? json['ProfileImageUrl'])?.toString(),
      nationality: (json['nationality'] ?? json['Nationality'] ?? json['employee']?['nationality'] ?? json['Employee']?['Nationality'])?.toString(),
      isSaudiNational: json['isSaudiNational'] ?? json['IsSaudiNational'] ?? json['employee']?['isSaudiNational'] ?? json['Employee']?['IsSaudiNational'],
      daysSinceLastVacation: json['daysSinceLastVacation'] ?? json['DaysSinceLastVacation'] ?? json['employee']?['daysSinceLastVacation'] ?? json['Employee']?['DaysSinceLastVacation'],
      resumptionDate: rawResumption != null ? DateTime.tryParse(rawResumption.toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'employeeCode': employeeCode,
      'employeeNameEnglish': employeeNameEnglish,
      'employeeNameArabic': employeeNameArabic,
      'mobileNo': mobileNo,
      'email': email,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'designationId': designationId,
      'designationName': designationName,
      'roleId': roleId,
      'roleName': roleName,
      'empSalesmanCode': empSalesmanCode,
      'status': status,
      'profileImageUrl': profileImageUrl,
      'nationality': nationality,
      'isSaudiNational': isSaudiNational,
      'daysSinceLastVacation': daysSinceLastVacation,
      'resumptionDate': resumptionDate?.toIso8601String(),
    };
  }
}
