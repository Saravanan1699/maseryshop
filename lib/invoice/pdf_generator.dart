import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../my-order-list/myorderlist.dart';

Future<File> generatePdf(Order order) async {
  final pdf = pw.Document();

  String _getPaymentMethod(String paymentMethodId) {
    switch (paymentMethodId) {
      case '1':
        return 'Cash on Delivery';
      case '2':
        return 'Google Payment';
      default:
        return 'Unknown Payment Method';
    }
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }

  List<String> _splitAddress(String address, int maxLength) {
    List<String> lines = [];
    for (int i = 0; i < address.length; i += maxLength) {
      lines.add(address.substring(
          i, i + maxLength > address.length ? address.length : i + maxLength));
    }
    return lines;
  }

  final logo = await _getLogoImage();

  // Assume fixed tax and discount for now
  final taxRate = 0.0;
  final discount = 0.0; // 0 discount

  // Calculate totals
  final subtotal = order.inventories.fold<double>(
    0.0,
    (total, item) =>
        total +
        (double.tryParse(item['pivot']['unit_price'] ?? '0.0') ?? 0.0) *
            (int.tryParse(item['pivot']['quantity'] ?? '0') ?? 0),
  );

  final tax = subtotal * taxRate;
  final totalAfterDiscount = subtotal - discount;
  final total = totalAfterDiscount + tax;

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Logo and name at the top
          pw.Row(
            children: [
              pw.Image(logo, height: 80),
              pw.SizedBox(width: 10),
              pw.Text('Masery Shop',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Sold By:',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Tradepac Global Pte Ltd',
                        style: pw.TextStyle(fontSize: 12)),
                    pw.Text('1 ROCHOR CANAL ROAD #05 - 18',
                        style: pw.TextStyle(fontSize: 12)),
                    pw.Text('SIMLIM SQUARE', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('SINGAPORE', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Billing Address:',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: _splitAddress(order.billingAddress, 30)
                          .map((line) =>
                              pw.Text(line, style: pw.TextStyle(fontSize: 12)))
                          .toList(),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text('Shipping Address:',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: _splitAddress(order.shippingAddress, 30)
                          .map((line) =>
                              pw.Text(line, style: pw.TextStyle(fontSize: 12)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Order No: ${order.orderNumber}',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Text('Items: ${order.itemcount}',
              style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text('Order Date: ${_formatDate(order.createdAt)}',
              style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            columnWidths: {
              0: pw.FractionColumnWidth(0.2), // Serial Number
              1: pw.FractionColumnWidth(0.4), // Title
              2: pw.FractionColumnWidth(0.3), // Quantity
              3: pw.FractionColumnWidth(0.4), // Price
              4: pw.FractionColumnWidth(0.3), // Tax
              5: pw.FractionColumnWidth(0.3), // Discount
              6: pw.FractionColumnWidth(0.4), // Total
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue500,
                ),
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('S.No',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Title',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Quantity',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Price',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Tax',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Discount',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Total',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                ],
              ),
              for (int i = 0; i < order.inventories.length; i++)
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        '${i + 1}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        order.inventories[i]['title'] ?? 'No Title',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        '${order.inventories[i]['pivot']['quantity'] ?? '0'}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        '\$${(double.tryParse(order.inventories[i]['pivot']['unit_price'] ?? '')?.toStringAsFixed(2)) ?? '0.00'}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('-\$${tax.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 12)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('-\$${discount.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 12)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        '\$${(double.tryParse(order.inventories[i]['pivot']['unit_price'] ?? '0.0') ?? 0.0 * (int.tryParse(order.inventories[i]['pivot']['quantity'] ?? '0') ?? 0)).toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Total:',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 20),
              pw.Text('\$${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 20),
          // pw.Align(
          //   alignment: pw.Alignment.bottomLeft,
          //   child: pw.BarcodeWidget(
          //     barcode: pw.Barcode.qrCode(),
          //     data: 'https://example.com',
          //     width: 50,
          //     height: 50,
          //   ),
          // ),
        ],
      ),
    ),
  );

  final outputFile = await _getOutputFile();
  await outputFile.writeAsBytes(await pdf.save());
  return outputFile;
}

Future<File> _getOutputFile() async {
  final directory = await getExternalStorageDirectory();
  final path = '${directory!.path}/invoice_${DateTime.now().toString()}.pdf';
  return File(path);
}

Future<pw.ImageProvider> _getLogoImage() async {
  final byteData = await rootBundle
      .load('assets/logo.png'); // Assuming logo is stored in assets
  final buffer = byteData.buffer.asUint8List();
  return pw.MemoryImage(buffer);
}
