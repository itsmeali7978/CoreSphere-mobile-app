import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/pending_approvals_controller.dart';
import 'package:intl/intl.dart';

class PendingApprovalsView extends StatelessWidget {
  const PendingApprovalsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PendingApprovalsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('pending_approvals'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchPendingApprovals,
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
                  onPressed: controller.fetchPendingApprovals,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        if (controller.pendingRequests.isEmpty) {
          return Center(child: Text('no_pending_approvals'.tr));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPendingApprovals,
          child: ListView.builder(
            itemCount: controller.pendingRequests.length,
            itemBuilder: (context, index) {
              final request = controller.pendingRequests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(request.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'request_no'.tr}: ${request.requestNo}'),
                      Text('${'employee'.tr}: ${request.employeeName} (${request.employeeCode})'),
                      Text('${'date'.tr}: ${DateFormat('yyyy-MM-dd').format(request.createdDate.toLocal())}'),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(_translateStatus(request.status, request.statusDisplayName), style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.orange.shade100,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  onTap: () async {
                    final result = await Get.toNamed(RouteNames.requestDetails, arguments: request);
                    if (result == true) {
                      controller.fetchPendingApprovals();
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
}
