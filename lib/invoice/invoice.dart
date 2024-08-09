import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maseryshop/Responsive/responsive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../my-order-list/myorderlist.dart';
import '../my-order-list/order-details.dart';
import 'pdf_generator.dart'; // Ensure this file is properly defined

class Invoice extends StatelessWidget {
  final Order order;

  const Invoice({super.key, required this.order});

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

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final pdfGenerator = PdfGenerator(); // Ensure PdfGenerator is defined

      // Generate the PDF content asynchronously
      final pdfContent = await pdfGenerator.buildInvoicePdf(order);

      // Add the generated PDF content to the document
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pdfContent,
        ),
      );

      // Get the file path for saving the PDF
      final outputFile = await _getFilePath();
      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(await pdf.save());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to $outputFile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving PDF: $e')),
      );
    }
  }

  Future<String?> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Masergy_Shop_Invoice_${order.orderNumber}.pdf';
    return filePath;
  }

  Future<void> _printPdf() async {
    try {
      final pdf = pw.Document();
      final pdfGenerator = PdfGenerator(); // Ensure PdfGenerator is defined

      // Generate the PDF content asynchronously
      final pdfContent = await pdfGenerator.buildInvoicePdf(order);

      // Add the generated PDF content to the document
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pdfContent,
        ),
      );

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Masergy_Shop_Invoice_${order.orderNumber}.pdf',
      );
    } catch (e) {
      // Handle print error
      print('Error printing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final taxRate = 0.0; // 0% tax rate
    final discount = 0.0; // 0 discount

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
    final responsive = Responsive(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Invoice',
          style: GoogleFonts.montserrat(
            fontSize: responsive.textSize(3),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: responsive.marginPercentage(2, 0.5, 1, 1),
              decoration: BoxDecoration(
                color: Color(0xffF2F2F2),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  size: responsive.textSize(2.5),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: responsive.paddingPercentage(5, 2, 5, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: responsive.heightPercentage(10),
                    width: responsive.widthPercentage(20),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Masergy Shop',
                    style: GoogleFonts.montserrat(
                      fontSize: responsive.textSize(2.5),
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Order No: ${order.orderNumber}',
                style: GoogleFonts.montserrat(
                  fontSize: responsive.textSize(2.5),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Items: ${order.itemcount}',
                style: GoogleFonts.montserrat(
                  fontSize: responsive.textSize(2.5),
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Payment Method: ${_getPaymentMethod(order.paymentMethodId)}',
                style: GoogleFonts.montserrat(
                  fontSize: responsive.textSize(2.5),
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: responsive.heightPercentage(3)),
              _buildAddressSection('Billing Address:', order.billingAddress),
              SizedBox(height: responsive.heightPercentage(3)),
              _buildAddressSection('Shipping Address:', order.shippingAddress),
              SizedBox(height: responsive.heightPercentage(3)),
              Text(
                'Order Date:',
                style: GoogleFonts.montserrat(
                  fontSize: responsive.textSize(2.5),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5),
              Text(
                _formatDate(order.createdAt),
                style: GoogleFonts.montserrat(
                  fontSize: responsive.textSize(2.5),
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: responsive.heightPercentage(3)),
              Text(
                'Items Purchased:',
                style: GoogleFonts.montserrat(
                  fontSize: responsive.textSize(2.5),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              if (order.inventories.isNotEmpty) ...[
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(2),
                    5: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                      ),
                      children: [
                        _buildTableCell('S.No', isHeader: true),
                        _buildTableCell('Title', isHeader: true),
                        _buildTableCell('Discount', isHeader: true),
                        _buildTableCell('Tax', isHeader: true),
                        _buildTableCell('Quantity', isHeader: true),
                        _buildTableCell('Price', isHeader: true),
                      ],
                    ),
                    for (int i = 0; i < order.inventories.length; i++)
                      TableRow(
                        children: [
                          _buildTableCell('${i + 1}'),
                          _buildTableCell(
                              order.inventories[i]['title'] ?? 'No Title'),
                          _buildTableCell('\$${discount.toStringAsFixed(2)}'),
                          _buildTableCell('\$${tax.toStringAsFixed(2)}'),
                          _buildTableCell(
                              '${order.inventories[i]['pivot']['quantity'] ?? '0'}'),
                          _buildTableCell(
                              '\$${(double.tryParse(order.inventories[i]['pivot']['unit_price'] ?? '')?.toStringAsFixed(2)) ?? '0.00'}'),
                        ],
                      ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                      ),
                      children: [
                        _buildTableCell('Total', isHeader: true),
                        TableCell(
                            child: Padding(padding: const EdgeInsets.all(8.0))),
                        TableCell(
                            child: Padding(padding: const EdgeInsets.all(8.0))),
                        TableCell(
                            child: Padding(padding: const EdgeInsets.all(8.0))),
                        TableCell(
                            child: Padding(padding: const EdgeInsets.all(8.0))),
                        _buildTableCell('\$${total.toStringAsFixed(2)}',
                            isHeader: true),
                      ],
                    ),
                  ],
                ),
              ],
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _printPdf();
                    await _downloadPdf(context);
                  },
                  child: Text('Download',
                      style: GoogleFonts.montserrat(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: responsive.symmetricPaddingPercentage(7 , 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection(String title, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        Text(
          address,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  TableCell _buildTableCell(String text, {bool isHeader = false}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isHeader ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
