class CustomerPaymentReceipt {
  final int receiptId;
  final String receiptNo;
  final String customerNo;
  final String? customerName;
  final String? customerName2;
  final String? customerCity;
  final String? customerMobile;
  final String employeeCode;
  final String? collectedBy;
  final DateTime receiptDate;
  final double amount;
  final String paymentMethodCode;
  final String? referenceNo;
  final String? remarks;
  final String paymentAgainst;
  final int status; // 0 = Draft, 1 = Posted, etc.
  final bool erpPosted;
  final DateTime? erpPostedDate;
  final String? navDocumentNo;
  final DateTime createdDate;
  final DateTime updatedDate;

  CustomerPaymentReceipt({
    required this.receiptId,
    required this.receiptNo,
    required this.customerNo,
    this.customerName,
    this.customerName2,
    this.customerCity,
    this.customerMobile,
    required this.employeeCode,
    this.collectedBy,
    required this.receiptDate,
    required this.amount,
    required this.paymentMethodCode,
    this.referenceNo,
    this.remarks,
    this.paymentAgainst = 'Partial Payment',
    required this.status,
    required this.erpPosted,
    this.erpPostedDate,
    this.navDocumentNo,
    required this.createdDate,
    required this.updatedDate,
  });

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    final str = value.toString();
    if (!str.endsWith('Z') && !str.contains('+') && !str.contains('-')) {
      return DateTime.parse('${str}Z');
    }
    return DateTime.parse(str);
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    if (!str.endsWith('Z') && !str.contains('+') && !str.contains('-')) {
      return DateTime.parse('${str}Z');
    }
    return DateTime.parse(str);
  }

  static String _parseString(Map<String, dynamic> json, List<String> keys, {String defaultValue = ''}) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return json[key].toString();
      }
    }
    return defaultValue;
  }

  static String? _parseNullableString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return json[key].toString();
      }
    }
    return null;
  }

  factory CustomerPaymentReceipt.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentReceipt(
      receiptId: json['receiptId'] is int
          ? json['receiptId'] as int
          : (json['ReceiptId'] is int ? json['ReceiptId'] as int : int.parse((json['receiptId'] ?? json['ReceiptId'] ?? 0).toString())),
      receiptNo: _parseString(json, ['receiptNo', 'ReceiptNo']),
      customerNo: _parseString(json, ['customerNo', 'CustomerNo']),
      customerName: _parseNullableString(json, ['customerName', 'CustomerName', 'name', 'Name']),
      customerName2: _parseNullableString(json, ['customerName2', 'CustomerName2', 'name2', 'Name2']),
      customerCity: _parseNullableString(json, ['customerCity', 'CustomerCity']),
      customerMobile: _parseNullableString(json, ['customerMobile', 'CustomerMobile']),
      employeeCode: _parseString(json, [
        'employeeCode',
        'EmployeeCode',
        'employeeId',
        'EmployeeId',
        'salespersonCode',
        'SalespersonCode',
        'collectedBy',
        'CollectedBy'
      ]),
      collectedBy: _parseNullableString(json, ['collectedBy', 'CollectedBy']),
      receiptDate: _parseDateTime(json['receiptDate'] ?? json['ReceiptDate']),
      amount: json['amount'] != null
          ? double.parse(json['amount'].toString())
          : (json['Amount'] != null ? double.parse(json['Amount'].toString()) : 0.0),
      paymentMethodCode: _parseString(json, ['paymentMethodCode', 'PaymentMethodCode']),
      referenceNo: _parseNullableString(json, ['referenceNo', 'ReferenceNo']),
      remarks: _parseNullableString(json, ['remarks', 'Remarks']),
      paymentAgainst: _parseString(json, ['paymentAgainst', 'PaymentAgainst'], defaultValue: 'Partial Payment'),
      status: (json['status'] ?? json['Status']) as int? ?? 0,
      erpPosted: (json['erpPosted'] ?? json['ErpPosted']) as bool? ?? false,
      erpPostedDate: _parseNullableDateTime(json['erpPostedDate'] ?? json['ErpPostedDate']),
      navDocumentNo: _parseNullableString(json, ['navDocumentNo', 'NavDocumentNo']),
      createdDate: _parseDateTime(json['createdDate'] ?? json['CreatedDate']),
      updatedDate: _parseDateTime(json['updatedDate'] ?? json['UpdatedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiptId': receiptId,
      'receiptNo': receiptNo,
      'customerNo': customerNo,
      'customerName': customerName,
      'customerName2': customerName2,
      'customerCity': customerCity,
      'customerMobile': customerMobile,
      'employeeCode': employeeCode,
      'collectedBy': collectedBy,
      'receiptDate': receiptDate.toIso8601String(),
      'amount': amount,
      'paymentMethodCode': paymentMethodCode,
      'referenceNo': referenceNo,
      'remarks': remarks,
      'paymentAgainst': paymentAgainst,
      'status': status,
      'erpPosted': erpPosted,
      'erpPostedDate': erpPostedDate?.toIso8601String(),
      'navDocumentNo': navDocumentNo,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
    };
  }
}
