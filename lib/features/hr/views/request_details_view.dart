import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/request_details_controller.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../authentication/controllers/authentication_controller.dart';

import '../../../core/utils/request_export_service.dart';

class RequestDetailsView extends StatelessWidget {
  const RequestDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<RequestDetailsController>()
        ? (Get.find<RequestDetailsController>()..initFromArguments())
        : Get.put(RequestDetailsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('request_details'.tr),
        actions: [
          GetBuilder<RequestDetailsController>(
            builder: (c) {
              return IconButton(
                icon: const Icon(Icons.print_outlined),
                tooltip: 'preview_download_request'.tr,
                onPressed: () => Get.toNamed(
                  RouteNames.requestPreview,
                  arguments: {'request': c.request, 'history': c.history},
                ),
              );
            },
          ),
        ],
      ),
      body: GetBuilder<RequestDetailsController>(
        builder: (c) {
          final req = c.request;

          final currentUser = Get.isRegistered<AuthenticationController>()
              ? Get.find<AuthenticationController>().currentUser.value
              : null;

          final userEmpCode = currentUser?.employeeCode.trim() ?? '';
          final userUsername = currentUser?.userName.trim() ?? '';

          final isSubmitter = (userEmpCode.isNotEmpty && req.employeeCode.trim().toLowerCase() == userEmpCode.toLowerCase()) ||
                              (userUsername.isNotEmpty && req.employeeCode.trim().toLowerCase() == userUsername.toLowerCase());

          final isPendingForMe = req.status.startsWith('PENDING') && 
                                 req.currentApproverEmployeeCode != null &&
                                 req.currentApproverEmployeeCode!.isNotEmpty &&
                                 (userEmpCode.isEmpty ||
                                  req.currentApproverEmployeeCode!.trim().toLowerCase() == userEmpCode.toLowerCase() ||
                                  req.currentApproverEmployeeCode!.trim().toLowerCase() == userUsername.toLowerCase());

          final isHrOrManager = currentUser?.roleName != null && (
              currentUser!.roleName!.toLowerCase().contains('hr') ||
              currentUser.roleName!.toLowerCase().contains('admin') ||
              currentUser.roleName!.toLowerCase().contains('manager') ||
              currentUser.roleName!.toLowerCase().contains('supervisor')
          );

          // Edit option is ONLY for HR/Manager/Workflow Approver reviewing another user's pending request (NOT the request creator!)
          final canEditLeaveDates = req.status.startsWith('PENDING') &&
                                    !isSubmitter &&
                                    (isHrOrManager || isPendingForMe);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(req.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        _buildInfoRow('request_no'.tr, req.requestNo),
                        _buildInfoRow('type'.tr, _translateType(req.requestTypeName)),
                        _buildInfoRow('employee'.tr, '${req.employeeName} (${req.employeeCode})'),
                        _buildInfoRow('date'.tr, DateFormat('yyyy-MM-dd').format(req.createdDate.toLocal())),
                        _buildInfoRow('status'.tr, _translateStatus(req.status, req.statusDisplayName)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                            label: Text('preview_download_request'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => Get.toNamed(
                              RouteNames.requestPreview,
                              arguments: {'request': c.request, 'history': c.history},
                            ),
                          ),
                        ),
                        () {
                          final daysVacation = req.daysSinceLastVacation ?? currentUser?.daysSinceLastVacation;
                          final isAnnual = req.requestTypeName.toLowerCase().contains('annual') ||
                              (req.requestTypeName.toLowerCase().contains('leave') &&
                               !req.requestTypeName.toLowerCase().contains('unpaid') &&
                               !req.requestTypeName.toLowerCase().contains('sick'));
                          if (isAnnual && daysVacation != null && daysVacation < 365) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade400, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'vacation_365_warning'.tr.replaceAll('@days', '$daysVacation'),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }(),
                        if (req.description != null && req.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('description'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(req.description!),
                        ],
                        if (req.startDate != null || req.endDate != null || (req.requestTypeName != null && req.requestTypeName!.toLowerCase().contains('leave'))) ...[
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('leave_details'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (canEditLeaveDates)
                                Obx(() => TextButton.icon(
                                      icon: Icon(c.isEditingDates.value ? Icons.close : Icons.edit_calendar, size: 18),
                                      label: Text(c.isEditingDates.value ? 'cancel'.tr : 'edit_dates'.tr),
                                      onPressed: () {
                                        c.isEditingDates.value = !c.isEditingDates.value;
                                      },
                                    )),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            if (c.isEditingDates.value) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              final picked = await showDatePicker(
                                                context: context,
                                                initialDate: c.editedStartDate.value ?? DateTime.now(),
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime(2030),
                                              );
                                              if (picked != null) {
                                                c.editedStartDate.value = picked;
                                                c.recalculateLeaveDays();
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.grey.shade400),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('start_date'.tr, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    c.editedStartDate.value != null
                                                        ? DateFormat('yyyy-MM-dd').format(c.editedStartDate.value!)
                                                        : 'Select',
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              final picked = await showDatePicker(
                                                context: context,
                                                initialDate: c.editedEndDate.value ?? DateTime.now(),
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime(2030),
                                              );
                                              if (picked != null) {
                                                c.editedEndDate.value = picked;
                                                c.recalculateLeaveDays();
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.grey.shade400),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('end_date'.tr, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    c.editedEndDate.value != null
                                                        ? DateFormat('yyyy-MM-dd').format(c.editedEndDate.value!)
                                                        : 'Select',
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${'leave_days'.tr}: ${c.calculatedLeaveDays.value?.toInt() ?? 0}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: c.isSavingDates.value ? null : () => c.saveEditedDates(),
                                          icon: c.isSavingDates.value
                                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                              : const Icon(Icons.check, size: 16),
                                          label: Text('save'.tr),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Column(
                                children: [
                                  if (c.editedStartDate.value != null) _buildInfoRow('start_date'.tr, DateFormat('yyyy-MM-dd').format(c.editedStartDate.value!.toLocal())),
                                  if (c.editedEndDate.value != null) _buildInfoRow('end_date'.tr, DateFormat('yyyy-MM-dd').format(c.editedEndDate.value!.toLocal())),
                                  if (c.calculatedLeaveDays.value != null && c.calculatedLeaveDays.value! > 0)
                                    _buildInfoRow('leave_days'.tr, c.calculatedLeaveDays.value!.toInt().toString()),
                                ],
                              );
                            }
                          }),
                        ],
                        if (req.selectedDates != null && req.selectedDates!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('selected_dates'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: req.selectedDates!.map((d) => Chip(label: Text(DateFormat('yyyy-MM-dd').format(d.toLocal())))).toList(),
                          )
                        ],
                        if (req.attachmentUrls != null && req.attachmentUrls!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('attachments'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: req.attachmentUrls!.map((url) => ActionChip(
                              avatar: const Icon(Icons.attach_file, size: 16),
                              label: const Text('View Attachment'),
                              onPressed: () async {
                                String fullUrl = url.trim();
                                if (!fullUrl.startsWith('http')) {
                                  final baseUri = Uri.parse(ApiConstants.baseUrl);
                                  final origin = '${baseUri.scheme}://${baseUri.host}:${baseUri.port}';
                                  if (!fullUrl.startsWith('/uploads') && !fullUrl.startsWith('uploads/')) {
                                    fullUrl = fullUrl.startsWith('/') ? '/uploads$fullUrl' : '/uploads/$fullUrl';
                                  }
                                  fullUrl = fullUrl.startsWith('/') ? '$origin$fullUrl' : '$origin/$fullUrl';
                                }
                                final uri = Uri.parse(fullUrl);
                                try {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  Get.snackbar('Error', 'Could not open attachment: $e');
                                }
                              },
                            )).toList(),
                          )
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isPendingForMe) ...[
                  TextField(
                    controller: c.commentsController,
                    decoration: InputDecoration(
                      labelText: 'comments'.tr,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: c.isProcessing.value ? null : () => c.processApproval('Approved'),
                          child: Text('approve'.tr),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: c.isProcessing.value ? null : () => c.processApproval('Rejected'),
                          child: Text('reject'.tr),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                Text('approval_history'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Obx(() {
                  if (c.isLoadingHistory.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (req.approvalHistory.isEmpty) {
                    return Text('no_history'.tr);
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: req.approvalHistory.length,
                    itemBuilder: (context, index) {
                      final h = req.approvalHistory[index];
                      final isLast = index == req.approvalHistory.length - 1;
                      final isPending = h.action == 'PENDING';
                      final isRejected = h.action == 'REJECTED';
                      final isApproved = h.action == 'APPROVED';

                      Color nodeColor = Colors.grey;
                      IconData nodeIcon = Icons.radio_button_unchecked;

                      if (isApproved) {
                        nodeColor = Colors.green;
                        nodeIcon = Icons.check_circle;
                      } else if (isRejected) {
                        nodeColor = Colors.red;
                        nodeIcon = Icons.cancel;
                      } else if (isPending) {
                        nodeColor = Colors.orange;
                        nodeIcon = Icons.hourglass_empty;
                      }

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              children: [
                                Icon(nodeIcon, color: nodeColor),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${'level'.tr} ${h.levelNo}: ${h.action}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: nodeColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${'approver'.tr}: ${h.approverName ?? h.approverEmployeeCode ?? 'N/A'}'),
                                    if (h.comments != null && h.comments!.isNotEmpty)
                                      Text('${'comments'.tr}: ${h.comments}',
                                          style: const TextStyle(fontStyle: FontStyle.italic)),
                                    if (h.actionDate != null)
                                      Text(
                                        DateFormat('yyyy-MM-dd').format(h.actionDate!.toLocal()),
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _translateType(String typeName) {
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
}
