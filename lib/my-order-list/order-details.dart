import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Home-pages/home.dart';
import '../bottombar/bottombar.dart';

class orderdetails extends StatefulWidget {
  const orderdetails({super.key});

  @override
  State<orderdetails> createState() => _orderdetailsState();
}

class _orderdetailsState extends State<orderdetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Order Details',
          style: GoogleFonts.montserrat(),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order No 1947034',
                    style: GoogleFonts.montserrat(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '22-07-2024',
                    style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
                  Text(
                    'Tracking number:',
                    style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400]),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'IW3475453455',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Delivered',
                    style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.green),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
                  Text(
                    '3 items',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            _buildOrderItem('Asus', '424.00', '1', 'assets/logo.png'),
            _buildOrderItem('Vivo', '350.00', '1', 'assets/logo.png'),
            _buildOrderItem('Asus Vivobook', '524.00', '1', 'assets/logo.png'),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                'Order information',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 15),
            _buildOrderInfo('Shipping Address:',
                '3 Newbridge Court, Chino Hills,\nCA 91709, United States'),
            _buildOrderInfo('Payment method:', 'Cash on delivery'),
            _buildOrderInfo('Delivery method:', 'FedEx, 3 days, \$15'),
            _buildOrderInfo('Discount:', '10%, Personal promo code'),
            _buildOrderInfo('Total Amount:', '\$1298'),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => orderdetails()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Color(0xff0D6EFD)),
                  ),
                ),
                child: Text(
                  'Feedback',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Color(0xff0D6EFD),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        onTap: (index) {},
      ),
    );
  }

  Widget _buildOrderItem(
      String name, String price, String unit, String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 100,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    )),
                Row(
                  children: [
                    Text('Price:',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        )),
                    SizedBox(width: 5),
                    Text(price,
                        style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400])),
                  ],
                ),
                Row(
                  children: [
                    Text('Unit:',
                        style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400])),
                    SizedBox(width: 5),
                    Text(unit,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
