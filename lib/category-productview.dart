import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Home-pages/categorylistview.dart';

class ProductDetailsPage extends StatelessWidget {
  final CategotyProduct product;

  ProductDetailsPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title, style: GoogleFonts.montserrat()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product.imagePaths.isNotEmpty
                ? Image.network(
              product.imagePaths[0],
              fit: BoxFit.cover,
            )
                : Placeholder(),
            SizedBox(height: 10),
            Text(
              product.title,
              style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              product.description,
              style: GoogleFonts.montserrat(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Sale Price: \$${product.salePrice}',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add more product details as needed
          ],
        ),
      ),
    );
  }
}
