import 'package:get/get.dart';
import '../../core/api/api_client.dart';
import '../models/api_response.dart';
import '../models/paged_api_response.dart';
import '../models/customer.dart';

class CustomerRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // 1. Get Customers List (Paginated + Optional Search)
  Future<PagedApiResponse<Customer>> getCustomers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? salespersonCode,
    String? sortColumn,
    String? sortDirection,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'PageNumber': page,
      'PageSize': pageSize,
    };

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParameters['SearchQuery'] = searchQuery.trim();
    }

    if (salespersonCode != null && salespersonCode.trim().isNotEmpty) {
      queryParameters['SalespersonCode'] = salespersonCode.trim();
    }

    if (sortColumn != null && sortColumn.trim().isNotEmpty) {
      queryParameters['SortColumn'] = sortColumn.trim();
    }

    if (sortDirection != null && sortDirection.trim().isNotEmpty) {
      queryParameters['SortDirection'] = sortDirection.trim();
    }

    final response = await _apiClient.get(
      '/customers',
      queryParameters: queryParameters,
    );

    return PagedApiResponse<Customer>.fromJson(
      response.data,
      (json) => Customer.fromJson(json),
    );
  }

  // 2. Get Single Customer Details by Customer Number
  Future<ApiResponse<Customer>> getCustomerByNo(String customerNo) async {
    final response = await _apiClient.get('/customers/$customerNo');
    
    return ApiResponse<Customer>.fromJson(
      response.data,
      (json) => Customer.fromJson(json),
    );
  }

  // 3. Create Customer
  Future<ApiResponse<Customer>> createCustomer(Customer customer) async {
    final response = await _apiClient.post(
      '/customers',
      data: customer.toJson(),
    );

    return ApiResponse<Customer>.fromJson(
      response.data,
      (json) => Customer.fromJson(json),
    );
  }

  // 4. Update Customer
  Future<ApiResponse<Customer>> updateCustomer(
    String customerNo,
    Customer customer,
  ) async {
    final response = await _apiClient.put(
      '/customers/$customerNo',
      data: customer.toJson(),
    );

    return ApiResponse<Customer>.fromJson(
      response.data,
      (json) => Customer.fromJson(json),
    );
  }

  // 5. Delete Customer
  Future<ApiResponse<bool>> deleteCustomer(String customerNo) async {
    final response = await _apiClient.delete('/customers/$customerNo');

    return ApiResponse<bool>.fromJson(
      response.data,
      (json) => json as bool? ?? true,
    );
  }

  // 6. Get Customer Aging Details
  Future<ApiResponse<Map<String, dynamic>>> getCustomerAging(String customerNo) async {
    final response = await _apiClient.get('/customer-aging/$customerNo');
    
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => Map<String, dynamic>.from(json as Map),
    );
  }

  // 7. Get Customers by Aging Bucket
  Future<ApiResponse<List<Map<String, dynamic>>>> getCustomersByBucket(String bucketName) async {
    final response = await _apiClient.get('/customer-aging/bucket/$bucketName');
    
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data,
      (json) => (json as List).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    );
  }
}
