class Employee {
  final String employeeCode;
  final String? employeeNameEnglish;
  final String? employeeNameArabic;
  final String? mobileNo;
  final String? email;
  final String? gender;
  final int? departmentId;
  final String? departmentName;
  final int? designationId;
  final String? designationName;
  final bool isActive;
  final String? location;
  final String? bankCode;
  final String? accountNo;
  final String? nationality;
  final String? iqamaNo;
  final String? passportNo;
  final bool isSaudiNational;
  final DateTime? joinDate;
  final DateTime? resumptionDate;
  final String? empSalesmanCode;

  String get fullName => employeeNameEnglish ?? employeeNameArabic ?? employeeCode;

  Employee({
    required this.employeeCode,
    this.employeeNameEnglish,
    this.employeeNameArabic,
    this.mobileNo,
    this.email,
    this.gender,
    this.departmentId,
    this.departmentName,
    this.designationId,
    this.designationName,
    this.isActive = true,
    this.location,
    this.bankCode,
    this.accountNo,
    this.nationality,
    this.iqamaNo,
    this.passportNo,
    this.isSaudiNational = false,
    this.joinDate,
    this.resumptionDate,
    this.empSalesmanCode,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    final rawResumption = json['resumptionDate'] ?? json['ResumptionDate'] ?? json['resumptiondate'] ?? json['Resumptiondate'];
    return Employee(
      employeeCode: json['employeeCode'] ?? json['EmployeeCode'] ?? '',
      employeeNameEnglish: json['employeeNameEnglish'] ?? json['EmployeeNameEnglish'],
      employeeNameArabic: json['employeeNameArabic'] ?? json['EmployeeNameArabic'],
      mobileNo: json['mobileNo'] ?? json['MobileNo'],
      email: json['email'] ?? json['Email'],
      gender: json['gender'] ?? json['Gender'],
      departmentId: json['departmentId'] ?? json['DepartmentId'],
      departmentName: json['departmentName'] ?? json['DepartmentName'],
      designationId: json['designationId'] ?? json['DesignationId'],
      designationName: json['designationName'] ?? json['DesignationName'],
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
      location: json['location'] ?? json['Location'],
      bankCode: json['bankCode'] ?? json['BankCode'],
      accountNo: json['accountNo'] ?? json['AccountNo'],
      nationality: json['nationality'] ?? json['Nationality'],
      iqamaNo: json['iqamaNo'] ?? json['IqamaNo'],
      passportNo: json['passportNo'] ?? json['PassportNo'],
      isSaudiNational: json['isSaudiNational'] ?? json['IsSaudiNational'] ?? false,
      joinDate: json['joinDate'] != null
          ? DateTime.tryParse(json['joinDate'].toString())
          : (json['JoinDate'] != null ? DateTime.tryParse(json['JoinDate'].toString()) : null),
      resumptionDate: rawResumption != null ? DateTime.tryParse(rawResumption.toString()) : null,
      empSalesmanCode: json['empSalesmanCode'] ?? json['EmpSalesmanCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeCode': employeeCode,
      'employeeNameEnglish': employeeNameEnglish,
      'employeeNameArabic': employeeNameArabic,
      'mobileNo': mobileNo,
      'email': email,
      'gender': gender,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'designationId': designationId,
      'designationName': designationName,
      'isActive': isActive,
      'location': location,
      'bankCode': bankCode,
      'accountNo': accountNo,
      'nationality': nationality,
      'iqamaNo': iqamaNo,
      'passportNo': passportNo,
      'isSaudiNational': isSaudiNational,
      'joinDate': joinDate?.toIso8601String(),
      'resumptionDate': resumptionDate?.toIso8601String(),
      'empSalesmanCode': empSalesmanCode,
    };
  }
}
