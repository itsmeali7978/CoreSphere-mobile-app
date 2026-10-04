import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/create_request_controller.dart';
import '../../../data/models/request_type.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class CreateRequestView extends StatelessWidget {
  const CreateRequestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateRequestController());

    return Scaffold(
      appBar: AppBar(
        title: Text('create_request'.tr),
      ),
      body: Obx(() {
        if (controller.isLoadingTypes.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<RequestType>(
                decoration: InputDecoration(
                  labelText: 'request_type'.tr,
                  border: const OutlineInputBorder(),
                ),
                value: controller.selectedRequestType.value,
                items: controller.requestTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (val) {
                  controller.selectedRequestType.value = val;
                },
              ),
              const SizedBox(height: 16),
              
              if (controller.isLeaveRequest) ...[
                if (controller.isAnnualLeave) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_available_outlined, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'days_since_last_vacation'.tr,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Obx(() {
                                final user = controller.currentUser.value;
                                final days = user?.daysSinceLastVacation ?? 0;
                                return Text(
                                  '$days ${'days'.tr}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    final user = controller.currentUser.value;
                    final days = user?.daysSinceLastVacation ?? 0;
                    if (days < 365) {
                      final warningText = 'vacation_365_warning'.tr.replaceAll('@days', '$days');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                                warningText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: controller.startDate.value ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              controller.startDate.value = date;
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'start_date'.tr,
                              border: const OutlineInputBorder(),
                            ),
                            child: Text(
                              controller.startDate.value != null
                                  ? DateFormat('yyyy-MM-dd').format(controller.startDate.value!)
                                  : 'select_dates'.tr,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: controller.endDate.value ?? controller.startDate.value ?? DateTime.now(),
                              firstDate: controller.startDate.value ?? DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              controller.endDate.value = date;
                            }
                          },
                          child: InputDecorator(
                            decoration:  InputDecoration(
                              labelText: 'end_date'.tr,
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              controller.endDate.value != null
                                  ? DateFormat('yyyy-MM-dd').format(controller.endDate.value!)
                                  : 'select_dates'.tr,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (controller.isUnpaidLeave || controller.isSickLeave) ...[
                  OutlinedButton.icon(
                    onPressed: () async {
                      var results = await showCalendarDatePicker2Dialog(
                        context: context,
                        config: CalendarDatePicker2WithActionButtonsConfig(
                          calendarType: CalendarDatePicker2Type.multi,
                        ),
                        dialogSize: const Size(325, 400),
                        value: controller.selectedDates.toList(),
                      );
                      if (results != null) {
                        controller.selectedDates.value = results.whereType<DateTime>().toList();
                      }
                    },
                    icon: const Icon(Icons.calendar_month),
                    label:  Text('select_dates'.tr),
                  ),
                  const SizedBox(height: 8),
                  if (controller.selectedDates.isNotEmpty) ...[
                     Text('select_dates'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: controller.selectedDates.map((d) {
                        return Chip(
                          label: Text(DateFormat('yyyy-MM-dd').format(d)),
                          onDeleted: () {
                            controller.selectedDates.remove(d);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                if (controller.leaveDays > 0)
                  Text(
                    '${'leave_days'.tr}: ${controller.leaveDays.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: controller.descriptionController,
                decoration: InputDecoration(
                  labelText: 'description'.tr,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              if (controller.isSickLeave) ...[
                OutlinedButton.icon(
                  onPressed: () => controller.pickFile(allowMultiple: true),
                  icon: const Icon(Icons.attach_file),
                  label:  Text('add_attachments'.tr),
                ),
                if (controller.attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(controller.attachments.length, (index) {
                      final file = controller.attachments[index];
                      return ListTile(
                        leading: const Icon(Icons.file_present),
                        title: Text(file.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.removeAttachment(index),
                        ),
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 24),
              ],

              ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : controller.submitRequest,
                child: controller.isSubmitting.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('submit'.tr),
              ),
            ],
          ),
        );
      }),
    );
  }
}
