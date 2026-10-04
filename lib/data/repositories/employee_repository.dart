import 'package:get/get.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/paged_api_response.dart';
import '../models/employee.dart';

class EmployeeRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Fetch paged employees from GET /api/v1.0/employees
  Future<PagedApiResponse<Employee>> getEmployees({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    final queryParams = <String, dynamic>{
      'PageNumber': page,
      'PageSize': pageSize,
    };

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParams['SearchQuery'] = searchQuery.trim();
    }

    final response = await _apiClient.get(
      ApiConstants.employees,
      queryParameters: queryParams,
    );

    return PagedApiResponse<Employee>.fromJson(
      response.data,
      (json) => Employee.fromJson(json),
    );
  }

  /// Fetch single employee by Employee Code from GET /api/v1.0/employees/{employeeCode}
  Future<ApiResponse<Employee>> getEmployeeByCode(String employeeCode) async {
    final response = await _apiClient.get('${ApiConstants.employees}/$employeeCode');

    return ApiResponse<Employee>.fromJson(
      response.data,
      (json) => Employee.fromJson(json),
    );
  }
}
