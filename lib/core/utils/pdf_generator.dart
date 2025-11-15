import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import 'currency_utils.dart';
import 'date_utils.dart';
import 'gst_utils.dart';

/// PDF generator for invoices
class PdfGenerator {
  PdfGenerator._();

  /// Generate invoice PDF
  static Future<File> generateInvoicePdf({
    required Business business,
    required Customer customer,
    required Invoice invoice,
    required List<InvoiceItem> items,
  }) async {
    final pdf = pw.Document();

    // Add invoice page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(business, invoice),
          pw.SizedBox(height: 20),
          _buildBillToSection(business, customer),
          pw.SizedBox(height: 20),
          _buildInvoiceDetails(invoice),
          pw.SizedBox(height: 20),
          _buildItemsTable(items, invoice.isGstInvoice),
          pw.SizedBox(height: 20),
          _buildTotalsSection(invoice, items),
          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildNotes(invoice.notes!),
          ],
          if (invoice.termsConditions != null && invoice.termsConditions!.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildTermsConditions(invoice.termsConditions!),
          ],
          pw.Spacer(),
          _buildFooter(business),
        ],
      ),
    );

    // Save PDF to file
    final output = await _getOutputFile(invoice.invoiceNumber);
    final bytes = await pdf.save();
    await output.writeAsBytes(bytes);

    return output;
  }

  /// Build header section
  static pw.Widget _buildHeader(Business business, Invoice invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                business.name,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              if (business.address != null)
                pw.Text(business.address!, style: const pw.TextStyle(fontSize: 10)),
              if (business.phone != null)
                pw.Text('Phone: ${business.phone}', style: const pw.TextStyle(fontSize: 10)),
              if (business.email != null)
                pw.Text('Email: ${business.email}', style: const pw.TextStyle(fontSize: 10)),
              if (business.gstin != null && business.gstin!.isNotEmpty)
                pw.Text(
                  'GSTIN: ${business.gstin}',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              invoice.isGstInvoice ? 'TAX INVOICE' : 'INVOICE',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              '#${invoice.invoiceNumber}',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build bill to section
  static pw.Widget _buildBillToSection(Business business, Customer customer) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Bill To:',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                customer.name,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (customer.address != null && customer.address!.isNotEmpty)
                pw.Text(customer.address!, style: const pw.TextStyle(fontSize: 10)),
              if (customer.phone != null && customer.phone!.isNotEmpty)
                pw.Text('Phone: ${customer.phone}', style: const pw.TextStyle(fontSize: 10)),
              if (customer.gstin != null && customer.gstin!.isNotEmpty)
                pw.Text(
                  'GSTIN: ${customer.gstin}',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
            ],
          ),
        ),
        if (business.address != null) ...[
          pw.SizedBox(width: 40),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Ship To:',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (customer.address != null && customer.address!.isNotEmpty)
                  pw.Text(customer.address!, style: const pw.TextStyle(fontSize: 10))
                else
                  pw.Text('Same as billing address', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build invoice details
  static pw.Widget _buildInvoiceDetails(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildDetailItem('Invoice Date', AppDateUtils.formatDate(invoice.invoiceDate)),
          if (invoice.dueDate != null)
            _buildDetailItem('Due Date', AppDateUtils.formatDate(invoice.dueDate!)),
          if (invoice.paymentTerms != null && invoice.paymentTerms!.isNotEmpty)
            _buildDetailItem('Payment Terms', invoice.paymentTerms!),
          _buildDetailItem('Status', invoice.status),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  /// Build items table
  static pw.Widget _buildItemsTable(List<InvoiceItem> items, bool isGstInvoice) {
    final headers = [
      '#',
      'Item',
      'HSN',
      'Qty',
      'Rate',
      'Amount',
      if (isGstInvoice) 'Tax%',
      if (isGstInvoice) 'Tax',
      'Total',
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: isGstInvoice
          ? {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FixedColumnWidth(60),
              3: const pw.FixedColumnWidth(40),
              4: const pw.FixedColumnWidth(60),
              5: const pw.FixedColumnWidth(70),
              6: const pw.FixedColumnWidth(40),
              7: const pw.FixedColumnWidth(60),
              8: const pw.FixedColumnWidth(70),
            }
          : {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FixedColumnWidth(60),
              3: const pw.FixedColumnWidth(50),
              4: const pw.FixedColumnWidth(70),
              5: const pw.FixedColumnWidth(80),
              6: const pw.FixedColumnWidth(80),
            },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue50),
          children: headers
              .map((header) => pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      header,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ))
              .toList(),
        ),
        // Item rows
        ...items.asMap().entries.map(
              (entry) => _buildItemRow(entry.key + 1, entry.value, isGstInvoice),
            ),
      ],
    );
  }

  static pw.TableRow _buildItemRow(int index, InvoiceItem item, bool isGstInvoice) {
    final cells = [
      index.toString(),
      '${item.itemName}${item.description != null && item.description!.isNotEmpty ? '\n${item.description}' : ''}',
      item.hsnCode ?? '-',
      '${item.quantity} ${item.unit}',
      CurrencyUtils.formatCurrency(item.rate),
      CurrencyUtils.formatCurrency(item.lineTotal),
      if (isGstInvoice) '${item.taxRate}%',
      if (isGstInvoice) CurrencyUtils.formatCurrency(item.taxAmount),
      CurrencyUtils.formatCurrency(item.totalAmount),
    ];

    return pw.TableRow(
      children: cells
          .map((cell) => pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  cell,
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: cells.indexOf(cell) == 1 ? pw.TextAlign.left : pw.TextAlign.right,
                ),
              ))
          .toList(),
    );
  }

  /// Build totals section
  static pw.Widget _buildTotalsSection(Invoice invoice, List<InvoiceItem> items) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Amount in Words:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                CurrencyUtils.amountToWords(invoice.totalAmount),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Column(
            children: [
              _buildTotalRow('Subtotal:', invoice.subtotal),
              if (invoice.discountAmount > 0)
                _buildTotalRow('Discount:', -invoice.discountAmount),
              if (invoice.isGstInvoice && invoice.taxAmount > 0) ...[
                pw.Divider(thickness: 0.5),
                ..._buildGstBreakdown(items),
                pw.Divider(thickness: 0.5),
              ],
              _buildTotalRow(
                'Total Amount:',
                invoice.totalAmount,
                isTotal: true,
              ),
              if (invoice.paidAmount > 0)
                _buildTotalRow('Paid:', -invoice.paidAmount),
              if (invoice.balanceAmount > 0)
                _buildTotalRow(
                  'Balance Due:',
                  invoice.balanceAmount,
                  isTotal: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  static List<pw.Widget> _buildGstBreakdown(List<InvoiceItem> items) {
    // Calculate total CGST and SGST (assuming intra-state)
    double totalTax = items.fold(0.0, (sum, item) => sum + item.taxAmount);
    final gstSplit = GstUtils.splitIntraStateGst(totalTax);

    return [
      _buildTotalRow('CGST:', gstSplit['CGST']!),
      _buildTotalRow('SGST:', gstSplit['SGST']!),
    ];
  }

  static pw.Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 11 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            CurrencyUtils.formatCurrency(amount),
            style: pw.TextStyle(
              fontSize: isTotal ? 11 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Build notes section
  static pw.Widget _buildNotes(String notes) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Notes:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          notes,
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  /// Build terms and conditions
  static pw.Widget _buildTermsConditions(String terms) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Terms & Conditions:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          terms,
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  /// Build footer
  static pw.Widget _buildFooter(Business business) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 10),
        pw.Text(
          'Authorized Signatory',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 40),
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 10),
        pw.Text(
          business.name,
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  /// Get output file path
  static Future<File> _getOutputFile(String invoiceNumber) async {
    final directory = await getApplicationDocumentsDirectory();
    final invoicesDir = Directory('${directory.path}/invoices');

    // Create directory if it doesn't exist
    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }

    final fileName = 'Invoice_${invoiceNumber.replaceAll('/', '_')}.pdf';
    return File('${invoicesDir.path}/$fileName');
  }

  /// Share invoice PDF
  static Future<void> shareInvoice(File pdfFile) async {
    // This would integrate with share_plus package
    // For now, just return the file path
    // In real implementation: Share.shareFiles([pdfFile.path]);
  }

  /// Print invoice
  static Future<void> printInvoice(File pdfFile) async {
    // This would integrate with printing package
    // For now, placeholder
    // In real implementation: await Printing.layoutPdf(onLayout: (_) => pdfFile.readAsBytes());
  }
}
