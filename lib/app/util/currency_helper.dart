import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class CurrencyInfo {
  final String code;
  final String symbol;
  final String side;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    this.side = 'left',
  });
}

class CurrencyHelper {
  static const Map<String, CurrencyInfo> _byCurrency = {
    'INR': CurrencyInfo(code: 'INR', symbol: '₹', side: 'left'),
    'QAR': CurrencyInfo(code: 'QAR', symbol: 'QR', side: 'right'),
    'AED': CurrencyInfo(code: 'AED', symbol: 'AED', side: 'right'),
    'SAR': CurrencyInfo(code: 'SAR', symbol: 'SAR', side: 'right'),
    'KWD': CurrencyInfo(code: 'KWD', symbol: 'KWD', side: 'right'),
    'BHD': CurrencyInfo(code: 'BHD', symbol: 'BHD', side: 'right'),
    'OMR': CurrencyInfo(code: 'OMR', symbol: 'OMR', side: 'right'),
    'EGP': CurrencyInfo(code: 'EGP', symbol: 'EGP', side: 'right'),
    'USD': CurrencyInfo(code: 'USD', symbol: '\$', side: 'left'),
    'GBP': CurrencyInfo(code: 'GBP', symbol: '£', side: 'left'),
    'EUR': CurrencyInfo(code: 'EUR', symbol: '€', side: 'left'),
    'PKR': CurrencyInfo(code: 'PKR', symbol: 'Rs', side: 'left'),
  };

  static const Map<String, String> _countryToCurrency = {
    'IN': 'INR',
    'IND': 'INR',
    'INDIA': 'INR',
    'QA': 'QAR',
    'QAT': 'QAR',
    'QATAR': 'QAR',
    'AE': 'AED',
    'ARE': 'AED',
    'UAE': 'AED',
    'UNITED ARAB EMIRATES': 'AED',
    'SA': 'SAR',
    'SAU': 'SAR',
    'SAUDI ARABIA': 'SAR',
    'KW': 'KWD',
    'KWT': 'KWD',
    'KUWAIT': 'KWD',
    'BH': 'BHD',
    'BHR': 'BHD',
    'BAHRAIN': 'BHD',
    'OM': 'OMR',
    'OMN': 'OMR',
    'OMAN': 'OMR',
    'EG': 'EGP',
    'EGY': 'EGP',
    'EGYPT': 'EGP',
    'US': 'USD',
    'USA': 'USD',
    'UNITED STATES': 'USD',
    'GB': 'GBP',
    'GBR': 'GBP',
    'UNITED KINGDOM': 'GBP',
    'UK': 'GBP',
    'PK': 'PKR',
    'PAK': 'PKR',
    'PAKISTAN': 'PKR',
  };

  static CurrencyInfo fromCurrencyCode(String? code, {String? symbol}) {
    final key = (code ?? '').trim().toUpperCase();
    final mapped = _byCurrency[key];
    if (mapped != null) {
      if (symbol != null && symbol.trim().isNotEmpty) {
        return CurrencyInfo(code: mapped.code, symbol: symbol.trim(), side: mapped.side);
      }
      return mapped;
    }
    if (key.isEmpty) {
      return CurrencyInfo(
        code: AppConstants.defaultCurrencyCode,
        symbol: AppConstants.defaultCurrencySymbol,
        side: AppConstants.defaultCurrencySide,
      );
    }
    return CurrencyInfo(
      code: key,
      symbol: (symbol != null && symbol.trim().isNotEmpty) ? symbol.trim() : key,
      side: 'right',
    );
  }

  static CurrencyInfo fromCountry({String? code, String? name}) {
    final keys = <String>[
      code ?? '',
      name ?? '',
    ].map((e) => e.trim().toUpperCase()).where((e) => e.isNotEmpty);
    for (final key in keys) {
      final currency = _countryToCurrency[key];
      if (currency != null) return fromCurrencyCode(currency);
    }
    return fromCurrencyCode(AppConstants.defaultCurrencyCode);
  }

  static CurrencyInfo current(SharedPreferencesManager prefs) {
    return fromCurrencyCode(
      prefs.getString('currencyCode'),
      symbol: prefs.getString('currencySymbol'),
    );
  }

  static void save(SharedPreferencesManager prefs, CurrencyInfo info) {
    prefs.putString('currencyCode', info.code);
    prefs.putString('currencySymbol', info.symbol);
    prefs.putString('currencySide', info.side);
  }

  static CurrencyInfo active() {
    if (Get.isRegistered<SharedPreferencesManager>()) {
      return current(Get.find<SharedPreferencesManager>());
    }
    return fromCurrencyCode(AppConstants.defaultCurrencyCode);
  }

  static String code() => active().code;

  static String symbol() => active().symbol;

  static String displaySymbol([SharedPreferencesManager? prefs]) {
    final info = prefs != null ? current(prefs) : active();
    if (info.code.toUpperCase() == 'INR') return info.symbol;
    return info.code;
  }

  /// Half-up to 2 decimals so 9.975 becomes 9.98 (not 9.97 from float).
  static double round2(double value) => (value * 100).round() / 100;

  static double discountedPrice(double original, double percent) {
    final cut = round2(original * percent / 100);
    return round2(original - cut);
  }

  static double withTax(double amount, double taxPercent) {
    final tax = round2(amount * taxPercent / 100);
    return round2(amount + tax);
  }

  /// Sell / discounted price is already tax-inclusive. Do not add tax again.
  static String inclusiveFixed(double amount) => round2(amount).toStringAsFixed(2);

  static String withTaxFixed(double amount, double taxPercent) =>
      withTax(amount, taxPercent).toStringAsFixed(2);

  /// API amount + API symbol. Do not convert in the app.
  static String format(dynamic amount, {int? decimals, String? symbol}) {
    final info = active();
    final n = amount is num ? amount : num.tryParse('$amount') ?? 0;
    final places = decimals ?? 2;
    final text = n.toStringAsFixed(places);
    final mark = (symbol ?? info.symbol).trim();
    if (mark.isNotEmpty) return '$mark $text';
    return '${info.code} $text';
  }
}
