import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import '../../data/models/customer_payment_receipt.dart';
import '../../data/models/company_info.dart';
import '../../data/models/data_translation.dart';
import '../utils/app_number_to_words.dart';

class ReceiptPdfService {
  /// Generates a professional Receipt Voucher PDF bytes fitting half of an A4 page,
  /// matching the exact design format provided in the specification.
  static Future<Uint8List> generatePdf(
    CustomerPaymentReceipt receipt, {
    CompanyInfo? companyInfo,
    Map<String, DataTranslation>? translations,
    Uint8List? logoBytes,
    bool isHalfPageOnly = true,
  }) async {
    final pdf = pw.Document();

    final company = companyInfo ?? CompanyInfo.defaultCompanyInfo();
    final dict = translations ?? {};

    // Load Fonts
    final amiriData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final amiriFont = pw.Font.ttf(amiriData);

    final fontData = await rootBundle.load('assets/fonts/saudi_riyal.ttf');
    final saudiRiyalFont = pw.Font.ttf(fontData);

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = dateFormat.format(receipt.receiptDate.toLocal());
    final amountInWords = AppNumberToWords.convertToWords(receipt.amount);
    final formattedAmount = NumberFormat('#,##0.00', 'en_US').format(receipt.amount);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        theme: pw.ThemeData.withFont(
          base: amiriFont,
          bold: amiriFont,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Outer Navy Border Container wrapping the entire receipt voucher
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex('#0B192C'), width: 1.5),
                ),
                padding: const pw.EdgeInsets.all(12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // 1. Header Section: Left (English), Center (Logo), Right (Arabic)
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left English Details
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              company.companyName1English.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 10.5,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#0B192C'),
                              ),
                            ),
                            if (company.companyName2English != null && company.companyName2English!.isNotEmpty)
                              pw.Text(
                                company.companyName2English!,
                                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#333333')),
                              ),
                            pw.SizedBox(height: 2),
                            pw.Text('VAT: ${company.vatRegistrationNo}', style: pw.TextStyle(fontSize: 7.5, color: PdfColor.fromHex('#555555'))),
                            pw.Text('CR: ${company.crNo}', style: pw.TextStyle(fontSize: 7.5, color: PdfColor.fromHex('#555555'))),
                          ],
                        ),

                        // Center Logo
                        if (logoBytes != null && logoBytes.isNotEmpty)
                          pw.Container(
                            height: 60,
                            width: 135,
                            child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
                          )
                        else
                          pw.Container(
                            height: 50,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#F0F4F8'),
                              borderRadius: pw.BorderRadius.circular(4),
                              border: pw.Border.all(color: PdfColor.fromHex('#CCCCCC'), width: 0.5),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                company.companyName1English,
                                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0052CC')),
                              ),
                            ),
                          ),

                        // Right Arabic Details with RTL Directionality
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            _buildArabicText(company.companyName1Arabic, fontSize: 10.5, bold: true, color: PdfColor.fromHex('#0B192C')),
                            if (company.companyName2Arabic != null && company.companyName2Arabic!.isNotEmpty)
                              _buildArabicText(company.companyName2Arabic!, fontSize: 8, bold: true, color: PdfColor.fromHex('#333333')),
                            pw.SizedBox(height: 2),
                            pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                pw.Text('${company.vatRegistrationNo} :', style: pw.TextStyle(fontSize: 7.5, color: PdfColor.fromHex('#555555'))),
                                _buildArabicText('الرقم الضريبي', fontSize: 7.5, color: PdfColor.fromHex('#555555')),
                              ],
                            ),
                            pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                pw.Text('${company.crNo} :', style: pw.TextStyle(fontSize: 7.5, color: PdfColor.fromHex('#555555'))),
                                _buildArabicText('السجل التجاري', fontSize: 7.5, color: PdfColor.fromHex('#555555')),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),

                    // 2. Title Banner
                    pw.Center(
                      child: _buildBilingualText(
                        _getEngCap(dict, 'VOUCHER_RECEIPT_TITLE', 'RECEIPT VOUCHER'),
                        _getArabCap(dict, 'VOUCHER_RECEIPT_TITLE', 'سند قبض إلكتروني'),
                        fontSize: 12,
                        bold: true,
                        color: PdfColor.fromHex('#0052CC'),
                      ),
                    ),
                    pw.SizedBox(height: 8),

                    // 3. 4-Column Grid Metadata Table
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColor.fromHex('#D0D0D0'), width: 0.7),
                      children: [
                        // Row 1
                        pw.TableRow(
                          children: [
                            _buildGridBilingualLabel(dict, 'VOUCHER_NO', 'Voucher No.', 'رقم السند'),
                            _buildGridValueCell(receipt.receiptNo),
                            _buildGridBilingualLabel(dict, 'DATE_TIME', 'Date & Time', 'التاريخ والوقت'),
                            _buildGridValueCell(formattedDate),
                          ],
                        ),
                        // Row 2
                        pw.TableRow(
                          children: [
                            _buildGridBilingualLabel(dict, 'PAYMENT_METHOD', 'Payment Method', 'طريقة الدفع'),
                            _buildMethodGridValue(receipt.paymentMethodCode),
                            _buildGridBilingualLabel(dict, 'TRANSACTION_STATUS', 'Transaction Status', 'الحالة'),
                            _buildBilingualGridValue('COMPLETED', 'مكتمل'),
                          ],
                        ),
                        // Row 3
                        pw.TableRow(
                          children: [
                            _buildGridBilingualLabel(dict, 'CUSTOMER_NAME', 'Customer Name', 'اسم العميل'),
                            _buildCustomerGridValue(receipt),
                            _buildGridBilingualLabel(dict, 'CUSTOMER_VAT', 'Customer VAT', 'الرقم الضريبي'),
                            _buildGridValueCell('[ ${receipt.customerMobile ?? '31XXXXXXXX0003'} ]'),
                          ],
                        ),
                        // Row 4
                        pw.TableRow(
                          children: [
                            _buildGridBilingualLabel(dict, 'CUSTOMER_CODE', 'Customer Code', 'كود العميل'),
                            _buildGridValueCell(' ${receipt.customerNo} '),
                            _buildGridBilingualLabel(dict, 'COLLECTOR_SALESMAN', 'Collector / Salesman', 'المندوب'),
                            _buildGridValueCell((receipt.collectedBy != null && receipt.collectedBy!.isNotEmpty) ? receipt.collectedBy! : receipt.employeeCode),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),

                    // 4. Financial Details Summary Box Table
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColor.fromHex('#D0D0D0'), width: 0.7),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(1.4),
                        1: const pw.FlexColumnWidth(3.0),
                      },
                      children: [
                        // Row 1: Total Amount Received
                        pw.TableRow(
                          children: [
                            _buildGridBilingualLabel(dict, 'TOTAL_AMOUNT_RECEIVED', 'Total Amount Received', 'إجمالي المبلغ المقبوض'),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                              child: pw.Text(
                                '$formattedAmount SAR',
                                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0B192C')),
                              ),
                            ),
                          ],
                        ),
                        // Row 2: Amount in Words
                        pw.TableRow(
                          children: [
                            _buildGridBilingualLabel(dict, 'AMOUNT_IN_WORDS', 'Amount in Words', 'المبلغ كتابة'),
                            _buildGridValueCell('$amountInWords Only'),
                          ],
                        ),
                        // Row 3: Payment Against
                        pw.TableRow(
                          children: [
                            _buildGridBilingualLabel(dict, 'PAYMENT_AGAINST', 'Payment Against', 'وذلك مقابل'),
                            _buildGridValueCell('${receipt.paymentAgainst} against Invoice No. [${receipt.navDocumentNo ?? receipt.referenceNo ?? 'xxxxx'}]'),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),

                    // 5. Notes Section
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildBilingualText(
                          _getEngCap(dict, 'NOTES', 'Notes'),
                          _getArabCap(dict, 'NOTES', 'ملاحظة'),
                          fontSize: 8.5,
                          bold: true,
                        ),
                        pw.Text(': ', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        pw.Expanded(
                          child: pw.Text(
                            receipt.remarks != null && receipt.remarks!.isNotEmpty ? receipt.remarks! : '',
                            style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#333333')),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),

                    // 6. Signatures Section (Payer & Collector)
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Payer Signature
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildBilingualText('Payer Signature (من)', 'توقيع العميل / الدافع', fontSize: 8, bold: true),
                            pw.SizedBox(height: 18),
                            pw.Container(
                              width: 140,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.8)),
                              ),
                            ),
                          ],
                        ),

                        // Right Collector Signature
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            _buildBilingualText('Collector Signature (إلى)', 'توقيع المندوب / المستلم', fontSize: 8, bold: true),
                            pw.SizedBox(height: 18),
                            pw.Container(
                              width: 140,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),

                    // 7. Footer Metadata & Legal Disclaimer
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'VAT No: ${company.vatRegistrationNo} | CR: ${company.crNo} | E-mail: ${company.email ?? 'accounts@housecare.sa'} | ${company.phone ?? '+966 56 850 2632'}',
                            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#333333')),
                          ),
                          pw.SizedBox(height: 2),
                          _buildBilingualText(
                            'This is a system-generated electronic receipt voucher and is valid without a signature or official seal.',
                            'سند قبض إلكتروني مخرج من النظام ولا يحتاج إلى توقيع أو ختم رسمي.',
                            fontSize: 7,
                            color: PdfColor.fromHex('#666666'),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'A copy of this receipt will be dispatched from:: ${company.email ?? 'accounts@housecare.sa'}',
                            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#333333')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildArabicText(
    String arab, {
    double fontSize = 8,
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Text(
        arab,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColor.fromHex('#0B192C'),
        ),
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  static pw.Widget _buildBilingualText(
    String eng,
    String arab, {
    double fontSize = 8,
    bool bold = false,
    PdfColor? color,
  }) {
    final fontStyle = pw.TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color ?? PdfColor.fromHex('#0B192C'),
    );

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(eng, style: fontStyle),
        pw.Text(' / ', style: fontStyle),
        _buildArabicText(arab, fontSize: fontSize, bold: bold, color: color),
      ],
    );
  }

  static pw.Widget _buildGridBilingualLabel(Map<String, DataTranslation> dict, String key, String defEng, String defArab) {
    final eng = _getEngCap(dict, key, defEng);
    final arab = _getArabCap(dict, key, defArab);
    return pw.Container(
      color: PdfColor.fromHex('#FAFAFA'),
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: _buildBilingualText(eng, arab, fontSize: 7.5, bold: true),
    );
  }

  static pw.Widget _buildBilingualGridValue(String eng, String arab) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: _buildBilingualText(eng, arab, fontSize: 7.5),
    );
  }

  static pw.Widget _buildCustomerGridValue(CustomerPaymentReceipt receipt) {
    final arab = receipt.customerName2 ?? '';
    final eng = receipt.customerName ?? '';

    if (arab.trim().isNotEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: _buildArabicText(arab.trim(), fontSize: 8, bold: true),
      );
    } else if (eng.trim().isNotEmpty) {
      return _buildGridValueCell(eng.trim());
    }
    return _buildGridValueCell('[ Customer / Business Name ]');
  }

  static pw.Widget _buildMethodGridValue(String code) {
    switch (code.toUpperCase()) {
      case 'CASH':
        return _buildBilingualGridValue('CASH', 'نقدًا');
      case 'BANK':
        return _buildBilingualGridValue('BANK TRANSFER', 'تحويل بنكي');
      case 'CHEQUE':
        return _buildBilingualGridValue('CHEQUE', 'شيك');
      case 'CARD':
        return _buildBilingualGridValue('CARD', 'بطاقة');
      default:
        return _buildBilingualGridValue(code, 'نقدًا');
    }
  }

  static pw.Widget _buildGridValueCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 7.5, color: PdfColor.fromHex('#222222')),
      ),
    );
  }

  static String _getEngCap(Map<String, DataTranslation> dict, String key, String defEng) {
    if (dict.containsKey(key.toUpperCase())) {
      return dict[key.toUpperCase()]!.english;
    }
    return defEng;
  }

  static String _getArabCap(Map<String, DataTranslation> dict, String key, String defArab) {
    if (dict.containsKey(key.toUpperCase())) {
      return dict[key.toUpperCase()]!.arabic;
    }
    return defArab;
  }
}
