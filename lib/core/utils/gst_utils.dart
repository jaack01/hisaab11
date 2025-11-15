/// GST calculation utilities
class GstUtils {
  GstUtils._();

  /// Calculate GST amount from base amount
  static double calculateGstAmount(double baseAmount, double gstRate) {
    return (baseAmount * gstRate) / 100;
  }

  /// Calculate total amount including GST
  static double calculateTotalWithGst(double baseAmount, double gstRate) {
    final gstAmount = calculateGstAmount(baseAmount, gstRate);
    return baseAmount + gstAmount;
  }

  /// Calculate base amount from total (inclusive GST)
  static double calculateBaseFromTotal(double totalAmount, double gstRate) {
    return totalAmount / (1 + (gstRate / 100));
  }

  /// Calculate GST from total amount (reverse calculation)
  static double calculateGstFromTotal(double totalAmount, double gstRate) {
    final baseAmount = calculateBaseFromTotal(totalAmount, gstRate);
    return totalAmount - baseAmount;
  }

  /// Split GST into CGST and SGST (for intra-state)
  static Map<String, double> splitIntraStateGst(double gstAmount) {
    final half = gstAmount / 2;
    return {
      'CGST': half,
      'SGST': half,
    };
  }

  /// Get IGST (for inter-state)
  static double getInterStateGst(double gstAmount) {
    return gstAmount;
  }

  /// Calculate invoice line item totals
  static Map<String, double> calculateLineItemTotals({
    required double quantity,
    required double rate,
    double discountPercentage = 0.0,
    double taxRate = 0.0,
  }) {
    // Line total = quantity * rate
    final lineTotal = quantity * rate;

    // Calculate discount
    final discountAmount = (lineTotal * discountPercentage) / 100;

    // Taxable amount = line total - discount
    final taxableAmount = lineTotal - discountAmount;

    // Calculate tax
    final taxAmount = calculateGstAmount(taxableAmount, taxRate);

    // Total = taxable amount + tax
    final totalAmount = taxableAmount + taxAmount;

    return {
      'lineTotal': lineTotal,
      'discountAmount': discountAmount,
      'taxableAmount': taxableAmount,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
    };
  }

  /// Calculate invoice totals from line items
  static Map<String, double> calculateInvoiceTotals({
    required List<Map<String, double>> lineItems,
    double invoiceDiscountPercentage = 0.0,
  }) {
    // Sum all line items
    double subtotal = 0.0;
    double totalTaxAmount = 0.0;

    for (final item in lineItems) {
      subtotal += item['taxableAmount'] ?? 0.0;
      totalTaxAmount += item['taxAmount'] ?? 0.0;
    }

    // Apply invoice-level discount
    final invoiceDiscountAmount = (subtotal * invoiceDiscountPercentage) / 100;
    final discountedSubtotal = subtotal - invoiceDiscountAmount;

    // Recalculate tax if invoice discount applied
    double finalTaxAmount = totalTaxAmount;
    if (invoiceDiscountAmount > 0) {
      // Need to recalculate taxes on discounted amount
      // This is simplified - real calculation would need per-item tax rates
      final discountRatio = discountedSubtotal / subtotal;
      finalTaxAmount = totalTaxAmount * discountRatio;
    }

    final totalAmount = discountedSubtotal + finalTaxAmount;

    return {
      'subtotal': subtotal,
      'invoiceDiscountAmount': invoiceDiscountAmount,
      'discountedSubtotal': discountedSubtotal,
      'taxAmount': finalTaxAmount,
      'totalAmount': totalAmount,
    };
  }

  /// Validate GSTIN format
  static bool isValidGstin(String? gstin) {
    if (gstin == null || gstin.isEmpty) return false;

    // GSTIN format: 22AAAAA0000A1Z5
    // 2 digits state code + 10 chars PAN + 1 entity number + 1 Z + 1 checksum
    final regex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    return regex.hasMatch(gstin);
  }

  /// Validate HSN Code format
  static bool isValidHsnCode(String? hsnCode) {
    if (hsnCode == null || hsnCode.isEmpty) return false;

    // HSN can be 2, 4, 6, or 8 digits
    final regex = RegExp(r'^[0-9]{2}([0-9]{2})?([0-9]{2})?([0-9]{2})?$');
    return regex.hasMatch(hsnCode);
  }

  /// Get GST rate description
  static String getGstRateDescription(double rate) {
    if (rate == 0) return 'Nil rated';
    if (rate == 0.25) return '0.25%';
    if (rate == 3) return '3%';
    if (rate == 5) return '5%';
    if (rate == 12) return '12%';
    if (rate == 18) return '18%';
    if (rate == 28) return '28%';
    return '$rate%';
  }

  /// Calculate CGST amount
  static double calculateCgst(double taxableAmount, double gstRate) {
    return calculateGstAmount(taxableAmount, gstRate / 2);
  }

  /// Calculate SGST amount
  static double calculateSgst(double taxableAmount, double gstRate) {
    return calculateGstAmount(taxableAmount, gstRate / 2);
  }

  /// Calculate IGST amount
  static double calculateIgst(double taxableAmount, double gstRate) {
    return calculateGstAmount(taxableAmount, gstRate);
  }
}
