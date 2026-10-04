class Customer {
  final String customerNo;
  final String name;
  final String? name2;
  final String? address;
  final String? postalCode;
  final String? buildingNo;
  final String? district;
  final String? city;
  final String? mobileNo;
  final String? email;
  final String? vatRegistrationNo;
  final String? contactPersonName;
  final String? salesPersonCode;
  final double? balance;
  final double? creditLimit;

  Customer({
    required this.customerNo,
    required this.name,
    this.name2,
    this.address,
    this.postalCode,
    this.buildingNo,
    this.district,
    this.city,
    this.mobileNo,
    this.email,
    this.vatRegistrationNo,
    this.contactPersonName,
    this.salesPersonCode,
    this.balance,
    this.creditLimit,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerNo: json['customerNo'] ?? '',
      name: json['name'] ?? '',
      name2: json['name2'],
      address: json['address'],
      postalCode: json['postalCode'],
      buildingNo: json['buildingNo'],
      district: json['district'],
      city: json['city'],
      mobileNo: json['mobileNo'],
      email: json['email'],
      vatRegistrationNo: json['vatRegistrationNo'],
      contactPersonName: json['contactPersonName'],
      salesPersonCode: json['salesPersonCode'],
      balance: json['balance']?.toDouble(),
      creditLimit: json['creditLimit']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerNo': customerNo,
      'name': name,
      'name2': name2,
      'address': address,
      'postalCode': postalCode,
      'buildingNo': buildingNo,
      'district': district,
      'city': city,
      'mobileNo': mobileNo,
      'email': email,
      'vatRegistrationNo': vatRegistrationNo,
      'contactPersonName': contactPersonName,
      'salesPersonCode': salesPersonCode,
      'balance': balance,
      'creditLimit': creditLimit,
    };
  }
}
