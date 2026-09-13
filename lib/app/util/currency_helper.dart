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
}
