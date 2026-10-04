import 'dart:convert';
import 'package:get/get.dart';
import '../../core/api/api_client.dart';
import '../../core/services/prefs_service.dart';
import '../models/data_translation.dart';

class TranslationRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final PrefsService _prefsService = Get.find<PrefsService>();
  
  static const String _storageKey = 'cached_data_translations';

  Future<Map<String, DataTranslation>> getTranslationsDictionary() async {
    try {
      final response = await _apiClient.get('/translations/dictionary');
      if (response.data != null && response.data['success'] == true && response.data['data'] != null) {
        final Map<String, dynamic> rawDict = response.data['data'];
        final Map<String, DataTranslation> result = {};
        rawDict.forEach((key, value) {
          result[key.toUpperCase()] = DataTranslation.fromJson(value);
        });
        
        final Map<String, dynamic> jsonCache = {};
        result.forEach((key, val) => jsonCache[key] = val.toJson());
        await _prefsService.sharedPreferences.setString(_storageKey, jsonEncode(jsonCache));
        
        return result;
      }
    } catch (e) {
      // Ignore network failure and try reading from cache
    }

    final cachedStr = _prefsService.sharedPreferences.getString(_storageKey);
    if (cachedStr != null) {
      try {
        final Map<String, dynamic> cached = jsonDecode(cachedStr);
        final Map<String, DataTranslation> result = {};
        cached.forEach((key, value) {
          result[key.toUpperCase()] = DataTranslation.fromJson(value);
        });
        return result;
      } catch (_) {}
    }

    return _getDefaultTranslations();
  }

  Map<String, DataTranslation> _getDefaultTranslations() {
    return {
      'VOUCHER_RECEIPT_TITLE': DataTranslation(key: 'VOUCHER_RECEIPT_TITLE', english: 'RECEIPT VOUCHER', arabic: 'سند قبض إلكتروني'),
      'VOUCHER_NO': DataTranslation(key: 'VOUCHER_NO', english: 'Voucher No.', arabic: 'رقم السند'),
      'DATE_TIME': DataTranslation(key: 'DATE_TIME', english: 'Date & Time', arabic: 'التاريخ والوقت'),
      'PAYMENT_METHOD': DataTranslation(key: 'PAYMENT_METHOD', english: 'Payment Method', arabic: 'طريقة الدفع'),
      'TRANSACTION_STATUS': DataTranslation(key: 'TRANSACTION_STATUS', english: 'Transaction Status', arabic: 'الحالة'),
      'CUSTOMER_NAME': DataTranslation(key: 'CUSTOMER_NAME', english: 'Customer Name', arabic: 'اسم العميل'),
      'CUSTOMER_VAT': DataTranslation(key: 'CUSTOMER_VAT', english: 'Customer VAT', arabic: 'الرقم الضريبي'),
      'CUSTOMER_CODE': DataTranslation(key: 'CUSTOMER_CODE', english: 'Customer Code', arabic: 'كود العميل'),
      'COLLECTOR_SALESMAN': DataTranslation(key: 'COLLECTOR_SALESMAN', english: 'Collector / Salesman', arabic: 'المندوب'),
      'TOTAL_AMOUNT_RECEIVED': DataTranslation(key: 'TOTAL_AMOUNT_RECEIVED', english: 'Total Amount Received', arabic: 'إجمالي المبلغ المقبوض'),
      'AMOUNT_IN_WORDS': DataTranslation(key: 'AMOUNT_IN_WORDS', english: 'Amount in Words', arabic: 'المبلغ كتابة'),
      'PAYMENT_AGAINST': DataTranslation(key: 'PAYMENT_AGAINST', english: 'Payment Against', arabic: 'وذلك مقابل'),
      'NOTES': DataTranslation(key: 'NOTES', english: 'Notes', arabic: 'ملاحظة'),
      'PAYER_SIGNATURE': DataTranslation(key: 'PAYER_SIGNATURE', english: 'Payer Signature (من)', arabic: 'توقيع العميل / الدافع'),
      'COLLECTOR_SIGNATURE': DataTranslation(key: 'COLLECTOR_SIGNATURE', english: 'Collector Signature (إلى)', arabic: 'توقيع المندوب / المستلم'),
      'ELECTRONIC_RECEIPT_FOOTER': DataTranslation(
        key: 'ELECTRONIC_RECEIPT_FOOTER',
        english: 'This is a system-generated electronic receipt voucher and is valid without a signature or official seal.',
        arabic: 'سند قبض إلكتروني مخرج من النظام ولا يحتاج إلى توقيع أو ختم رسمي.',
      ),
    };
  }
}
