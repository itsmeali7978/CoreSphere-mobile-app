class CompanyInfo {
  final int companyId;
  final String companyCode;
  final String companyName1English;
  final String companyName1Arabic;
  final String? companyName2English;
  final String? companyName2Arabic;
  final String? addressEnglish;
  final String? addressArabic;
  final String? district;
  final String? city;
  final String? postalCode;
  final String? buildingNo;
  final String? country;
  final String? phone;
  final String? email;
  final String? website;
  final String? vatRegistrationNo;
  final String? crNo;
  final String? logoPath;
  final String? logoUrl;

  CompanyInfo({
    required this.companyId,
    required this.companyCode,
    required this.companyName1English,
    required this.companyName1Arabic,
    this.companyName2English,
    this.companyName2Arabic,
    this.addressEnglish,
    this.addressArabic,
    this.district,
    this.city,
    this.postalCode,
    this.buildingNo,
    this.country,
    this.phone,
    this.email,
    this.website,
    this.vatRegistrationNo,
    this.crNo,
    this.logoPath,
    this.logoUrl,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      companyId: json['companyID'] ?? json['companyId'] ?? json['CompanyID'] ?? 1,
      companyCode: json['companyCode'] ?? json['CompanyCode'] ?? 'COMP001',
      companyName1English: json['companyName1English'] ?? json['CompanyName1English'] ?? 'HOUSE CARE STORES',
      companyName1Arabic: json['companyName1Arabic'] ?? json['CompanyName1Arabic'] ?? 'متاجر هاوس كير',
      companyName2English: json['companyName2English'] ?? json['CompanyName2English'] ?? 'Thuijjar Shuttar Trading Company',
      companyName2Arabic: json['companyName2Arabic'] ?? json['CompanyName2Arabic'] ?? 'شركة تجار شطار التجارية',
      addressEnglish: json['addressEnglish'] ?? json['AddressEnglish'],
      addressArabic: json['addressArabic'] ?? json['AddressArabic'],
      district: json['district'] ?? json['District'],
      city: json['city'] ?? json['City'],
      postalCode: json['postalCode'] ?? json['PostalCode'],
      buildingNo: json['buildingNo'] ?? json['BuildingNo'],
      country: json['country'] ?? json['Country'],
      phone: json['phone'] ?? json['Phone'] ?? '+966 56 850 2632',
      email: json['email'] ?? json['Email'] ?? 'accounts@housecare.sa',
      website: json['website'] ?? json['Website'],
      vatRegistrationNo: json['vatRegistrationNo'] ?? json['VatRegistrationNo'] ?? '31107468690003',
      crNo: json['crNo'] ?? json['CrNo'] ?? '4031193218',
      logoPath: json['logoPath'] ?? json['LogoPath'],
      logoUrl: json['logoUrl'] ?? json['LogoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyID': companyId,
      'companyCode': companyCode,
      'companyName1English': companyName1English,
      'companyName1Arabic': companyName1Arabic,
      'companyName2English': companyName2English,
      'companyName2Arabic': companyName2Arabic,
      'addressEnglish': addressEnglish,
      'addressArabic': addressArabic,
      'district': district,
      'city': city,
      'postalCode': postalCode,
      'buildingNo': buildingNo,
      'country': country,
      'phone': phone,
      'email': email,
      'website': website,
      'vatRegistrationNo': vatRegistrationNo,
      'crNo': crNo,
      'logoPath': logoPath,
      'logoUrl': logoUrl,
    };
  }

  static CompanyInfo defaultCompanyInfo() {
    return CompanyInfo(
      companyId: 1,
      companyCode: 'COMP001',
      companyName1English: 'HOUSE CARE STORES',
      companyName1Arabic: 'متاجر هاوس كير',
      companyName2English: 'Thuijjar Shuttar Trading Company',
      companyName2Arabic: 'شركة تجار شطار التجارية',
      vatRegistrationNo: '31107468690003',
      crNo: '4031193218',
      email: 'accounts@housecare.sa',
      phone: '+966 56 850 2632',
    );
  }
}
