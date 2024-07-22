import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bottombar/bottombar.dart';
import 'order-details.dart';

class Order {
  final String title;
  final String status;
  final String orderId;
  final String date;
  final String trackid;
  final String quantity;
  final String totalAmount;
  final VoidCallback onPressed;

  Order({
    required this.title,
    required this.status,
    required this.orderId,
    required this.date,
    required this.trackid,
    required this.quantity,
    required this.totalAmount,
    required this.onPressed,
  });
}

class Orderlist extends StatefulWidget {
  const Orderlist({super.key});

  @override
  State<Orderlist> createState() => _OrderlistState();
}

class _OrderlistState extends State<Orderlist> {
  final List<Order> orders = [
    Order(
      title: 'Order 1947034',
      status: 'Delivered',
      orderId: '1947034',
      date: '2024-07-19',
      trackid: 'IW3475453455',
      quantity: '2',
      totalAmount: '120\$',
      onPressed: () {},
    ),
    Order(
      title: 'Order #2',
      status: 'Processing',
      orderId: '1947035',
      date: '2024-07-18',
      trackid: 'IW3475453455',
      quantity: '1',
      totalAmount: '200\$',
      onPressed: () {},
    ),
    Order(
      title: 'Order #3',
      status: 'Delivered',
      orderId: '1947036',
      date: '2024-07-17',
      trackid: 'IW3475453455',
      quantity: '6',
      totalAmount: '400\$',
      onPressed: () {},
    ),
    Order(
      title: 'Order #4',
      status: 'Cancelled',
      orderId: '1947037',
      date: '2024-07-16',
      trackid: 'IW3475453455',
      quantity: '4',
      totalAmount: '450\$',
      onPressed: () {},
    ),
  ];

  List<Order> get deliveredOrders =>
      orders.where((order) => order.status == 'Delivered').toList();

  List<Order> get processingOrders =>
      orders.where((order) => order.status == 'Processing').toList();

  List<Order> get cancelledOrders =>
      orders.where((order) => order.status == 'Cancelled').toList();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Order History',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/logo.png'),
              backgroundColor: Color(0xffF2F2F2),
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Delivered'),
              Tab(text: 'Processing'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderListView(orders: deliveredOrders),
            OrderListView(orders: processingOrders),
            OrderListView(orders: cancelledOrders),
          ],
        ),
        bottomNavigationBar: BottomBar(
          onTap: (index) {},
        ),
      ),
    );
  }
}

class OrderListView extends StatelessWidget {
  final List<Order> orders;

  const OrderListView({required this.orders, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    order.status == 'Delivered'
                        ? Icons.check_box
                        : (order.status == 'Cancelled'
                            ? Icons.cancel
                            : Icons.hourglass_empty),
                    color: order.status == 'Delivered'
                        ? Colors.green
                        : (order.status == 'Cancelled'
                            ? Colors.red
                            : Colors.orange),
                  ),
                  SizedBox(width: 8),
                  Text(
                    order.status,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: order.status == 'Delivered'
                          ? Colors.green
                          : (order.status == 'Cancelled'
                              ? Colors.red
                              : Colors.orange),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ID: ${order.orderId}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    order.date,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Track ID: ${order.trackid}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quantity: ${order.quantity}'),
                  Text(
                    'Total Amount: ${order.totalAmount}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => orderdetails()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Background color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    child: Text(
                      'Details',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    order.status,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: order.status == 'Delivered'
                          ? Colors.green
                          : (order.status == 'Cancelled'
                              ? Colors.red
                              : Colors.orange),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
