import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../core/api/api_client.dart';
import '../models/api_response.dart';
import '../models/approval_request.dart';
import '../models/request_type.dart';
import '../models/request_approval_history.dart';

class ApprovalRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Requests API

  Future<ApiResponse<ApprovalRequest>> createRequest(dynamic data) async {
    final response = await _apiClient.post(
      '/Requests',
      data: data,
    );
    return ApiResponse<ApprovalRequest>.fromJson(
      response.data,
      (json) => ApprovalRequest.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<String>> uploadRequestAttachment(dynamic formData) async {
    final response = await _apiClient.post(
      '/Requests/upload-attachment',
      data: formData,
    );
    return ApiResponse<String>.fromJson(
      response.data,
      (json) => json as String,
    );
  }

  Future<ApiResponse<List<String>>> uploadRequestAttachments(dynamic formData) async {
    final response = await _apiClient.post(
      '/Requests/upload-attachments',
      data: formData,
    );
    return ApiResponse<List<String>>.fromJson(
      response.data,
      (json) => (json as List).map((e) => e as String).toList(),
    );
  }

  Future<ApiResponse<List<ApprovalRequest>>> getMyRequests() async {
    final response = await _apiClient.get('/Requests/my-requests');
    return ApiResponse<List<ApprovalRequest>>.fromJson(
      response.data,
      (json) => (json as List).map((e) => ApprovalRequest.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse<ApprovalRequest>> getRequestById(int id) async {
    final response = await _apiClient.get('/Requests/$id');
    return ApiResponse<ApprovalRequest>.fromJson(
      response.data,
      (json) => ApprovalRequest.fromJson(json),
    );
  }

  Future<ApiResponse<List<RequestApprovalHistory>>> getRequestHistory(int id) async {
    final response = await _apiClient.get('/Requests/$id/history');
    return ApiResponse<List<RequestApprovalHistory>>.fromJson(
      response.data,
      (json) => (json as List).map((e) => RequestApprovalHistory.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse<ApprovalRequest>> updateRequestDates(int id, DateTime startDate, DateTime endDate) async {
    final response = await _apiClient.put(
      '/Requests/$id/update-dates',
      data: {
        'requestId': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
    return ApiResponse<ApprovalRequest>.fromJson(
      response.data,
      (json) => ApprovalRequest.fromJson(json),
    );
  }

  // Approvals API

  Future<ApiResponse<List<ApprovalRequest>>> getPendingApprovals() async {
    final response = await _apiClient.get('/Approvals/pending');
    return ApiResponse<List<ApprovalRequest>>.fromJson(
      response.data,
      (json) => (json as List).map((e) => ApprovalRequest.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse<ApprovalRequest>> processApproval(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '/Approvals/process',
      data: data,
    );
    return ApiResponse<ApprovalRequest>.fromJson(
      response.data,
      (json) => ApprovalRequest.fromJson(json),
    );
  }

  Future<ApiResponse<List<RequestType>>> getRequestTypes() async {
    final response = await _apiClient.get('/Approvals/types');
    return ApiResponse<List<RequestType>>.fromJson(
      response.data,
      (json) => (json as List).map((e) => RequestType.fromJson(e)).toList(),
    );
  }
}
