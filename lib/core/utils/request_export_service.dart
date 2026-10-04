import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/approval_request.dart';
import '../../data/models/request_approval_history.dart';
import '../../data/models/company_info.dart';
import 'app_toast.dart';

class RequestExportService {
  /// Generate PDF document byte array for a single request in A4 Company Letter Pad format
  static Future<Uint8List> generateSingleRequestPdfBytes(
    ApprovalRequest request, {
    List<RequestApprovalHistory>? history,
    CompanyInfo? companyInfo,
    Uint8List? logoBytes,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy/MM/dd');

    // Load Fonts for Arabic & English support
    final amiriData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final amiriFont = pw.Font.ttf(amiriData);

    final primaryRed = PdfColor.fromHex('#B82C2A');
    final darkNavy = PdfColor.fromHex('#0B192C');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 12),
        theme: pw.ThemeData.withFont(
          base: amiriFont,
          bold: amiriFont,
        ),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // 1. Company Letter Pad Header with Center Company Logo
              _buildLetterPadHeader(primaryRed, darkNavy, logoBytes: logoBytes, companyInfo: companyInfo),

              pw.SizedBox(height: 6),

              // 2. Form Title Header
              _buildFormTitle(request.requestTypeId == 1),

              pw.SizedBox(height: 6),

              // 3. Form Grid
              _buildVacationFormGrid(request, dateFormat, primaryRed),

              pw.SizedBox(height: 6),

              // 4. Section 2: Management Approval (موافقة المشرف)
              _buildManagementApprovalBox(request, primaryRed),

              pw.SizedBox(height: 6),

              // 5. Section 3: Signatures (التواقيع)
              _buildSignatureSection(history, dateFormat),

              pw.SizedBox(height: 10),

              // 6. Company Letter Pad Footer
              _buildLetterPadFooter(primaryRed),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// 1. Company Letter Pad Header matching 'Company Letter Pad.pdf' with Center Company Logo
  static pw.Widget _buildLetterPadHeader(
    PdfColor primaryRed,
    PdfColor darkNavy, {
    Uint8List? logoBytes,
    CompanyInfo? companyInfo,
  }) {
    final name1Ar = companyInfo?.companyName1Arabic ?? 'هاوس كير';
    final name1En = companyInfo?.companyName1English ?? 'House Care';
    final name2Ar = companyInfo?.companyName2Arabic ?? 'متاجر هاوس كير';
    final name2En = companyInfo?.companyName2English ?? 'HOUSE CARE STORES';
    final crNo = companyInfo?.crNo ?? '4031193218';

    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Left Branding / Logo text
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  name1Ar,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryRed),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.Text(
                  name1En,
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryRed),
                ),
                pw.Text(
                  'قمة التوفير للمستهلك',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.green700),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),

            // Center Logo Image
            if (logoBytes != null && logoBytes.isNotEmpty)
              pw.Container(
                height: 65,
                width: 150,
                child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
              ),

            // Right Branding
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  name2Ar,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryRed),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.Text(
                  name2En.toUpperCase(),
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryRed),
                ),
                pw.Text(
                  'شركة تجار شطار التجارية',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryRed),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 6),

        // Center Red Banner Bar
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: primaryRed,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              pw.Text(
                '$crNo س.ت',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                '|  Thujjar Shuttar Trading Company  |',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'شركة تجار شطار التجارية',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 2. Form Title Header
  static pw.Widget _buildFormTitle(bool isAnnualLeave) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Column(
        children: [
          pw.Text(
            isAnnualLeave ? 'نموذج طلب اجازة' : 'نموذج طلب',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            isAnnualLeave ? 'Vacation Request Form' : 'Request Form',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildGenericFormTitle(String requestTypeName) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Column(
        children: [
          pw.Text(
            'نموذج طلب - $requestTypeName',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            'Request Form - $requestTypeName',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Generic Standard Form Grid for Non-Annual Leave Requests
  static pw.Widget _buildGenericRequestFormGrid(
    ApprovalRequest r,
    List<RequestApprovalHistory>? history,
    DateFormat dateFormat,
    PdfColor primaryRed,
  ) {
    final effectiveJoiningDate = r.resumptionDate ?? r.joinDate ?? r.createdDate;
    final empNameAr = (r.employeeNameArabic != null && r.employeeNameArabic!.trim().isNotEmpty)
        ? r.employeeNameArabic!
        : r.employeeName;
    final iqamaVal = (r.iqamaNo != null && r.iqamaNo!.trim().isNotEmpty) ? r.iqamaNo! : '-';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Request Overview Table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
          columnWidths: const {
            0: pw.FlexColumnWidth(1),
            1: pw.FixedColumnWidth(105),
            2: pw.FlexColumnWidth(1),
            3: pw.FixedColumnWidth(105),
          },
          children: [
            // Row 1: Request No & Request Date
            pw.TableRow(
              children: [
                _buildValueWidget(r.requestNo),
                _buildLabelCell('رقم الطلب\nRequest No'),
                _buildDateWidget(r.createdDate, dateFormat),
                _buildLabelCell('تاريخ الطلب\nRequest Date'),
              ],
            ),
            // Row 2: Employee Code & Name
            pw.TableRow(
              children: [
                _buildValueWidget(r.employeeCode),
                _buildLabelCell('الرقم الوظيفي\nEmployee Code'),
                _buildValueWidget(empNameAr, fontSize: 10),
                _buildLabelCell('اسم الموظف\nEmployee Name'),
              ],
            ),
            // Row 3: Request Type & Status
            pw.TableRow(
              children: [
                _buildValueWidget(r.statusDisplayName),
                _buildLabelCell('حالة الطلب\nStatus'),
                _buildValueWidget(r.requestTypeName),
                _buildLabelCell('نوع الطلب\nRequest Type'),
              ],
            ),
            // Row 4: Iqama & Joining Date
            pw.TableRow(
              children: [
                _buildDateWidget(effectiveJoiningDate, dateFormat),
                _buildLabelCell('تاريخ الالتحاق\nJoining Date'),
                _buildValueWidget(iqamaVal),
                _buildLabelCell('الهوية / الاقامة\nIqama / ID'),
              ],
            ),
            // Row 5: Start & End Date (if applicable)
            if (r.startDate != null || r.endDate != null || r.leaveDays != null)
              pw.TableRow(
                children: [
                  _buildDateWidget(r.endDate, dateFormat),
                  _buildLabelCell('تاريخ الانتهاء\nEnd Date'),
                  _buildDateWidget(r.startDate, dateFormat),
                  _buildLabelCell('تاريخ البدء\nStart Date'),
                ],
              ),
            // Row 6: Balance & Vacation Days (if applicable)
            if (r.startDate != null || r.endDate != null || r.leaveDays != null)
              pw.TableRow(
                children: [
                  _buildDaysWidget(r.daysSinceLastVacation),
                  _buildLabelCell('الرصيد المتبقي\nBalance'),
                  _buildDaysWidget(r.leaveDays, startDate: r.startDate, endDate: r.endDate, selectedDates: r.selectedDates),
                  _buildLabelCell('عدد الايام\nVacation Days'),
                ],
              ),
          ],
        ),

        pw.SizedBox(height: 8),

        // Subject & Description Section
        pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 0.8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                color: PdfColor.fromHex('#E0E0E0'),
                child: pw.Text(
                  'تفاصيل الطلب / Request Details',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  textDirection: pw.TextDirection.rtl,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(r.subject, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textDirection: pw.TextDirection.rtl),
                        pw.Text('الموضوع / Subject: ', style: const pw.TextStyle(fontSize: 10), textDirection: pw.TextDirection.rtl),
                      ],
                    ),
                    if (r.description != null && r.description!.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text('البيان / Description:', style: const pw.TextStyle(fontSize: 9), textDirection: pw.TextDirection.rtl),
                      pw.SizedBox(height: 2),
                      pw.Text(r.description!, style: const pw.TextStyle(fontSize: 9), textDirection: pw.TextDirection.rtl),
                    ],
                    if (r.selectedDates != null && r.selectedDates!.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text('التواريخ المحددة / Selected Dates:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textDirection: pw.TextDirection.rtl),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        r.selectedDates!.map((d) => dateFormat.format(d)).join(', '),
                        style: const pw.TextStyle(fontSize: 9),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Approval History Timeline if available
        if (history != null && history.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.8),
            ),
            child: pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  color: PdfColor.fromHex('#E0E0E0'),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'سجل الموافقات / Approval History',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _buildTableHeaderCell('التاريخ / Date'),
                        _buildTableHeaderCell('ملاحظات / Comments'),
                        _buildTableHeaderCell('الإجراء / Action'),
                        _buildTableHeaderCell('اسم المعتمد / Approver'),
                        _buildTableHeaderCell('المستوى / Level'),
                      ],
                    ),
                    ...history.map((h) {
                      final dateStr = h.actionDate != null ? dateFormat.format(h.actionDate!) : '-';
                      return pw.TableRow(
                        children: [
                          _buildTableCell(dateStr),
                          _buildTableCell(h.comments ?? '-'),
                          _buildTableCell(h.action),
                          _buildTableCell(h.approverName ?? h.approverEmployeeCode ?? '-'),
                          _buildTableCell('Level ${h.levelNo}'),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      color: PdfColor.fromHex('#E0E0E0'),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {double fontSize = 8.5}) {
    final bool hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      color: PdfColors.white,
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: fontSize),
        textDirection: hasArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// 3. Grid Form matching 'request content.jpeg' with Complete Grey Border Cell Fills & Crisp Arabic BiDi Rendering
  static pw.Widget _buildVacationFormGrid(
    ApprovalRequest r,
    DateFormat dateFormat,
    PdfColor primaryRed,
  ) {
    final isTypeId1 = r.requestTypeId == 1;
    final isSick = r.requestTypeName.toLowerCase().contains('sick') || r.requestTypeName.contains('مرضية');
    final isUnpaid = r.requestTypeName.toLowerCase().contains('unpaid') || r.requestTypeName.contains('بدون راتب');
    final isEmergency = r.requestTypeName.toLowerCase().contains('emergency') || r.requestTypeName.contains('طارئة');
    final isAnnual = isTypeId1 || (!isSick && !isUnpaid && !isEmergency);

    final String daysCaption = isTypeId1 ? 'عدد الايام\nVacation Days' : 'عدد الايام\nLeave Days';
    final pw.Widget balanceWidget = isTypeId1
        ? _buildDaysWidget(r.daysSinceLastVacation)
        : pw.Text('-', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold));

    final effectiveJoiningDate = r.resumptionDate ?? r.joinDate ?? r.createdDate;
    final empNameAr = (r.employeeNameArabic != null && r.employeeNameArabic!.trim().isNotEmpty)
        ? r.employeeNameArabic!
        : r.employeeName;
    final iqamaVal = (r.iqamaNo != null && r.iqamaNo!.trim().isNotEmpty) ? r.iqamaNo! : '-';

    return pw.Column(
      children: [
        // Row 1: Joining Date & Date
        _build4CellRow(
          _buildDateWidget(effectiveJoiningDate, dateFormat), 'تاريخ الالتحاق\nJoining Date',
          _buildDateWidget(r.createdDate, dateFormat), 'التاريخ\nDate',
        ),

        // Row 2: Employees name
        _build2CellRow(
          _buildValueWidget(empNameAr, fontSize: 11),
          'اسم الموظف/ة\nEmployees name',
        ),

        // Row 3: Employee No & Iqama
        _build4CellRow(
          _buildValueWidget(r.employeeCode), 'الرقم الوظيفي\nEmployee No',
          _buildValueWidget(iqamaVal), 'رقم الهوية /الاقامة\nNo Of Identity / Iqama',
        ),

        // Row 4: Job Title
        _build2CellRow(
          _buildValueWidget(''),
          'المسمى الوظيفي\nJob Title',
        ),

        // Row 5: Vacation Ending Date & Starting Date
        _build4CellRow(
          _buildDateWidget(r.endDate, dateFormat), 'تاريخ انتهاء الاجازة\nVacation Ending Date',
          _buildDateWidget(r.startDate, dateFormat), 'تاريخ بدء الاجازة\nVacation Starting Date',
        ),

        // Row 6: Balance & Vacation/Leave Days
        _build4CellRow(
          balanceWidget, 'الرصيد المتبقي\nBalance',
          _buildDaysWidget(r.leaveDays, startDate: r.startDate, endDate: r.endDate, selectedDates: r.selectedDates), daysCaption,
        ),

        // Row 7: Vacation Type Checkboxes
        _build2CellRow(
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            color: PdfColors.white,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildCheckboxItem('بدون راتب\nWithout Salary', isUnpaid),
                _buildCheckboxItem('مرضية\nSick leave', isSick),
                _buildCheckboxItem('طارئة\nEmergency', isEmergency),
                _buildCheckboxItem('سنوية\nAnnual leave', isAnnual),
              ],
            ),
          ),
          'نوع الاجازة\nVacation Type',
        ),

        // Row 8: Employee Signature
        _build2CellRow(
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            color: PdfColors.white,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Text('التاريخ / Date:  ', style: const pw.TextStyle(fontSize: 9), textDirection: pw.TextDirection.rtl),
                    //_buildDateWidget(r.createdDate, dateFormat),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Text('توقيع الموظف/ة / Employees Signature:  ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textDirection: pw.TextDirection.rtl),
                    pw.Text('___________', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
          'توقيع الموظف/ة\nEmployees Signature',
        ),
      ],
    );
  }

  static pw.Widget _buildDaysWidget(num? count, {DateTime? startDate, DateTime? endDate, List<DateTime>? selectedDates}) {
    num? days = count;
    if ((days == null || days == 0) && selectedDates != null && selectedDates.isNotEmpty) {
      days = selectedDates.length;
    }
    if ((days == null || days == 0) && startDate != null && endDate != null) {
      final diff = endDate.difference(startDate).inDays + 1;
      if (diff > 0) days = diff;
    }

    if (days == null || days == 0) {
      return pw.Text('-', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold));
    }
    final numStr = days is double ? (days % 1 == 0 ? days.toInt().toString() : days.toString()) : days.toString();
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          numStr,
          style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(width: 4),
        pw.Text(
          'ايام',
          style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    );
  }

  static pw.Widget _buildDateWidget(DateTime? date, DateFormat dateFormat) {
    if (date == null) {
      return pw.Text('-', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold));
    }
    final dateStr = dateFormat.format(date);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text('م', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold), textDirection: pw.TextDirection.rtl),
        pw.SizedBox(width: 4),
        pw.Text(dateStr, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold))
        
        
      ],
    );
  }

  static pw.Widget _build4CellRow(
    pw.Widget val1, String label1,
    pw.Widget val2, String label2,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
      columnWidths: const {
        0: pw.FlexColumnWidth(1),
        1: pw.FixedColumnWidth(105),
        2: pw.FlexColumnWidth(1),
        3: pw.FixedColumnWidth(105),
      },
      children: [
        pw.TableRow(
          children: [
            _buildValueContainer(val1),
            _buildLabelCell(label1),
            _buildValueContainer(val2),
            _buildLabelCell(label2),
          ],
        ),
      ],
    );
  }

  static pw.Widget _build2CellRow(pw.Widget valueWidget, String labelText) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
      columnWidths: const {
        0: pw.FlexColumnWidth(1),
        1: pw.FixedColumnWidth(105),
      },
      children: [
        pw.TableRow(
          children: [
            valueWidget,
            _buildLabelCell(labelText),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildLabelCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      color: PdfColor.fromHex('#E0E0E0'),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildValueWidget(String text, {double fontSize = 9.5, bool isBold = true}) {
    final bool hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
      textDirection: hasArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      textAlign: pw.TextAlign.center,
    );
  }

  static pw.Widget _buildValueContainer(pw.Widget child) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: PdfColors.white,
      alignment: pw.Alignment.center,
      child: child,
    );
  }

  static pw.Widget _buildCheckboxItem(String label, bool isChecked) {
    return pw.Row(
      children: [
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
            color: isChecked ? PdfColors.black : PdfColors.white,
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8), textDirection: pw.TextDirection.rtl),
      ],
    );
  }

  /// 4. Section 2: Management Approval (موافقة المشرف)
  static pw.Widget _buildManagementApprovalBox(ApprovalRequest r, PdfColor primaryRed) {
    final isApproved = r.status.toUpperCase() == 'APPROVED';
    final isRejected = r.status.toUpperCase() == 'REJECTED';

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
      ),
      child: pw.Column(
        children: [
          // Header Bar
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: PdfColors.grey300,
            alignment: pw.Alignment.center,
            child: pw.Text(
              'موافقة المشرف / Management approval',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _buildCheckboxOption('موافق وقد تم تامين البديل / Approved and we covered his work', isApproved),
                pw.SizedBox(height: 4),
                _buildCheckboxOption('موافق ولكن نحتاج من يحل محله / Approved and we need someone takes his place', false),
                pw.SizedBox(height: 4),
                _buildCheckboxOption('غير موافق / Not approved', isRejected),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCheckboxOption(String label, bool isChecked) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9), textDirection: pw.TextDirection.rtl),
        pw.SizedBox(width: 6),
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
            color: isChecked ? PdfColors.black : PdfColors.white,
          ),
        ),
      ],
    );
  }

  /// 5. Section 3: Signatures (التواقيع)
  static pw.Widget _buildSignatureSection(List<RequestApprovalHistory>? history, DateFormat dateFormat) {
    DateTime? hrDate;
    DateTime? gmDate;

    if (history != null) {
      for (var h in history) {
        if (h.actionDate != null) {
          if (h.levelNo == 1 || h.levelNo == 2) {
            hrDate = h.actionDate;
          }
          if (h.levelNo >= 2 && h.action.toUpperCase() == 'APPROVED') {
            gmDate = h.actionDate;
          }
        }
      }
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Text('التاريخ / Date:  ', style: const pw.TextStyle(fontSize: 9), textDirection: pw.TextDirection.rtl),
                  if (hrDate != null)
                    _buildDateWidget(hrDate, dateFormat)
                  else
                    pw.Text('___________', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text('توقيع مدير الموارد البشرية / HR Manager Signature:  ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textDirection: pw.TextDirection.rtl),
                  pw.Text('_________________', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Text('التاريخ / Date:  ', style: const pw.TextStyle(fontSize: 9), textDirection: pw.TextDirection.rtl),
                  if (gmDate != null)
                    _buildDateWidget(gmDate, dateFormat)
                  else
                    pw.Text('___________', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text('توقيع المدير العام : / General Director Signature:  ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textDirection: pw.TextDirection.rtl),
                  pw.Text('_________________', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 6. Company Letter Pad Footer matching 'Company Letter Pad.pdf'
  static pw.Widget _buildLetterPadFooter(PdfColor primaryRed) {
    return pw.Column(
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          color: primaryRed,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'المملكة العربية السعودية - مكة المكرمة - الشوقية - سوق القوافل - أمام الحلقة  |  Kingdom of Saudi Arabia - Makkah - Al Shawqiah - Al Qawafil Market - Opp. Al-Halaqah',
                style: pw.TextStyle(fontSize: 7, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                '@housecareksa  |  housecare@housecare.sa  |  www.housecare.sa',
                style: pw.TextStyle(fontSize: 7, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Export a single request details to PDF format and open printing / preview / share dialog
  static Future<void> exportSingleRequestToPdf(
    ApprovalRequest request, {
    List<RequestApprovalHistory>? history,
  }) async {
    try {
      final bytes = await generateSingleRequestPdfBytes(request, history: history);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Vacation_Request_${request.requestNo}.pdf',
      );
    } catch (e) {
      AppToast.show('Failed to generate PDF: $e', backgroundColor: Colors.redAccent);
    }
  }

  /// Export a single request details to Excel (CSV with UTF-8 BOM) matching form fields
  static Future<void> exportSingleRequestToExcel(
    ApprovalRequest request, {
    List<RequestApprovalHistory>? history,
  }) async {
    try {
      final dateFormat = DateFormat('yyyy/MM/dd');
      final StringBuffer csv = StringBuffer();

      // UTF-8 BOM for Excel Arabic / English support
      csv.write('\uFEFF');

      // Company Header
      csv.writeln('"شركة تجار شطار التجارية - متاجر هاوس كير"');
      csv.writeln('"Thujjar Shuttar Trading Company - House Care Stores"');
      csv.writeln('"C.R. 4031193218 س.ت"');
      csv.writeln('');

      final typeName = request.requestTypeName.toLowerCase();
      final subjectText = request.subject.toLowerCase();
      final isAnnualLeave = typeName.contains('annual') ||
          typeName.contains('سنوي') ||
          typeName.contains('سنوية') ||
          typeName.contains('سنويه') ||
          subjectText.contains('annual') ||
          subjectText.contains('سنوي') ||
          subjectText.contains('سنوية') ||
          subjectText.contains('سنويه');

      // Form Title
      csv.writeln(isAnnualLeave
          ? '"نموذج طلب اجازة / Vacation Request Form"'
          : '"نموذج طلب - ${request.requestTypeName} / Request Form - ${request.requestTypeName}"');
      csv.writeln('');

      // Form Fields
      final createdStr = '${dateFormat.format(request.createdDate)} م';
      final effectiveJoiningDate = request.resumptionDate ?? request.joinDate ?? request.createdDate;
      final joinStr = '${dateFormat.format(effectiveJoiningDate)} م';
      final empNameAr = (request.employeeNameArabic != null && request.employeeNameArabic!.trim().isNotEmpty)
          ? request.employeeNameArabic!
          : request.employeeName;
      final iqamaVal = (request.iqamaNo != null && request.iqamaNo!.trim().isNotEmpty) ? request.iqamaNo! : '-';
      final startStr = request.startDate != null ? '${dateFormat.format(request.startDate!)} م' : '-';
      final endStr = request.endDate != null ? '${dateFormat.format(request.endDate!)} م' : '-';
      num? computedDays = request.leaveDays;
      if ((computedDays == null || computedDays == 0) && request.selectedDates != null && request.selectedDates!.isNotEmpty) {
        computedDays = request.selectedDates!.length;
      }
      if ((computedDays == null || computedDays == 0) && request.startDate != null && request.endDate != null) {
        final diff = request.endDate!.difference(request.startDate!).inDays + 1;
        if (diff > 0) computedDays = diff;
      }
      final daysStr = computedDays != null && computedDays > 0 ? '${computedDays.toInt()} ايام' : '-';
      final balStr = request.daysSinceLastVacation != null ? '${request.daysSinceLastVacation} ايام' : '-';

      csv.writeln('"التاريخ / Date","$createdStr"');
      csv.writeln('"تاريخ الالتحاق / Joining Date","$joinStr"');
      csv.writeln('"اسم الموظف/ة / Employees name","${_cleanCsvField(empNameAr)}"');
      csv.writeln('"الرقم الوظيفي / Employee No","${_cleanCsvField(request.employeeCode)}"');
      csv.writeln('"رقم الهوية / الاقامة / No Of Identity / Iqama","${_cleanCsvField(iqamaVal)}"');
      csv.writeln('"نوع الطلب / Request Type","${_cleanCsvField(request.requestTypeName)}"');
      csv.writeln('"الموضوع / Subject","${_cleanCsvField(request.subject)}"');
      if (request.description != null && request.description!.isNotEmpty) {
        csv.writeln('"البيان / Description","${_cleanCsvField(request.description)}"');
      }

      if (isAnnualLeave) {
        csv.writeln('"المسمى الوظيفي / Job Title",""');
        csv.writeln('"تاريخ بدء الاجازة / Vacation Starting Date","$startStr"');
        csv.writeln('"تاريخ انتهاء الاجازة / Vacation Ending Date","$endStr"');
        csv.writeln('"عدد الايام / Vacation Days","$daysStr"');
        csv.writeln('"الرصيد المتبقي / Balance","$balStr"');
        csv.writeln('"موافقة المشرف / Management approval","${_cleanCsvField(request.statusDisplayName)}"');
      } else {
        if (request.startDate != null) csv.writeln('"تاريخ البدء / Start Date","$startStr"');
        if (request.endDate != null) csv.writeln('"تاريخ الانتهاء / End Date","$endStr"');
        csv.writeln('"حالة الطلب / Status","${_cleanCsvField(request.statusDisplayName)}"');
      }
      csv.writeln('');

      // Signatures Section
      csv.writeln('"توقيع الموظف/ة / Employees Signature","____________"');
      csv.writeln('"توقيع مدير الموارد البشرية / HR Manager Signature","____________"');
      csv.writeln('"توقيع المدير العام / General Director Signature","____________"');
      csv.writeln('');

      // Approval History Table if available
      if (history != null && history.isNotEmpty) {
        csv.writeln('"سجل الموافقات / Approval History"');
        csv.writeln('"المستوى / Level","اسم المعتمد / Approver Name","كود الموظف / Approver Code","الإجراء / Action","ملاحظات / Comments","التاريخ / Date"');
        for (var h in history) {
          final level = 'Level ${h.levelNo}';
          final name = _cleanCsvField(h.approverName);
          final code = _cleanCsvField(h.approverEmployeeCode);
          final action = _cleanCsvField(h.action);
          final comments = _cleanCsvField(h.comments);
          final date = h.actionDate != null ? '${dateFormat.format(h.actionDate!)} م' : '-';
          csv.writeln('"$level","$name","$code","$action","$comments","$date"');
        }
      }

      final directory = await getTemporaryDirectory();
      final fileName = 'Vacation_Request_${_cleanCsvField(request.requestNo)}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csv.toString(), encoding: utf8);

      AppToast.show('Excel report saved successfully: $fileName', backgroundColor: Colors.green);

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        await Share.shareXFiles([XFile(file.path)], text: 'Vacation Request Form - CoreSphere ERP');
      }
    } catch (e) {
      AppToast.show('Failed to export Excel report: $e', backgroundColor: Colors.redAccent);
    }
  }

  static String _cleanCsvField(String? input) {
    if (input == null) return '';
    return input.replaceAll('"', '""').replaceAll('\n', ' ');
  }
}
