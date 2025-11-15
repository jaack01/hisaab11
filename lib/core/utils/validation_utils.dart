import '../constants/app_constants.dart';

/// Utility class for input validation
class ValidationUtils {
  // Private constructor
  ValidationUtils._();

  /// Validate if string is not empty
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validate if string is empty
  static bool isEmpty(String? value) {
    return !isNotEmpty(value);
  }

  /// Validate email address
  static bool isValidEmail(String? email) {
    if (isEmpty(email)) return false;
    final regex = RegExp(AppConstants.emailPattern);
    return regex.hasMatch(email!);
  }

  /// Validate phone number
  static bool isValidPhone(String? phone) {
    if (isEmpty(phone)) return false;
    final regex = RegExp(AppConstants.phoneNumberPattern);
    return regex.hasMatch(phone!);
  }

  /// Validate GSTIN (India)
  static bool isValidGstin(String? gstin) {
    if (isEmpty(gstin)) return false;
    final regex = RegExp(AppConstants.gstinPattern);
    return regex.hasMatch(gstin!);
  }

  /// Validate PAN (India)
  static bool isValidPan(String? pan) {
    if (isEmpty(pan)) return false;
    final regex = RegExp(AppConstants.panPattern);
    return regex.hasMatch(pan!);
  }

  /// Validate amount
  static bool isValidAmount(String? amount) {
    if (isEmpty(amount)) return false;
    try {
      final value = double.parse(amount!);
      return value >= AppConstants.minTransactionAmount &&
          value <= AppConstants.maxTransactionAmount;
    } catch (e) {
      return false;
    }
  }

  /// Validate customer name
  static bool isValidCustomerName(String? name) {
    if (isEmpty(name)) return false;
    return name!.length >= AppConstants.minCustomerNameLength &&
        name.length <= AppConstants.maxCustomerNameLength;
  }

  /// Validate description length
  static bool isValidDescription(String? description) {
    if (description == null) return true; // Description is optional
    return description.length <= AppConstants.maxDescriptionLength;
  }

  /// Validate PIN
  static bool isValidPin(String? pin) {
    if (isEmpty(pin)) return false;
    return pin!.length == AppConstants.pinLength &&
        RegExp(AppConstants.numberOnlyPattern).hasMatch(pin);
  }

  /// Validate alphanumeric string
  static bool isAlphaNumeric(String? value) {
    if (isEmpty(value)) return false;
    final regex = RegExp(AppConstants.alphaNumericPattern);
    return regex.hasMatch(value!);
  }

  /// Validate numeric string
  static bool isNumeric(String? value) {
    if (isEmpty(value)) return false;
    final regex = RegExp(AppConstants.numberOnlyPattern);
    return regex.hasMatch(value!);
  }

  /// Validate minimum length
  static bool hasMinLength(String? value, int minLength) {
    if (isEmpty(value)) return false;
    return value!.length >= minLength;
  }

  /// Validate maximum length
  static bool hasMaxLength(String? value, int maxLength) {
    if (isEmpty(value)) return true;
    return value!.length <= maxLength;
  }

  /// Validate length range
  static bool hasLengthBetween(String? value, int minLength, int maxLength) {
    return hasMinLength(value, minLength) && hasMaxLength(value, maxLength);
  }

  /// Validate URL
  static bool isValidUrl(String? url) {
    if (isEmpty(url)) return false;
    try {
      final uri = Uri.parse(url!);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Validate date is not in future
  static bool isNotFutureDate(DateTime? date) {
    if (date == null) return false;
    return date.isBefore(DateTime.now()) ||
        date.isAtSameMomentAs(DateTime.now());
  }

  /// Validate date is in future
  static bool isFutureDate(DateTime? date) {
    if (date == null) return false;
    return date.isAfter(DateTime.now());
  }

  /// Validate date range
  static bool isDateInRange(DateTime? date, DateTime start, DateTime end) {
    if (date == null) return false;
    return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
        (date.isBefore(end) || date.isAtSameMomentAs(end));
  }

  /// Get error message for empty field
  static String? validateRequired(String? value, String fieldName) {
    if (isEmpty(value)) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Get error message for email
  static String? validateEmailField(String? value) {
    if (isEmpty(value)) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Get error message for phone
  static String? validatePhoneField(String? value) {
    if (isEmpty(value)) {
      return 'Phone number is required';
    }
    if (!isValidPhone(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  /// Get error message for optional phone
  static String? validateOptionalPhoneField(String? value) {
    if (isEmpty(value)) {
      return null; // Phone is optional
    }
    if (!isValidPhone(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  /// Get error message for customer name
  static String? validateCustomerNameField(String? value) {
    if (isEmpty(value)) {
      return 'Customer name is required';
    }
    if (!isValidCustomerName(value)) {
      return 'Name must be between ${AppConstants.minCustomerNameLength} and ${AppConstants.maxCustomerNameLength} characters';
    }
    return null;
  }

  /// Get error message for amount
  static String? validateAmountField(String? value) {
    if (isEmpty(value)) {
      return 'Amount is required';
    }
    if (!isValidAmount(value)) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  /// Get error message for PIN
  static String? validatePinField(String? value) {
    if (isEmpty(value)) {
      return 'PIN is required';
    }
    if (!isValidPin(value)) {
      return 'PIN must be ${AppConstants.pinLength} digits';
    }
    return null;
  }

  /// Get error message for GSTIN
  static String? validateGstinField(String? value) {
    if (isEmpty(value)) {
      return null; // GSTIN is optional
    }
    if (!isValidGstin(value)) {
      return 'Please enter a valid GSTIN';
    }
    return null;
  }

  /// Get error message for PAN
  static String? validatePanField(String? value) {
    if (isEmpty(value)) {
      return null; // PAN is optional
    }
    if (!isValidPan(value)) {
      return 'Please enter a valid PAN';
    }
    return null;
  }

  /// Get error message for description
  static String? validateDescriptionField(String? value) {
    if (!isValidDescription(value)) {
      return 'Description cannot exceed ${AppConstants.maxDescriptionLength} characters';
    }
    return null;
  }

  /// Get error message for confirm PIN match
  static String? validateConfirmPin(String? pin, String? confirmPin) {
    if (isEmpty(confirmPin)) {
      return 'Please confirm your PIN';
    }
    if (pin != confirmPin) {
      return 'PINs do not match';
    }
    return null;
  }

  /// Sanitize input (trim and remove multiple spaces)
  static String sanitize(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Remove all whitespace
  static String removeWhitespace(String input) {
    return input.replaceAll(RegExp(r'\s+'), '');
  }

  /// Capitalize first letter
  static String capitalizeFirst(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Capitalize each word
  static String capitalizeWords(String input) {
    if (input.isEmpty) return input;
    return input
        .split(' ')
        .map((word) => word.isEmpty ? word : capitalizeFirst(word))
        .join(' ');
  }

  /// Format phone number (add spaces)
  static String formatPhone(String phone) {
    final cleaned = removeWhitespace(phone);
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
    }
    return cleaned;
  }

  /// Validate invoice number format
  static bool isValidInvoiceNumber(String? invoiceNumber) {
    if (isEmpty(invoiceNumber)) return false;
    // Check if it follows pattern: INV000001
    final pattern = RegExp(r'^[A-Z]{3}\d{6}$');
    return pattern.hasMatch(invoiceNumber!);
  }

  /// Get error message for invoice number
  static String? validateInvoiceNumber(String? value) {
    if (isEmpty(value)) {
      return 'Invoice number is required';
    }
    if (!isValidInvoiceNumber(value)) {
      return 'Invalid invoice number format';
    }
    return null;
  }

  /// Validate quantity
  static bool isValidQuantity(String? quantity) {
    if (isEmpty(quantity)) return false;
    try {
      final value = double.parse(quantity!);
      return value > 0;
    } catch (e) {
      return false;
    }
  }

  /// Get error message for quantity
  static String? validateQuantity(String? value) {
    if (isEmpty(value)) {
      return 'Quantity is required';
    }
    if (!isValidQuantity(value)) {
      return 'Please enter a valid quantity';
    }
    return null;
  }

  /// Validate rate/price
  static bool isValidRate(String? rate) {
    if (isEmpty(rate)) return false;
    try {
      final value = double.parse(rate!);
      return value >= 0;
    } catch (e) {
      return false;
    }
  }

  /// Get error message for rate
  static String? validateRate(String? value) {
    if (isEmpty(value)) {
      return 'Rate is required';
    }
    if (!isValidRate(value)) {
      return 'Please enter a valid rate';
    }
    return null;
  }
}
