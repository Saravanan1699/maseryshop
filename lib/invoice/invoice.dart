import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../my-order-list/myorderlist.dart';
import '../my-order-list/order-details.dart';
import 'pdf_generator.dart';

class Invoice extends StatelessWidget {
  final Order order;

  const Invoice({super.key, required this.order});

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      // Set the custom download path
      final downloadPath = '/storage/emulated/0/Download/Masery_${order.orderNumber}.pdf';

      // Print path for debugging
      print('Saving PDF to: $downloadPath');

      // Generate the PDF
      final pdfFile = await generatePdf(order);

      // Save the PDF to the specified path
      final file = File(downloadPath);
      await file.writeAsBytes(await pdfFile.readAsBytes());

      // Notify user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to $downloadPath')),
      );

      // Optionally, open the PDF file after saving
      // OpenFile.open(downloadPath);  // Uncomment if you want to open the file automatically

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
      print('Error generating PDF: $e');  // Print error details
    }
  }


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

  @override
  Widget build(BuildContext context) {
    final taxRate = 0.0;  // 0% tax rate
    final discount = 0.0;  // 0 discount

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Invoice',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xffF2F2F2),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  size: 15,
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 80,
                    width: 80,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Masery Shop',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
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
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Items: ${order.itemcount}',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Payment Method: ${_getPaymentMethod(order.paymentMethodId)}',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 10),
              _buildAddressSection('Billing Address:', order.billingAddress),
              SizedBox(height: 20),
              _buildAddressSection('Shipping Address:', order.shippingAddress),
              SizedBox(height: 10),
              Text(
                'Order Date:',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5),
              Text(
                _formatDate(order.createdAt),
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Items Purchased:',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
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
                          _buildTableCell(order.inventories[i]['title'] ?? 'No Title'),
                          _buildTableCell('\$${discount.toStringAsFixed(2)}'),
                          _buildTableCell('\$${tax.toStringAsFixed(2)}'),
                          _buildTableCell('${order.inventories[i]['pivot']['quantity'] ?? '0'}'),
                          _buildTableCell('\$${(double.tryParse(order.inventories[i]['pivot']['unit_price'] ?? '')?.toStringAsFixed(2)) ?? '0.00'}'),
                        ],
                      ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                      ),
                      children: [
                        _buildTableCell('Total', isHeader: true),
                        TableCell(child: Padding(padding: const EdgeInsets.all(8.0))),
                        TableCell(child: Padding(padding: const EdgeInsets.all(8.0))),
                        TableCell(child: Padding(padding: const EdgeInsets.all(8.0))),
                        TableCell(child: Padding(padding: const EdgeInsets.all(8.0))),
                        _buildTableCell('\$${total.toStringAsFixed(2)}', isHeader: true),
                      ],
                    ),
                  ],
                ),
              ],
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => _downloadPdf(context),
                  child: Text('Download PDF', style: GoogleFonts.montserrat(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
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
