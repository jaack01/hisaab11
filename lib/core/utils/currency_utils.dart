import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for currency formatting and operations
class CurrencyUtils {
  // Private constructor
  CurrencyUtils._();

  /// Format amount to currency string with symbol
  static String formatCurrency(
    double amount, {
    String? symbol,
    int? decimalPlaces,
    bool showSymbol = true,
  }) {
    final currencySymbol = symbol ?? AppConstants.defaultCurrencySymbol;
    final decimals = decimalPlaces ?? AppConstants.currencyDecimalPlaces;

    final formatter = NumberFormat.currency(
      symbol: showSymbol ? currencySymbol : '',
      decimalDigits: decimals,
      locale: 'en_IN', // Indian locale for number formatting
    );

    return formatter.format(amount);
  }

  /// Format amount to currency string without symbol
  static String formatAmount(
    double amount, {
    int? decimalPlaces,
  }) {
    return formatCurrency(
      amount,
      decimalPlaces: decimalPlaces,
      showSymbol: false,
    );
  }

  /// Format amount in Indian numbering system (lakhs, crores)
  static String formatIndianCurrency(
    double amount, {
    String? symbol,
    bool showSymbol = true,
  }) {
    final currencySymbol = symbol ?? AppConstants.defaultCurrencySymbol;
    final absAmount = amount.abs();
    final isNegative = amount < 0;

    String formattedAmount;

    if (absAmount >= 10000000) {
      // Crores
      formattedAmount =
          '${(absAmount / 10000000).toStringAsFixed(2)} Cr';
    } else if (absAmount >= 100000) {
      // Lakhs
      formattedAmount =
          '${(absAmount / 100000).toStringAsFixed(2)} L';
    } else if (absAmount >= 1000) {
      // Thousands
      formattedAmount =
          '${(absAmount / 1000).toStringAsFixed(2)} K';
    } else {
      formattedAmount = absAmount.toStringAsFixed(2);
    }

    final prefix = isNegative ? '-' : '';
    final symbolPart = showSymbol ? '$currencySymbol ' : '';

    return '$prefix$symbolPart$formattedAmount';
  }

  /// Format amount with commas in Indian style
  static String formatWithCommas(double amount) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return formatter.format(amount);
  }

  /// Parse currency string to double
  static double parseCurrency(String currencyString) {
    try {
      // Remove currency symbol and commas
      final cleanedString = currencyString
          .replaceAll(AppConstants.defaultCurrencySymbol, '')
          .replaceAll(',', '')
          .trim();
      return double.parse(cleanedString);
    } catch (e) {
      return 0.0;
    }
  }

  /// Round amount to specified decimal places
  static double roundAmount(double amount, {int decimalPlaces = 2}) {
    final factor = pow(10, decimalPlaces).toDouble();
    return (amount * factor).round() / factor;
  }

  /// Check if amount is valid
  static bool isValidAmount(double amount) {
    return amount >= AppConstants.minTransactionAmount &&
        amount <= AppConstants.maxTransactionAmount;
  }

  /// Get absolute value
  static double abs(double amount) {
    return amount.abs();
  }

  /// Convert amount to words (Indian style)
  static String amountToWords(double amount) {
    if (amount == 0) return 'Zero';

    final ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
    ];

    final teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];

    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    String convertToWords(int number) {
      if (number == 0) return '';

      if (number < 10) {
        return ones[number];
      } else if (number < 20) {
        return teens[number - 10];
      } else if (number < 100) {
        final ten = number ~/ 10;
        final one = number % 10;
        return '${tens[ten]} ${ones[one]}'.trim();
      } else if (number < 1000) {
        final hundred = number ~/ 100;
        final remainder = number % 100;
        return '${ones[hundred]} Hundred ${convertToWords(remainder)}'.trim();
      } else if (number < 100000) {
        final thousand = number ~/ 1000;
        final remainder = number % 1000;
        return '${convertToWords(thousand)} Thousand ${convertToWords(remainder)}'
            .trim();
      } else if (number < 10000000) {
        final lakh = number ~/ 100000;
        final remainder = number % 100000;
        return '${convertToWords(lakh)} Lakh ${convertToWords(remainder)}'
            .trim();
      } else {
        final crore = number ~/ 10000000;
        final remainder = number % 10000000;
        return '${convertToWords(crore)} Crore ${convertToWords(remainder)}'
            .trim();
      }
    }

    final intAmount = amount.toInt();
    final decimal = ((amount - intAmount) * 100).round();

    String result = convertToWords(intAmount);

    if (decimal > 0) {
      result += ' and ${convertToWords(decimal)} Paise';
    }

    return result;
  }

  /// Format for display in lists (compact format)
  static String formatCompact(double amount, {String? symbol}) {
    final currencySymbol = symbol ?? AppConstants.defaultCurrencySymbol;
    final absAmount = amount.abs();
    final isNegative = amount < 0;

    String formattedAmount;

    if (absAmount >= 10000000) {
      formattedAmount = '${(absAmount / 10000000).toStringAsFixed(1)}Cr';
    } else if (absAmount >= 100000) {
      formattedAmount = '${(absAmount / 100000).toStringAsFixed(1)}L';
    } else {
      formattedAmount = formatWithCommas(absAmount);
    }

    final prefix = isNegative ? '-' : '';
    return '$prefix$currencySymbol$formattedAmount';
  }

  /// Calculate percentage
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0.0;
    return (value / total) * 100;
  }

  /// Calculate amount from percentage
  static double calculateAmountFromPercentage(
    double total,
    double percentage,
  ) {
    return (total * percentage) / 100;
  }

  /// Add GST to amount
  static double addGst(double amount, double gstRate) {
    return amount + calculateAmountFromPercentage(amount, gstRate);
  }

  /// Calculate GST from total amount
  static double calculateGstFromTotal(double totalAmount, double gstRate) {
    return totalAmount - (totalAmount / (1 + (gstRate / 100)));
  }

  /// Get base amount (excluding GST)
  static double getBaseAmount(double totalAmount, double gstRate) {
    return totalAmount / (1 + (gstRate / 100));
  }
}

// Helper function for pow
num pow(num x, num exponent) {
  if (exponent == 0) return 1;
  if (exponent == 1) return x;

  num result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= x;
  }
  return result;
}
