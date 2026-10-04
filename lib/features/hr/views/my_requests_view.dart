import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/my_requests_controller.dart';
import 'package:intl/intl.dart';

class MyRequestsView extends StatelessWidget {
  const MyRequestsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyRequestsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('my_requests'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Get.toNamed(RouteNames.createRequest);
              if (result == true) {
                controller.fetchRequests();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchRequests,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('failed_to_load'.tr),
                ElevatedButton(
                  onPressed: controller.fetchRequests,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        if (controller.requests.isEmpty) {
          return Center(child: Text('no_requests_found'.tr));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchRequests,
          child: ListView.builder(
            itemCount: controller.requests.length,
            itemBuilder: (context, index) {
              final request = controller.requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(request.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'request_no'.tr}: ${request.requestNo}'),
                      Text('${'type'.tr}: ${_translateRequestType(request.requestTypeName)}'),
                      Text('${'date'.tr}: ${DateFormat('yyyy-MM-dd').format(request.createdDate.toLocal())}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(_translateStatus(request.status, request.statusDisplayName)),
                    backgroundColor: _getStatusColor(request.status),
                  ),
                  onTap: () async {
                    final result = await Get.toNamed(RouteNames.requestDetails, arguments: request);
                    if (result == true) {
                      controller.fetchRequests();
                    }
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }

  String _translateRequestType(String typeName) {
    if (typeName.isEmpty) return typeName;
    if (typeName.tr != typeName) return typeName.tr;
    final key = typeName.toLowerCase().replaceAll(' ', '_');
    if (key.tr != key) return key.tr;
    return typeName;
  }

  String _translateStatus(String status, String statusDisplayName) {
    if (statusDisplayName.isNotEmpty && statusDisplayName.tr != statusDisplayName) {
      return statusDisplayName.tr;
    }
    if (status.isNotEmpty && status.tr != status) {
      return status.tr;
    }
    final keyDisplayName = statusDisplayName.toLowerCase().replaceAll(' ', '_');
    if (keyDisplayName.tr != keyDisplayName) {
      return keyDisplayName.tr;
    }
    final keyStatus = status.toLowerCase().replaceAll(' ', '_');
    if (keyStatus.tr != keyStatus) {
      return keyStatus.tr;
    }
    return statusDisplayName;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      case 'pending':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}
