import 'package:intl/intl.dart';

class CurrencyFormatter {
  static const String defaultCurrency = 'USD';
  static const String defaultLocale = 'en_US';
  
  static String format(double amount, {String? currencyCode, String? locale}) {
    final format = NumberFormat.currency(
      locale: locale ?? defaultLocale,
      symbol: _getCurrencySymbol(currencyCode ?? defaultCurrency),
      decimalDigits: 2,
    );
    
    return format.format(amount);
  }
  
  static String formatWithoutSymbol(double amount, {String? locale}) {
    final format = NumberFormat.decimalPattern(locale ?? defaultLocale);
    return format.format(amount);
  }
  
  static String formatCompact(double amount, {String? currencyCode, String? locale}) {
    final format = NumberFormat.compactCurrency(
      locale: locale ?? defaultLocale,
      symbol: _getCurrencySymbol(currencyCode ?? defaultCurrency),
      decimalDigits: 1,
    );
    
    return format.format(amount);
  }
  
  static double parse(String amount, {String? locale}) {
    try {
      final format = NumberFormat.currency(
        locale: locale ?? defaultLocale,
        symbol: _getCurrencySymbol(defaultCurrency),
        decimalDigits: 2,
      );
      return format.parse(amount).toDouble();
    } catch (e) {
      try {
        final format = NumberFormat.decimalPattern(locale ?? defaultLocale);
        return format.parse(amount).toDouble();
      } catch (e) {
        return 0.0;
      }
    }
  }
  
  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      case 'PKR':
        return '₨';
      case 'BDT':
        return '৳';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'CHF';
      case 'CNY':
        return '¥';
      case 'SEK':
        return 'kr';
      case 'NOK':
        return 'kr';
      case 'DKK':
        return 'kr';
      case 'PLN':
        return 'zł';
      case 'RUB':
        return '₽';
      case 'BRL':
        return 'R\$';
      case 'MXN':
        return '\$';
      case 'ZAR':
        return 'R';
      case 'SGD':
        return 'S\$';
      case 'HKD':
        return 'HK\$';
      case 'NZD':
        return 'NZ\$';
      case 'KRW':
        return '₩';
      case 'TRY':
        return '₺';
      case 'SAR':
        return '﷼';
      case 'AED':
        return 'د.إ';
      default:
        return currencyCode;
    }
  }
  
  static List<String> getSupportedCurrencies() {
    return [
      'USD', 'EUR', 'GBP', 'JPY', 'INR', 'PKR', 'BDT', 'CAD', 'AUD',
      'CHF', 'CNY', 'SEK', 'NOK', 'DKK', 'PLN', 'RUB', 'BRL', 'MXN',
      'ZAR', 'SGD', 'HKD', 'NZD', 'KRW', 'TRY', 'SAR', 'AED'
    ];
  }
  
  static String getCurrencyName(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound';
      case 'JPY':
        return 'Japanese Yen';
      case 'INR':
        return 'Indian Rupee';
      case 'PKR':
        return 'Pakistani Rupee';
      case 'BDT':
        return 'Bangladeshi Taka';
      case 'CAD':
        return 'Canadian Dollar';
      case 'AUD':
        return 'Australian Dollar';
      case 'CHF':
        return 'Swiss Franc';
      case 'CNY':
        return 'Chinese Yuan';
      case 'SEK':
        return 'Swedish Krona';
      case 'NOK':
        return 'Norwegian Krone';
      case 'DKK':
        return 'Danish Krone';
      case 'PLN':
        return 'Polish Zloty';
      case 'RUB':
        return 'Russian Ruble';
      case 'BRL':
        return 'Brazilian Real';
      case 'MXN':
        return 'Mexican Peso';
      case 'ZAR':
        return 'South African Rand';
      case 'SGD':
        return 'Singapore Dollar';
      case 'HKD':
        return 'Hong Kong Dollar';
      case 'NZD':
        return 'New Zealand Dollar';
      case 'KRW':
        return 'South Korean Won';
      case 'TRY':
        return 'Turkish Lira';
      case 'SAR':
        return 'Saudi Riyal';
      case 'AED':
        return 'UAE Dirham';
      default:
        return currencyCode;
    }
  }
}
