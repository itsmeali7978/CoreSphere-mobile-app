import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/api/api_client.dart';
import '../../core/services/logger_service.dart';
import '../models/api_response.dart';
import '../models/paged_api_response.dart';
import '../models/customer_payment_receipt.dart';

class PaymentReceiptRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final AppLogger _logger = Get.find<AppLogger>();

  static const String _baseEndpoint = '/customerpaymentreceipts';

  /// Fetches paginated receipt list with optional search query, status, and employee filter
  Future<PagedApiResponse<CustomerPaymentReceipt>> getReceipts({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    int? status,
    String? employeeCode,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'PageNumber': page,
        'PageSize': pageSize,
      };

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        queryParams['SearchQuery'] = searchQuery.trim();
      }

      if (status != null) {
        queryParams['status'] = status;
      }

      if (employeeCode != null && employeeCode.trim().isNotEmpty) {
        queryParams['employeeCode'] = employeeCode.trim();
      }

      final response = await _apiClient.get(_baseEndpoint, queryParameters: queryParams);
      
      return PagedApiResponse<CustomerPaymentReceipt>.fromJson(
        response.data,
        (json) => CustomerPaymentReceipt.fromJson(json),
      );
    } catch (e, stack) {
      _logger.error('Failed to fetch payment receipts list', e.toString(), stack);
      return PagedApiResponse<CustomerPaymentReceipt>(
        success: false,
        message: 'Failed to load receipt records from server.',
        data: [],
        pageNumber: page,
        pageSize: pageSize,
        totalRecords: 0,
        totalPages: 0,
      );
    }
  }

  /// Fetches a single receipt by ID
  Future<ApiResponse<CustomerPaymentReceipt>> getReceiptById(int id) async {
    try {
      final response = await _apiClient.get('$_baseEndpoint/$id');
      return ApiResponse<CustomerPaymentReceipt>.fromJson(
        response.data,
        (json) => CustomerPaymentReceipt.fromJson(json),
      );
    } catch (e, stack) {
      _logger.error('Failed to fetch payment receipt details for ID $id', e.toString(), stack);
      return ApiResponse<CustomerPaymentReceipt>(
        success: false,
        message: 'Failed to load payment receipt details.',
      );
    }
  }

  /// Creates a new receipt (Receipt number is generated exclusively by the backend API)
  Future<ApiResponse<CustomerPaymentReceipt>> createReceipt({
    required String customerNo,
    required String employeeCode,
    required DateTime receiptDate,
    required double amount,
    required String paymentMethodCode,
    String? referenceNo,
    String? remarks,
    String paymentAgainst = 'Partial Payment',
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'customerNo': customerNo,
        'employeeCode': employeeCode,
        'receiptDate': receiptDate.toUtc().toIso8601String(),
        'amount': amount,
        'paymentMethodCode': paymentMethodCode,
        'referenceNo': referenceNo,
        'remarks': remarks,
        'paymentAgainst': paymentAgainst,
      };

      final response = await _apiClient.post(_baseEndpoint, data: requestBody);

      return ApiResponse<CustomerPaymentReceipt>.fromJson(
        response.data,
        (json) => CustomerPaymentReceipt.fromJson(json),
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        try {
          return ApiResponse<CustomerPaymentReceipt>.fromJson(
            e.response!.data,
            (json) => CustomerPaymentReceipt.fromJson(json),
          );
        } catch (_) {}
      }
      return ApiResponse<CustomerPaymentReceipt>(
        success: false,
        message: 'Failed to create payment receipt. Please check inputs.',
      );
    } catch (e, stack) {
      _logger.error('Failed to create payment receipt', e.toString(), stack);
      return ApiResponse<CustomerPaymentReceipt>(
        success: false,
        message: 'A connection error occurred while creating receipt.',
      );
    }
  }

  /// Marks a payment receipt as received (Status = 1)
  Future<ApiResponse<CustomerPaymentReceipt>> receivePayment(int id, {String? collectedBy}) async {
    try {
      final response = await _apiClient.post(
        '$_baseEndpoint/$id/receive',
        data: {'collectedBy': collectedBy},
      );

      return ApiResponse<CustomerPaymentReceipt>.fromJson(
        response.data,
        (json) => CustomerPaymentReceipt.fromJson(json),
      );
    } catch (e, stack) {
      _logger.error('Failed to mark payment as received for ID $id', e.toString(), stack);
      return ApiResponse<CustomerPaymentReceipt>(
        success: false,
        message: 'Failed to mark payment as received.',
      );
    }
  }
}
