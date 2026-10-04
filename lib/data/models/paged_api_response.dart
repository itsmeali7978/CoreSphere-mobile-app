class PagedApiResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final List<String>? errors;

  PagedApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    this.errors,
  });

  factory PagedApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawData = json['data'] ?? json['Data'];
    final List<dynamic>? list = rawData is List ? rawData : null;
    final List<T> items = list != null
        ? list.map((item) => fromJsonT(item as Map<String, dynamic>)).toList()
        : <T>[];

    return PagedApiResponse<T>(
      success: json['success'] as bool? ?? json['Success'] as bool? ?? true,
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: items,
      pageNumber: json['pageNumber'] as int? ?? json['PageNumber'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? json['PageSize'] as int? ?? 10,
      totalRecords: json['totalRecords'] as int? ?? json['TotalRecords'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? json['TotalPages'] as int? ?? 0,
      errors: (json['errors'] ?? json['Errors']) != null ? List<String>.from(json['errors'] ?? json['Errors']) : null,
    );
  }
}
